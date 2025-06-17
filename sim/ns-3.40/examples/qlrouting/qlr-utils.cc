#pragma once
#include "qlr-utils.h"

#include "ns3/core-module.h"
#include "ns3/internet-module.h"
#include "ns3/network-module.h"
#include "ns3/p4-switch-module.h"

#include <map>

using namespace ns3;

NS_LOG_COMPONENT_DEFINE("qlr-utils");

std::map<uint32_t, uint64_t> queueBufferSlice;

void
computeQueueBufferSlice(Ptr<P4SwitchNetDevice> p4Device)
{
    queueBufferSlice[p4Device->GetNode()->GetId()] =
        p4Device->m_mmu->DynamicThreshold(0, 0, "egress");
}

void
updateQdepth(Ptr<P4SwitchNetDevice> p4Device)
{
    uint64_t totalBufferSlice = queueBufferSlice[p4Device->GetNode()->GetId()];
    uint64_t colorSlice = (uint64_t)(totalBufferSlice / 4.0f);

    P4Pipeline* pline = p4Device->m_p4_pipeline;
    if (pline != nullptr)
    {
        std::string nodeName = p4Device->GetName();
        for (size_t p = 1; p < p4Device->GetNPorts(); ++p)
        {
            uint64_t color = 0;
            uint64_t egressBytes = p4Device->m_mmu->GetEgressBytes(p, 0);
            if (egressBytes <= colorSlice - 1)
            {
                color = 0;
            }
            else if (egressBytes >= colorSlice && egressBytes <= ((colorSlice * 2) - 1))
            {
                color = 1;
            }
            else if (egressBytes >= (colorSlice * 2) && egressBytes <= ((colorSlice * 3) - 1))
            {
                color = 2;
            }
            else if (egressBytes >= (colorSlice * 3) && egressBytes <= ((colorSlice * 4) - 1))
            {
                color = 3;
            }

            if (color != p4Device->m_mmu->colorEgress[p][0])
            {
                NS_LOG_INFO("Node: " << nodeName << " Port: " << p + 1
                                     << " Egress Bytes: " << egressBytes << " Color: " << color);
                p4Device->m_mmu->colorEgress[p][0] = color;
            }
            pline->register_write(0, "IngressPipe.ig_qdepths", p, bm::Data(color));
        }
    }

    Simulator::Schedule(NanoSeconds(200), &updateQdepth, p4Device);
}

void 
traceQdepthUpdate(Ptr<P4SwitchNetDevice> p4Device, Ptr<OutputStreamWrapper> qdepthFile){
    uint64_t totalBufferSlice = queueBufferSlice[p4Device->GetNode()->GetId()];
    uint64_t colorSlice = (uint64_t)(totalBufferSlice / 4.0f);

    P4Pipeline* pline = p4Device->m_p4_pipeline;
    if (pline != nullptr)
    {
        std::string nodeName = p4Device->GetName();
        for (size_t p = 1; p < p4Device->GetNPorts(); ++p)
        {
            
            uint64_t egressBytes = p4Device->m_mmu->GetEgressBytes(p, 0);
            *qdepthFile ->GetStream() << Simulator::Now().GetSeconds() << " " << p + 1 << " " << egressBytes << std::endl;
            *qdepthFile->GetStream() << std::flush;
        }
    }

    Simulator::Schedule(Seconds(0.1), &traceQdepthUpdate, p4Device, qdepthFile);
}

void
traceQdepth(Ptr<P4SwitchNetDevice> p4Device, std::string fileName)
{
    AsciiTraceHelper ascii;
    Ptr<OutputStreamWrapper> qdepthFile = ascii.CreateFileStream(fileName);

    Simulator::Schedule(NanoSeconds(200), &traceQdepthUpdate, p4Device, qdepthFile);
}

Ptr<Packet>
QLRDeparser::get_ns3_packet(std::unique_ptr<bm::Packet> bm_packet)
{
    uint8_t* bm_buf = (uint8_t*)bm_packet.get()->data();
    size_t len = bm_packet.get()->get_data_size();

    Buffer b;
    b.AddAtStart(len);
    b.Begin().Write(bm_buf, len);

    Buffer::Iterator it = b.Begin();
    EthernetHeader eth;
    eth.Deserialize(it);
    it.Next(eth.GetSerializedSize());
    size_t offset = eth.GetSerializedSize();

    uint16_t ether_type = eth.GetLengthType();

    Ipv4Header ipv4;
    TcpHeader tcp;
    UdpHeader udp;
    uint8_t next_hdr = 0;
    if (ether_type == 0x0800)
    {
        ipv4.Deserialize(it);
        it.Next(ipv4.GetSerializedSize());
        offset += ipv4.GetSerializedSize();

        next_hdr = ipv4.GetProtocol();
    }

    if (next_hdr == 6)
    {
        tcp.Deserialize(it);
        it.Next(tcp.GetSerializedSize());
        offset += tcp.GetSerializedSize();
    }
    else if (next_hdr == 17)
    {
        udp.Deserialize(it);
        it.Next(udp.GetSerializedSize());
        offset += udp.GetSerializedSize();
    }

    Ptr<Packet> p = Create<Packet>(bm_buf + offset, len - offset);
    /* Headers are added in reverse order */
    if (next_hdr == 6)
        p->AddHeader(tcp);
    else if (next_hdr == 17)
        p->AddHeader(udp);

    if (ether_type == 0x0800)
        p->AddHeader(ipv4);

    p->AddHeader(eth);

    return p;
}