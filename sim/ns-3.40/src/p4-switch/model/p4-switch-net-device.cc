/* -*- Mode:C++; c-file-style:"gnu"; indent-tabs-mode:nil; -*- */
/*
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
 * Author: Mariano Scazzariello <marianos@kth.se>
 */
#include "p4-switch-net-device.h"

#include "ns3/boolean.h"
#include "ns3/channel.h"
#include "ns3/csma-net-device.h"
#include "ns3/ethernet-header.h"
#include "ns3/log.h"
#include "ns3/names.h"
#include "ns3/node.h"
#include "ns3/packet.h"
#include "ns3/simulator.h"
#include "ns3/string.h"
#include "ns3/uinteger.h"

#include <bm/bm_sim/packet.h>
#include <chrono>
#include <thread>

/**
 * \file
 * \ingroup p4-switch
 * ns3::P4SwitchNetDevice implementation.
 */

namespace ns3
{
NS_LOG_COMPONENT_DEFINE("P4SwitchNetDevice");

NS_OBJECT_ENSURE_REGISTERED(P4SwitchNetDevice);

TypeId
P4SwitchNetDevice::GetTypeId()
{
    static TypeId tid =
        TypeId("ns3::P4SwitchNetDevice")
            .SetParent<NetDevice>()
            .SetGroupName("P4Switch")
            .AddConstructor<P4SwitchNetDevice>()
            .AddAttribute(
                "Mtu",
                "The MAC-level Maximum Transmission Unit",
                UintegerValue(1500),
                MakeUintegerAccessor(&P4SwitchNetDevice::SetMtu, &P4SwitchNetDevice::GetMtu),
                MakeUintegerChecker<uint16_t>())
            .AddAttribute("PipelineJson",
                          "The bmv2 JSON file to use",
                          StringValue(""),
                          MakeStringAccessor(&P4SwitchNetDevice::GetPipelineJson,
                                             &P4SwitchNetDevice::SetPipelineJson),
                          MakeStringChecker())
            .AddAttribute("PipelineCommands",
                          "CLI commands to run on the P4 pipeline before starting the simulation",
                          StringValue(""),
                          MakeStringAccessor(&P4SwitchNetDevice::GetPipelineCommands,
                                             &P4SwitchNetDevice::SetPipelineCommands),
                          MakeStringChecker())
            .AddAttribute("PacketDeparser",
                          "Packet deparser class that converts a bmv2 packet into a ns3 packet",
                          PointerValue(nullptr),
                          MakePointerAccessor(&P4SwitchNetDevice::GetPktDeparser,
                                              &P4SwitchNetDevice::SetPktDeparser),
                          MakePointerChecker<P4PacketDeparser>())
            .AddAttribute("SwitchMmu",
                          "Switch MMU instance",
                          PointerValue(nullptr),
                          MakePointerAccessor(&P4SwitchNetDevice::m_mmu),
                          MakePointerChecker<SwitchMmu>());

    return tid;
}

P4SwitchNetDevice::P4SwitchNetDevice()
    : m_node(nullptr),
      m_ifIndex(0)
{
    NS_LOG_FUNCTION_NOARGS();
    m_channel = CreateObject<P4SwitchChannel>();

    m_p4_pipeline = nullptr;
    m_mmu = CreateObject<SwitchMmu>();
}

P4SwitchNetDevice::~P4SwitchNetDevice()
{
    NS_LOG_FUNCTION_NOARGS();
}

void
P4SwitchNetDevice::DoDispose()
{
    NS_LOG_FUNCTION_NOARGS();
    for (std::vector<Ptr<NetDevice>>::iterator iter = m_ports.begin(); iter != m_ports.end();
         iter++)
    {
        *iter = nullptr;
    }
    m_ports.clear();
    m_channel = nullptr;
    m_node = nullptr;
    NetDevice::DoDispose();

    for (size_t p = 0; p < pCnt; ++p)
    {
        Simulator::Cancel(dequeueEvent[p]);

        for (size_t q = 0; q < qCnt; ++q)
        {
            eg_queues[p][q].clear();
        }
    }
}

void
P4SwitchNetDevice::ReceiveFromDevice(Ptr<NetDevice> incomingPort,
                                     Ptr<const Packet> packet,
                                     uint16_t protocol,
                                     const Address& src,
                                     const Address& dst,
                                     PacketType packetType)
{
    NS_LOG_FUNCTION_NOARGS();

    if (m_p4_pipeline == nullptr)
    {
        InitPipeline();
    }

    std::string node_name = Names::FindName(m_node);

    uint32_t port_n = GetPortN(incomingPort);
    uint32_t port_idx = port_n - 1; // port_n starts from 1
    NS_LOG_LOGIC(node_name << " | ReceiveFromDevice port " << port_n
                           << " sending through P4 pipeline");

    // Re-append Ethernet header, removed by CsmaNetDevice
    Ptr<Packet> full_packet = packet->Copy();

    EthernetHeader eth_hdr_in;
    Mac48Address mac_src = Mac48Address::ConvertFrom(src);
    Mac48Address mac_dst = Mac48Address::ConvertFrom(dst);
    eth_hdr_in.SetSource(mac_src);
    eth_hdr_in.SetDestination(mac_dst);
    eth_hdr_in.SetLengthType(protocol);
    full_packet->AddHeader(eth_hdr_in);

    uint32_t pkt_size = full_packet->GetSize();

    // Check if the ingress can admit the packet
    // qIndex=0 is high priority, so we start from 1
    if (!m_mmu->CheckIngressAdmission(port_idx, 1, pkt_size))
    {
        NS_LOG_DEBUG(node_name << " | Port " << port_n
                               << " cannot admit in ingress packet with size=" << pkt_size
                               << ", dropping");

        return;
    }

    // We admitted the packet, now update the ingress admission
    NS_LOG_DEBUG(node_name << " | packet with size=" << pkt_size
                           << " admitted, sending through the ingress pipeline");
    m_mmu->UpdateIngressAdmission(port_idx, 1, pkt_size);
    std::unique_ptr<bm::Packet> pkt = m_p4_pipeline->process_ingress(full_packet, port_n);

    // Remove from ingress admission
    m_mmu->RemoveFromIngressAdmission(port_idx, 1, pkt_size);

    // The TM decides what to do with the processed packet
    std::list<std::pair<uint16_t, std::unique_ptr<bm::Packet>>>* pkts =
        new std::list<std::pair<uint16_t, std::unique_ptr<bm::Packet>>>();

    m_p4_pipeline->process_tm(pkts, std::move(pkt));

    // Enqueue each packet in a different egress queue, by also checking the egress admission
    for (auto& item : *pkts)
    {
        uint16_t outport_n = item.first;
        uint16_t outport_idx = outport_n - 1; // outport_n starts from 1
        std::unique_ptr<bm::Packet> out_pkt = std::move(item.second);

        if (!m_mmu->CheckEgressAdmission(outport_idx, 1, pkt_size))
        {
            NS_LOG_DEBUG(node_name << " | Ouput Port " << outport_n
                                   << " cannot admit in egress packet with size=" << pkt_size
                                   << ", dropping");

            out_pkt.release();

            continue;
        }

        uint64_t eg_bytes_before = m_mmu->GetEgressBytes(outport_idx, 1);

        // We admitted the packet, now update the egress admission
        NS_LOG_DEBUG(node_name << " | packet with size=" << pkt_size << " admitted in port="
                               << outport_n << " (idx=" << outport_idx << "), enqueuing...");
        m_mmu->UpdateEgressAdmission(outport_idx, 1, pkt_size);

        eg_queues[outport_idx][1].emplace_back(std::make_tuple(eg_bytes_before,
                                                              Simulator::Now().GetNanoSeconds(),
                                                              full_packet,
                                                              std::move(out_pkt)));

        NS_LOG_DEBUG(node_name << " | port=" << outport_n << " (idx=" << outport_idx
                               << ") queue=1 current_egress_bytes="
                               << m_mmu->GetEgressBytes(outport_idx, 1));
    }
}

void
P4SwitchNetDevice::DequeueRR(uint32_t p)
{
    std::string node_name = Names::FindName(m_node);

    // Dequeue from the MMU in a Round-Robin fashion
    auto p_queues = eg_queues[p];
    uint32_t rrlast = qIndexLast[p];

    bool found = false;
    uint32_t qIndex;

    if (p_queues[0].size() > 0) // 0 is the highest priority
    {
        found = true;
        qIndex = 0;
    }
    else
    {
        for (qIndex = 1; qIndex <= qCnt; qIndex++)
        {
            if (p_queues[(qIndex + rrlast) % qCnt].size() > 0) // round robin
            {
                found = true;
                break;
            }
        }
        qIndex = (qIndex + rrlast) % qCnt;
    }
    if (found)
    {
        std::tuple<uint64_t, int64_t, Ptr<const Packet>, std::unique_ptr<bm::Packet>>& item =
            p_queues[qIndex].front();
        if (qIndex != 0)
        {
            qIndexLast[p] = qIndex;
        }

        NS_LOG_DEBUG(node_name << " | Popped packet from port=" << p + 1 << " (idx=" << p
                               << ") qIndex=" << qIndex);

        uint32_t pkt_size = std::get<2>(item)->GetSize();

        NS_LOG_DEBUG(node_name << " | sending packet with size=" << pkt_size
                               << " through the egress pipeline");

        m_mmu->RemoveFromEgressAdmission(p, qIndex, pkt_size);

        uint64_t enq_qdepth = std::get<0>(item);
        uint64_t deq_qdepth = m_mmu->GetEgressBytes(p, qIndex);
        int64_t enq_tstamp = std::get<1>(item);
        std::unique_ptr<bm::Packet> tm_pkt = std::move(std::get<3>(item));

        int status = m_p4_pipeline->process_egress(tm_pkt,
                                                   pkt_size,
                                                   p + 1,
                                                   qIndex,
                                                   enq_qdepth,
                                                   deq_qdepth,
                                                   enq_tstamp);

        NS_LOG_DEBUG(node_name << " | port=" << p + 1 << " (idx=" << p
                               << ") queue=1 removed packet, current_egress_bytes="
                               << m_mmu->GetEgressBytes(p, 1));

        if (status == 0)
        {
            DeparseAndSend(p + 1, std::move(tm_pkt), std::get<2>(item));
        }
        else
        {
            NS_LOG_DEBUG(node_name << " | packet dropped in egress pipeline");
        }

        p_queues[qIndex].pop_front();
        tm_pkt.release();
    }

    dequeueEvent[p] = Simulator::Schedule(NanoSeconds(500), &P4SwitchNetDevice::DequeueRR, this, p);
}

void
P4SwitchNetDevice::DeparseAndSend(uint32_t outport_n,
                                  std::unique_ptr<bm::Packet> out_pkt,
                                  Ptr<const Packet> input_pkt)
{
    std::string node_name = Names::FindName(m_node);

    Ptr<Packet> deparsed_pkt = m_pkt_deparser->get_ns3_packet(std::move(out_pkt));

    Ptr<NetDevice> port = GetPort(outport_n);
    if (!port)
    {
        NS_LOG_DEBUG(node_name << " | Port " << outport_n << " not found, dropping packet");
        return;
    }

    // WARNING: out_pkt is a reconstructed Packet in p4-pipeline.
    // We try to infer known headers, but if something is missing you have to add the parsing logic
    // Remove the Ethernet header for the SendFrom
    EthernetHeader eth_hdr_out;
    deparsed_pkt->RemoveHeader(eth_hdr_out);

    // Add again the tags from the original pkt
    ByteTagIterator it = input_pkt->GetByteTagIterator();
    while (it.HasNext())
    {
        ByteTagIterator::Item tag_item = it.Next();
        Callback<ObjectBase*> constructor = tag_item.GetTypeId().GetConstructor();

        Tag* tag = dynamic_cast<Tag*>(constructor());
        NS_ASSERT(tag != nullptr);
        tag_item.GetTag(*tag);

        deparsed_pkt->AddByteTag(*tag);
    }

    PacketTagIterator pit = input_pkt->GetPacketTagIterator();
    while (pit.HasNext())
    {
        PacketTagIterator::Item tag_item = pit.Next();
        Callback<ObjectBase*> constructor = tag_item.GetTypeId().GetConstructor();

        Tag* tag = dynamic_cast<Tag*>(constructor());
        NS_ASSERT(tag != nullptr);
        tag_item.GetTag(*tag);

        deparsed_pkt->AddPacketTag(*tag);
    }

    NS_LOG_DEBUG(node_name << " | Forwarding pkt " << deparsed_pkt << " to port " << outport_n
                           << "                              " << eth_hdr_out.GetDestination()
                           << " " << eth_hdr_out.GetSource() << " " << eth_hdr_out.GetLengthType());

    port->SendFrom(deparsed_pkt,
                   eth_hdr_out.GetSource(),
                   eth_hdr_out.GetDestination(),
                   eth_hdr_out.GetLengthType());
}

void
P4SwitchNetDevice::InitPipeline()
{
    NS_LOG_FUNCTION_NOARGS();

    std::string node_name = Names::FindName(m_node);

    if (m_pkt_deparser == nullptr)
    {
        NS_LOG_ERROR(
            node_name << " Cannot initialize P4 pipeline, packet deparser is not set, abort!");
        std::exit(1);
    }

    if (m_pipeline_json != "")
    {
        NS_LOG_LOGIC(node_name << " Initializing up P4 pipeline...");
        m_p4_pipeline = new P4Pipeline(m_pipeline_json, node_name);
        if (!m_pipeline_commands.empty())
        {
            std::this_thread::sleep_for(std::chrono::seconds(5));
            m_p4_pipeline->run_cli_commands(m_pipeline_commands);
        }
    }
    else
    {
        NS_LOG_ERROR(node_name << " Cannot initialize P4 pipeline, abort!");
        std::exit(1);
    }

    // Start the timers for the MMU
    for (size_t p = 0; p < GetNPorts(); ++p)
    {
        dequeueEvent[p] =
            Simulator::Schedule(NanoSeconds(500), &P4SwitchNetDevice::DequeueRR, this, p);
    }
}

std::string
P4SwitchNetDevice::RunPipelineCommands(std::string commands)
{
    return m_p4_pipeline->run_cli_commands(commands);
}

void
P4SwitchNetDevice::AddPort(Ptr<NetDevice> port)
{
    NS_LOG_FUNCTION_NOARGS();
    NS_ASSERT(port != this);

    // We only support CSMA devices
    Ptr<CsmaNetDevice> port_csma = port->GetObject<CsmaNetDevice>();
    if (!port_csma)
    {
        NS_FATAL_ERROR("Device is not CSMA: cannot be added to P4 switch.");
    }
    if (!port->SupportsSendFrom())
    {
        NS_FATAL_ERROR("Device does not support SendFrom: cannot be added to switch.");
    }
    if (m_address == Mac48Address())
    {
        m_address = Mac48Address::ConvertFrom(port->GetAddress());
    }

    NS_LOG_DEBUG("RegisterProtocolHandler for " << port->GetInstanceTypeId().GetName());
    m_node->RegisterProtocolHandler(MakeCallback(&P4SwitchNetDevice::ReceiveFromDevice, this),
                                    0,
                                    port,
                                    true);
    m_ports.push_back(port);
    m_channel->AddChannel(port->GetChannel());
}

uint32_t
P4SwitchNetDevice::GetNPorts() const
{
    NS_LOG_FUNCTION_NOARGS();
    return m_ports.size();
}

Ptr<NetDevice>
P4SwitchNetDevice::GetPort(uint32_t n) const
{
    NS_LOG_FUNCTION_NOARGS();
    if (n <= 0 || n > GetNPorts())
    {
        return nullptr;
    }

    return m_ports[n - 1];
}

uint32_t
P4SwitchNetDevice::GetPortN(Ptr<NetDevice> port)
{
    uint32_t n = 1;
    for (std::vector<Ptr<NetDevice>>::iterator iter = m_ports.begin(); iter != m_ports.end();
         iter++)
    {
        if (port == *iter)
        {
            return n;
        }

        n++;
    }

    NS_FATAL_ERROR("Port number port " << port << " cannot be found!");
}

std::string
P4SwitchNetDevice::GetPipelineJson() const
{
    NS_LOG_FUNCTION_NOARGS();
    return m_pipeline_json;
}

void
P4SwitchNetDevice::SetPipelineJson(std::string pipeline_json)
{
    NS_LOG_FUNCTION(this << pipeline_json);
    m_pipeline_json = pipeline_json;
}

std::string
P4SwitchNetDevice::GetPipelineCommands() const
{
    NS_LOG_FUNCTION_NOARGS();
    return m_pipeline_commands;
}

void
P4SwitchNetDevice::SetPipelineCommands(std::string pipeline_commands)
{
    NS_LOG_FUNCTION(this << pipeline_commands);
    m_pipeline_commands = pipeline_commands;
}

Ptr<P4PacketDeparser>
P4SwitchNetDevice::GetPktDeparser() const
{
    NS_LOG_FUNCTION_NOARGS();
    return m_pkt_deparser;
}

void
P4SwitchNetDevice::SetPktDeparser(Ptr<P4PacketDeparser> pkt_deparser)
{
    NS_LOG_FUNCTION(this << pkt_deparser);
    m_pkt_deparser = pkt_deparser;
}

void
P4SwitchNetDevice::SetIfIndex(const uint32_t index)
{
    NS_LOG_FUNCTION_NOARGS();
    m_ifIndex = index;
}

uint32_t
P4SwitchNetDevice::GetIfIndex() const
{
    NS_LOG_FUNCTION_NOARGS();
    return m_ifIndex;
}

Ptr<Channel>
P4SwitchNetDevice::GetChannel() const
{
    NS_LOG_FUNCTION_NOARGS();
    return m_channel;
}

void
P4SwitchNetDevice::SetAddress(Address address)
{
    NS_LOG_FUNCTION_NOARGS();
    m_address = Mac48Address::ConvertFrom(address);
}

Address
P4SwitchNetDevice::GetAddress() const
{
    NS_LOG_FUNCTION_NOARGS();
    return m_address;
}

bool
P4SwitchNetDevice::SetMtu(const uint16_t mtu)
{
    NS_LOG_FUNCTION_NOARGS();
    m_mtu = mtu;
    return true;
}

uint16_t
P4SwitchNetDevice::GetMtu() const
{
    NS_LOG_FUNCTION_NOARGS();
    return m_mtu;
}

bool
P4SwitchNetDevice::IsLinkUp() const
{
    NS_LOG_FUNCTION_NOARGS();
    return true;
}

void
P4SwitchNetDevice::AddLinkChangeCallback(Callback<void> callback)
{
    // Unused.
}

bool
P4SwitchNetDevice::IsBroadcast() const
{
    NS_LOG_FUNCTION_NOARGS();
    return true;
}

Address
P4SwitchNetDevice::GetBroadcast() const
{
    NS_LOG_FUNCTION_NOARGS();
    return Mac48Address("ff:ff:ff:ff:ff:ff");
}

bool
P4SwitchNetDevice::IsMulticast() const
{
    NS_LOG_FUNCTION_NOARGS();
    return true;
}

Address
P4SwitchNetDevice::GetMulticast(Ipv4Address multicastGroup) const
{
    NS_LOG_FUNCTION(this << multicastGroup);
    Mac48Address multicast = Mac48Address::GetMulticast(multicastGroup);
    return multicast;
}

bool
P4SwitchNetDevice::IsPointToPoint() const
{
    NS_LOG_FUNCTION_NOARGS();
    return false;
}

bool
P4SwitchNetDevice::IsBridge() const
{
    NS_LOG_FUNCTION_NOARGS();
    return true;
}

bool
P4SwitchNetDevice::Send(Ptr<Packet> packet, const Address& dest, uint16_t protocolNumber)
{
    NS_LOG_FUNCTION_NOARGS();
    return SendFrom(packet, m_address, dest, protocolNumber);
}

bool
P4SwitchNetDevice::SendFrom(Ptr<Packet> packet,
                            const Address& src,
                            const Address& dest,
                            uint16_t protocolNumber)
{
    NS_LOG_FUNCTION_NOARGS();
    return false;
}

Ptr<Node>
P4SwitchNetDevice::GetNode() const
{
    NS_LOG_FUNCTION_NOARGS();
    return m_node;
}

void
P4SwitchNetDevice::SetNode(Ptr<Node> node)
{
    NS_LOG_FUNCTION_NOARGS();
    m_node = node;
}

bool
P4SwitchNetDevice::NeedsArp() const
{
    NS_LOG_FUNCTION_NOARGS();
    return false;
}

void
P4SwitchNetDevice::SetReceiveCallback(NetDevice::ReceiveCallback cb)
{
    NS_LOG_FUNCTION_NOARGS();
    m_rxCallback = cb;
}

void
P4SwitchNetDevice::SetPromiscReceiveCallback(NetDevice::PromiscReceiveCallback cb)
{
    NS_LOG_FUNCTION_NOARGS();
    m_promiscRxCallback = cb;
}

bool
P4SwitchNetDevice::SupportsSendFrom() const
{
    NS_LOG_FUNCTION_NOARGS();
    return false;
}

Address
P4SwitchNetDevice::GetMulticast(Ipv6Address addr) const
{
    NS_LOG_FUNCTION(this << addr);
    return Mac48Address::GetMulticast(addr);
}
} // namespace ns3
