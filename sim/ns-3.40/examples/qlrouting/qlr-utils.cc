#pragma once

#include "qlr-utils.h"

#include "socket-utils.h"
#include "tracer.h"
#include "utils.h"
#include "workload_parser.h"

#include "ns3/applications-module.h"
#include "ns3/core-module.h"
#include "ns3/csma-module.h"
#include "ns3/internet-module.h"
#include "ns3/network-module.h"
#include "ns3/p4-switch-module.h"

#include <filesystem>
#include <fstream>
#include <iostream>
#include <map>
#include <random>
#include <string>

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
            uint64_t color = 1;
            uint64_t egressBytes = p4Device->m_mmu->GetEgressBytes(p, 0);
            if (egressBytes <= colorSlice - 1)
            {
                color = 1;
            }
            else if (egressBytes >= colorSlice && egressBytes <= ((colorSlice * 2) - 1))
            {
                color = 2;
            }
            else if (egressBytes >= (colorSlice * 2) && egressBytes <= ((colorSlice * 3) - 1))
            {
                color = 3;
            }
            else if (egressBytes >= (colorSlice * 3) && egressBytes <= ((colorSlice * 4) - 1))
            {
                color = 4;
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
traceQdepthUpdate(Ptr<P4SwitchNetDevice> p4Device, Ptr<OutputStreamWrapper> qdepthFile)
{
    uint64_t totalBufferSlice = queueBufferSlice[p4Device->GetNode()->GetId()];
    uint64_t colorSlice = (uint64_t)(totalBufferSlice / 4.0f);

    P4Pipeline* pline = p4Device->m_p4_pipeline;
    if (pline != nullptr)
    {
        std::string nodeName = p4Device->GetName();
        for (size_t p = 1; p < p4Device->GetNPorts(); ++p)
        {
            uint64_t egressBytes = p4Device->m_mmu->GetEgressBytes(p, 0);
            *qdepthFile->GetStream()
                << Simulator::Now().GetSeconds() << " " << p + 1 << " " << egressBytes << std::endl;
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
    if (next_hdr == 6){
        p->AddHeader(tcp);
    }
    else if (next_hdr == 17)
        p->AddHeader(udp);

    if (ether_type == 0x0800)
        p->AddHeader(ipv4);

    p->AddHeader(eth);

    return p;
}

Ptr<P4SwitchNetDevice>
configureP4Switch(Ptr<Node> switchNode, std::string commandsPath, P4SwitchHelper switchHelper)
{
    NS_LOG_INFO("Configuring P4 Switch " << Names::FindName(switchNode) << " with commands from "
                                         << commandsPath);
    switchHelper.SetDeviceAttribute("PipelineCommands", StringValue(loadCommands(commandsPath)));
    NetDeviceContainer p4DevContainer = switchHelper.Install(switchNode, getAllDevices(switchNode));
    Ptr<P4SwitchNetDevice> p4Switch = DynamicCast<P4SwitchNetDevice>(p4DevContainer.Get(0));
    p4Switch->m_mmu->SetAlphaIngress(1.0 / 8);
    p4Switch->m_mmu->SetBufferPool(64 * 1024 * 1024);
    p4Switch->m_mmu->SetIngressPool(64 * 1024 * 1024);
    p4Switch->m_mmu->SetAlphaEgress(1.0 / 8);
    p4Switch->m_mmu->SetEgressPool(64 * 1024 * 1024);
    p4Switch->m_mmu->node_id = p4Switch->GetNode()->GetId();
    computeQueueBufferSlice(p4Switch);

    Simulator::Schedule(MicroSeconds(0), &updateQdepth, p4Switch);

    return p4Switch;
}

std::pair<NodeContainer, NodeContainer>
createTopology(const std::vector<std::pair<int, int>> edges,
               std::vector<int> hostsVector,
               uint16_t numNodes,
               std::string switchBandwidth,
               std::string hostBandwidth,
               bool dumpTraffic,
               std::string resultsPath,
               std::map<Ptr<Node>, Ptr<P4SwitchNetDevice>>& p4SwitchMap)
{
    NS_LOG_INFO("Creating topology with parameters:");
    NS_LOG_INFO("Number of nodes: " << numNodes);
    NS_LOG_INFO("Switch bandwidth: " << switchBandwidth);
    NS_LOG_INFO("Host bandwidth: " << hostBandwidth);
    NS_LOG_INFO("Dump traffic: " << (dumpTraffic ? "true" : "false"));
    NS_LOG_INFO("Results path: " << resultsPath);

    // Log edges
    std::ostringstream edgesStr;
    edgesStr << "Edges: ";
    for (const auto& edge : edges)
    {
        edgesStr << "(" << edge.first << "," << edge.second << ") ";
    }
    NS_LOG_INFO(edgesStr.str());

    // Log hosts vector
    std::ostringstream hostsStr;
    hostsStr << "Hosts vector: ";
    for (int host : hostsVector)
    {
        hostsStr << host << " ";
    }
    NS_LOG_INFO(hostsStr.str());

    NodeContainer switches;
    switches.Create(numNodes);

    std::map<uint32_t, NetDeviceContainer> switchInterfaces = {};

    for (uint32_t i = 0; i < numNodes; i++)
    {
        std::string switchName = "s" + std::to_string(i + 1);
        Names::Add(switchName, switches.Get(i));
    }

    NodeContainer hosts = addHosts(switches, hostsVector, hostBandwidth, dumpTraffic, resultsPath);

    CsmaHelper csma;
    csma.SetChannelAttribute("DataRate", StringValue(switchBandwidth));
    csma.SetChannelAttribute("Delay", TimeValue(MicroSeconds(10)));
    csma.SetDeviceAttribute("Mtu", UintegerValue(1500));

    for (const auto& edge : edges)
    {
        NetDeviceContainer link =
            csma.Install(NodeContainer(switches.Get(edge.first), switches.Get(edge.second)));
        switchInterfaces[edge.first].Add(link.Get(0));
        switchInterfaces[edge.second].Add(link.Get(1));
    }

    P4SwitchHelper qlrHelper;
    qlrHelper.SetDeviceAttribute("PipelineJson",
                                 StringValue("examples/qlrouting/qlr_build/qlr.json"));
    qlrHelper.SetDeviceAttribute("PacketDeparser", PointerValue(CreateObject<QLRDeparser>()));

    for (uint32_t i = 0; i < numNodes; i++)
    {
        std::string commandsPath = "examples/qlrouting/resources/" +
                                   std::to_string(numNodes) + "_nodes/commands/s" +
                                   std::to_string(i + 1) + ".txt";
        Ptr<Node> switchNode = switches.Get(i);

        Ptr<P4SwitchNetDevice> p4Switch = configureP4Switch(switchNode, commandsPath, qlrHelper);
        traceQdepth(p4Switch,
                    getPath(resultsPath, "qdepth/" + Names::FindName(switchNode) + ".txt"));
    }

    if (dumpTraffic)
    {
        std::string tracesPath = getPath(resultsPath, "traces/dump");
        std::filesystem::create_directories(tracesPath);
        csma.EnablePcapAll(tracesPath, true);
    }

    return {switches, hosts};
}

std::map<Ptr<Node>, uint32_t> nodeToNextTcpSocketIndex;

void
startTcpFlow(Ptr<Node> receiverHost,
             uint16_t addressIndex,
             Ptr<Node> senderHost,
             uint16_t port,
             float startTime,
             uint32_t flowDataSize,
             std::string resultsPath,
             std::string congestionControl)
{
    Ptr<Ipv4> receiverHostIpv4 = receiverHost->GetObject<Ipv4>();

    ApplicationContainer hostSenderApp =
        createTcpApplication(receiverHostIpv4->GetAddress(1, addressIndex).GetAddress(),
                             port,
                             senderHost,
                             flowDataSize,
                             congestionControl);
    hostSenderApp.Start(Seconds(startTime));

    if (nodeToNextTcpSocketIndex.find(senderHost) == nodeToNextTcpSocketIndex.end())
    {
        nodeToNextTcpSocketIndex[senderHost] = 1;
    }
    uint32_t socketIndex = nodeToNextTcpSocketIndex[senderHost];
    nodeToNextTcpSocketIndex[senderHost] = socketIndex + 1;

    std::string fileName = Names::FindName(senderHost) + "-" + Names::FindName(receiverHost) + "-" +
                           std::to_string(port);

    std::string retransmissionPath =
        getPath(getPath(resultsPath, "retransmissions"), fileName + ".rtx");
    NS_LOG_INFO("Starting TCP Retransmission tracking for " + Names::FindName(senderHost) + " -> " +
                Names::FindName(receiverHost) + " on port " + std::to_string(port) +
                " with socket index " + std::to_string(socketIndex) + " saving to " +
                retransmissionPath);

    Simulator::Schedule(Seconds(startTime + 0.2),
                        &startTcpRtx,
                        senderHost,
                        retransmissionPath,
                        socketIndex);

    std::string cwndPath = getPath(getPath(resultsPath, "cwnd"), fileName + ".cwnd");

    NS_LOG_INFO("Starting CWND tracking for " + Names::FindName(senderHost) + " -> " +
                Names::FindName(receiverHost) + " on port " + std::to_string(port) +
                " with socket index " + std::to_string(socketIndex) + " saving to " + cwndPath);
    ;
    Simulator::Schedule(Seconds(startTime + 0.2),
                        &TraceCwnd,
                        cwndPath,
                        senderHost->GetId(),
                        socketIndex);
}

void
startUdpFlow(Ptr<Node> receiverHost,
             uint16_t addressIndex,
             Ptr<Node> senderHost,
             uint16_t port,
             std::string rate,
             uint32_t packetSize,
             float start_time,
             float end_time,
             float burstDataSize)
{
    Ptr<Ipv4> receiverHostIpv4 = receiverHost->GetObject<Ipv4>();

    Ipv4Address dst_addr = receiverHostIpv4->GetAddress(1, addressIndex).GetAddress();

    NS_LOG_INFO("Starting UDP flow from " << Names::FindName(senderHost) << " to " << dst_addr
                                          << " on port " << std::to_string(port) << " rate " << rate
                                          << " start " << std::to_string(start_time) << " end "
                                          << std::to_string(end_time) << " dataSize "
                                          << burstDataSize);

    ApplicationContainer hostSenderApp =
        createUdpApplication(dst_addr, port, senderHost, rate, packetSize, burstDataSize);
    hostSenderApp.Start(Seconds(start_time));
    if (end_time > 0)
        hostSenderApp.Stop(Seconds(end_time));
}

NodeContainer
addHosts(NodeContainer switches,
         const std::vector<int> hostsVector,
         std::string hostBandwidth,
         bool dumpTraffic,
         std::string resultsPath)
{
    NodeContainer hosts;
    hosts.Create(hostsVector.size());

    std::map<uint32_t, NetDeviceContainer> hostInterfaces = {};

    CsmaHelper csma_host;
    csma_host.SetChannelAttribute("DataRate", StringValue(hostBandwidth));
    csma_host.SetChannelAttribute("Delay", TimeValue(MicroSeconds(10)));
    csma_host.SetDeviceAttribute("Mtu", UintegerValue(1500));

    for (uint32_t i = 0; i < hostsVector.size(); i++)
    {
        if (hostsVector[i] == 1)
        {
            Ptr<Node> host = hosts.Get(i);
            Names::Add("host" + std::to_string(i + 1), host);

            Ptr<Node> switchNode = switches.Get(i);

            NetDeviceContainer link = csma_host.Install(NodeContainer(host, switchNode));
            hostInterfaces[i].Add(link.Get(0));
            // switchInterfaces[i].Add(link.Get(1));
        }
    }

    InternetStackHelper hostStack;
    hostStack.SetIpv4StackInstall(true);
    hostStack.SetIpv6StackInstall(false);
    hostStack.Install(hosts);

    for (uint32_t i = 0; i < hostsVector.size(); i++)
    {
        NS_LOG_DEBUG("Configuring host " << Names::FindName(hosts.Get(i)));
        if (hostsVector[i] == 1)
        {
            Ptr<Node> host = hosts.Get(i);

            Ipv4AddressHelper hostIpv4Helper;
            std::string ipAddress = "10.0." + std::to_string(i + 1) + ".0";
            NS_LOG_DEBUG("Assigning IP " << ipAddress << ".1/24 to " << Names::FindName(host));
            hostIpv4Helper.SetBase(Ipv4Address(ipAddress.c_str()), Ipv4Mask("/24"));
            hostIpv4Helper.Assign(hostInterfaces[i]);
        }
    }

    for (uint32_t i = 0; i < hostsVector.size(); i++)
    {
        for (uint32_t j = 0; j < hostsVector.size(); j++)
        {
            if (i == j)
                continue;

            Ptr<Ipv4Interface> hostIpv4Interface = getIpv4Interface(hostInterfaces[i].Get(0));
            Ptr<Ipv4Interface> destinationIpv4Interface =
                getIpv4Interface(hostInterfaces[j].Get(0));
            addArpEntriesFromInterfaceAddresses(hostIpv4Interface, destinationIpv4Interface);
        }
    }

    if (dumpTraffic)
    {
        std::string tracesPath = getPath(resultsPath, "traces/dump");
        NS_LOG_INFO("Dumping host traffic in " << tracesPath);
        std::filesystem::create_directories(tracesPath);
        csma_host.EnablePcapAll(tracesPath, true);
    }

    return hosts;
}

void
logBulkSendThroughput(ApplicationContainer sinks, Ptr<OutputStreamWrapper> outFile)
{
    double time = Simulator::Now().GetSeconds();

    Ptr<PacketSink> sink = DynamicCast<PacketSink>(sinks.Get(0));
    if (sink && outFile)
    {
        uint64_t bytes = sink->GetTotalRx();
        *outFile->GetStream() << time << " " << bytes << std::endl;
        outFile->GetStream()->flush();
    }

    Simulator::Schedule(Seconds(1.0), &logBulkSendThroughput, sinks, outFile);
}

void
generateWorkloadFromFile(NodeContainer hosts,
                         std::string workloadFilePath,
                         std::string congestionControl,
                         std::string resultsPath)
{
    auto workloads = WorkloadParser::parseFile(workloadFilePath);

    uint16_t qlrPort = 22222;
    uint16_t defaultPort = 20000;
    AsciiTraceHelper ascii;
    for (uint16_t i = 0; i < hosts.GetN(); i++)
    {
        Ptr<Node> host = hosts.Get(i);
        ApplicationContainer hostReceiverApp = createSinkTcpApplication(qlrPort, host);
        hostReceiverApp.Start(Seconds(0.0));
        ApplicationContainer defaultHostReceiverApp = createSinkUdpApplication(defaultPort, host);
        defaultHostReceiverApp.Start(Seconds(0.0));
    }

    for (const auto& wl : workloads)
    {
        Ptr<Node> senderHost = hosts.Get(wl.sourceId);
        Ptr<Node> receiverHost = hosts.Get(wl.destinationId);
        if (wl.protocol == 6)
        {
            for (uint32_t f = 0; f < wl.flowsNumber; f++)
            {
                startTcpFlow(receiverHost,
                             0,
                             senderHost,
                             wl.dstPort,
                             wl.startTime,
                             wl.dataSize,
                             resultsPath,
                             congestionControl);
            }
        }
        else if (wl.protocol == 17)
        {
            for (uint32_t f = 0; f < wl.flowsNumber; f++)
            {
                startUdpFlow(receiverHost,
                             0,
                             senderHost,
                             wl.dstPort,
                             wl.dataRate,
                             wl.packetSize,
                             wl.startTime,
                             wl.endTime,
                             wl.dataSize);
            }
        }
        else
        {
            NS_LOG_ERROR("Unknown protocol " << wl.protocol << " in workload file.");
        }
    }
}

