/* -*- Mode:C++; c-file-style:"gnu"; indent-tabs-mode:nil; -*- */
/*
 * Copyright (c) 2018 Stanford University
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation;
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 * Authors: Stephen Ibanez <sibanez@stanford.edu>
 * Author: Mariano Scazzariello <marianos@kth.se>
 */
#include "p4-pipeline.h"

#include "ns3/log.h"

#include <bm/bm_runtime/bm_runtime.h>
#include <bm/bm_sim/event_logger.h>
#include <bm/bm_sim/logger.h>
#include <bm/bm_sim/options_parse.h>
#include <bm/bm_sim/parser.h>
#include <bm/bm_sim/tables.h>
#include <cstdlib>
#include <iostream>
#include <memory>
#include <string>
#include <unistd.h>

extern int import_primitives();

namespace ns3
{
NS_LOG_COMPONENT_DEFINE("P4Pipeline");

namespace
{

struct hash_ex
{
    uint32_t operator()(const char* buf, size_t s) const
    {
        const uint32_t p = 16777619;
        uint32_t hash = 2166136261;

        for (size_t i = 0; i < s; i++)
            hash = (hash ^ buf[i]) * p;

        hash += hash << 13;
        hash ^= hash >> 7;
        hash += hash << 3;
        hash ^= hash >> 17;
        hash += hash << 5;
        return static_cast<uint32_t>(hash);
    }
};

struct bmv2_hash
{
    uint64_t operator()(const char* buf, size_t s) const
    {
        return bm::hash::xxh64(buf, s);
    }
};

} // namespace

// if REGISTER_HASH calls placed in the anonymous namespace, some compiler can
// give an unused variable warning
REGISTER_HASH(hash_ex);
REGISTER_HASH(bmv2_hash);

// initialize static attributes
int P4Pipeline::thrift_port = 9090;
bm::packet_id_t P4Pipeline::packet_id = 0;
uint8_t P4Pipeline::ns2bm_buf[MAX_PKT_SIZE] = {};

P4Pipeline::P4Pipeline(std::string jsonFile, std::string name)
    : pre(new bm::McSimplePreLAG())
{
    add_component<bm::McSimplePreLAG>(pre);

    // Fields taken from simple_switch
    add_required_field("standard_metadata", "ingress_port");
    add_required_field("standard_metadata", "packet_length");
    add_required_field("standard_metadata", "instance_type");
    add_required_field("standard_metadata", "egress_spec");
    add_required_field("standard_metadata", "egress_port");

    force_arith_header("standard_metadata");
    force_arith_header("queueing_metadata");
    force_arith_header("intrinsic_metadata");

    import_primitives();

    std::string node_id = (name.empty()) ? std::to_string(thrift_port) : name;

    // Initialize the switch
    bm::OptionsParser opt_parser;
    opt_parser.config_file_path = jsonFile;
    opt_parser.debugger_addr =
        std::string("ipc:///tmp/bmv2-") + node_id + std::string("-debug.ipc");
    opt_parser.notifications_addr =
        std::string("ipc:///tmp/bmv2-") + node_id + std::string("-notifications.ipc");
    opt_parser.thrift_port = thrift_port++;
    opt_parser.console_logging = true;

    LogComponent component = GetLogComponent("P4Pipeline");
    if (component.IsEnabled(LOG_LEVEL_DEBUG))
    {
        std::cout << "DEBUG" << std::endl;
        opt_parser.log_level = bm::Logger::LogLevel::DEBUG;
    }
    else if (component.IsEnabled(LOG_LEVEL_INFO))
    {
        std::cout << "INFO" << std::endl;
        opt_parser.log_level = bm::Logger::LogLevel::INFO;
    }
    else if (component.IsEnabled(LOG_LEVEL_WARN))
    {
        std::cout << "WARN" << std::endl;
        opt_parser.log_level = bm::Logger::LogLevel::WARN;
    }
    else if (component.IsEnabled(LOG_LEVEL_ERROR))
    {
        std::cout << "ERROR" << std::endl;
        opt_parser.log_level = bm::Logger::LogLevel::ERROR;
    }
    else
    {
        opt_parser.console_logging = false;
    }

    int status = init_from_options_parser(opt_parser);
    if (status != 0)
    {
        BMLOG_DEBUG("Failed to initialize the P4 pipeline");
        std::exit(status);
    }

    int port = get_runtime_port();
    bm_runtime::start_server(this, port);
    start_and_return();
}

std::string
P4Pipeline::run_cli_commands(std::string commands)
{
    // Run the CLI commands to populate table entries
    int port = get_runtime_port();
    std::string cmd =
        "run_bmv2_CLI --thrift_port " + std::to_string(port) + " \"" + commands + "\"";

    std::string result = "";

    std::shared_ptr<FILE> pipe(popen(cmd.c_str(), "r"), pclose);
    if (!pipe)
        return result;

    char buffer[128];
    while (!feof(pipe.get()))
    {
        if (fgets(buffer, 128, pipe.get()) != NULL)
            result += buffer;
    }

    return result;
}

void
P4Pipeline::start_and_return_()
{
}

int
P4Pipeline::receive_(bm::DevMgr::port_t, const char* buffer, int len)
{
    return 0;
}

std::unique_ptr<bm::Packet>
P4Pipeline::process_ingress(Ptr<const Packet> ns3_packet, uint32_t ingress_port)
{
    bm::Parser* parser = this->get_parser("parser");

    int len = ns3_packet->GetSize();
    auto packet = get_bm_packet(ns3_packet, ingress_port);

    BMELOG(packet_in, *packet);

    bm::PHV* phv = packet->get_phv();
    phv->reset_metadata();
    phv->get_field("standard_metadata.packet_length").set(len);

    bm::Field& f_instance_type = phv->get_field("standard_metadata.instance_type");
    f_instance_type.set(PKT_INSTANCE_TYPE_NORMAL);

    if (phv->has_field("intrinsic_metadata.ingress_global_timestamp"))
    {
        phv->get_field("intrinsic_metadata.ingress_global_timestamp")
            .set(Simulator::Now().GetNanoSeconds());
    }

    phv->get_field("standard_metadata.ingress_port").set(ingress_port);

    const bm::Packet::buffer_state_t packet_in_state = packet->save_buffer_state();
    parser->parse(packet.get());

    if (phv->has_field("standard_metadata.parser_error"))
    {
        phv->get_field("standard_metadata.parser_error").set(packet->get_error_code().get());
    }

    if (phv->has_field("standard_metadata.checksum_error"))
    {
        phv->get_field("standard_metadata.checksum_error")
            .set(packet->get_checksum_error() ? 1 : 0);
    }

    // The following is similar to what happens in bmv2 simple_switch ingress thread.
    bm::Pipeline* ingress_mau = this->get_pipeline("ingress");

    BMLOG_DEBUG_PKT(*packet, "Processing packet");

    ingress_mau->apply(packet.get());
    packet->reset_exit();

    return packet;
}

// Handle Traffic Management, for now only implements unicast and mcast
void
P4Pipeline::process_tm(
    std::list<std::tuple<uint16_t, uint16_t, std::unique_ptr<bm::Packet>>>* pkts_to_egress,
    std::unique_ptr<bm::Packet> packet)
{
    bm::PHV* phv = packet->get_phv();
    bm::Field& f_egress_spec_ig = phv->get_field("standard_metadata.egress_spec");
    uint16_t egress_spec_ig = f_egress_spec_ig.get_uint();

    unsigned int mgid = 0u;
    if (phv->has_field("intrinsic_metadata.mcast_grp"))
    {
        bm::Field& f_mgid = phv->get_field("intrinsic_metadata.mcast_grp");
        mgid = f_mgid.get_uint();
    }
    if (mgid != 0)
    {
        BMLOG_DEBUG_PKT(*packet, "Multicast requested for packet");
        auto& f_instance_type = phv->get_field("standard_metadata.instance_type");
        f_instance_type.set(PKT_INSTANCE_TYPE_REPLICATION);
        this->process_multicast(pkts_to_egress, packet.get(), mgid);
    }
    else
    {
        BMLOG_DEBUG_PKT(*packet, "Egress port is {}", egress_spec_ig);
        if (egress_spec_ig == drop_port)
        {
            BMLOG_DEBUG_PKT(*packet, "Dropping packet at ingress");
            packet.release();
        }
        else
        {
            auto& f_instance_type = phv->get_field("standard_metadata.instance_type");
            f_instance_type.set(PKT_INSTANCE_TYPE_NORMAL);

            unsigned int qid = 0u;
            if (phv->has_field("intrinsic_metadata.priority"))
            {
                auto& qid_f = phv->get_field("intrinsic_metadata.priority");
                qid = qid_f.get_uint();
            }

            pkts_to_egress->push_back(std::make_tuple(egress_spec_ig, qid, std::move(packet)));
        }
    }
}

int
P4Pipeline::process_egress(std::unique_ptr<bm::Packet>& packet,
                           int pkt_len,
                           uint16_t egress_port,
                           uint32_t qid,
                           uint64_t enq_qdepth,
                           uint64_t deq_qdepth,
                           int64_t enq_tstamp)
{
    // The following is similar to what happens in bmv2 simple_switch egress thread.
    bm::Pipeline* egress_mau = this->get_pipeline("egress");
    bm::Deparser* deparser = this->get_deparser("deparser");

    bm::PHV* phv = packet->get_phv();

    if (phv->has_field("intrinsic_metadata.egress_global_timestamp"))
    {
        phv->get_field("intrinsic_metadata.egress_global_timestamp")
            .set(Simulator::Now().GetNanoSeconds());
    }

    phv->get_field("queueing_metadata.enq_timestamp").set(enq_tstamp);
    phv->get_field("queueing_metadata.enq_qdepth").set(enq_qdepth);

    phv->get_field("queueing_metadata.deq_timedelta")
        .set(Simulator::Now().GetNanoSeconds() - enq_tstamp);

    phv->get_field("queueing_metadata.deq_qdepth").set(deq_qdepth);
    if (phv->has_field("intrinsic_metadata.priority"))
    {
        auto& qid_f = phv->get_field("intrinsic_metadata.priority");
        qid_f.set(qid);
    }

    phv->get_field("standard_metadata.egress_port").set(egress_port);

    bm::Field& f_egress_spec = phv->get_field("standard_metadata.egress_spec");
    f_egress_spec.set(drop_port + 1);

    phv->get_field("standard_metadata.packet_length").set(pkt_len);

    egress_mau->apply(packet.get());

    bm::Field& f_egress_spec_eg = phv->get_field("standard_metadata.egress_spec");
    uint16_t egress_spec_eg = f_egress_spec_eg.get_uint();
    if (egress_spec_eg == drop_port)
    {
        BMLOG_DEBUG_PKT(*packet, "Dropping packet at the end of egress");
        packet.release();

        return 1;
    }
    else
    {
        deparser->deparse(packet.get());

        return 0;
    }
}

void
P4Pipeline::process_multicast(
    std::list<std::tuple<uint16_t, uint16_t, std::unique_ptr<bm::Packet>>>* pkts_to_egress,
    bm::Packet* packet,
    unsigned int mgid)
{
    auto* phv = packet->get_phv();
    auto& f_rid = phv->get_field("intrinsic_metadata.egress_rid");
    const auto pre_out = pre->replicate({mgid});
    for (const auto& out : pre_out)
    {
        auto egress_port = out.egress_port;
        BMLOG_DEBUG_PKT(*packet, "Replicating packet on port {}", egress_port);
        f_rid.set(out.rid);
        std::unique_ptr<bm::Packet> packet_copy = packet->clone_with_phv_ptr();
        pkts_to_egress->push_back(std::make_tuple(egress_port, 1, std::move(packet_copy)));
    }
}

std::unique_ptr<bm::Packet>
P4Pipeline::get_bm_packet(Ptr<const Packet> ns3_packet, uint32_t ingress_port)
{
    int len = ns3_packet->GetSize();

    if (len > MAX_PKT_SIZE)
    {
        BMLOG_DEBUG("Packet length {} exceeds MAX_PKT_SIZE", len);
        std::exit(1);
    }
    ns3_packet->CopyData(ns2bm_buf, len);
    auto bm_packet = new_packet_ptr(ingress_port,
                                    packet_id++,
                                    len,
                                    bm::PacketBuffer(MAX_PKT_SIZE, (char*)(ns2bm_buf), len));

    return bm_packet;
}
} // namespace ns3
