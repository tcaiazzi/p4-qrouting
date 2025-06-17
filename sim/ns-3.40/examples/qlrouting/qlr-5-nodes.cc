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
 */
#include "ns3/applications-module.h"
#include "ns3/core-module.h"
#include "ns3/csma-module.h"
#include "ns3/error-model.h"
#include "ns3/flow-monitor-helper.h"
#include "ns3/flow-monitor-module.h"
#include "ns3/internet-module.h"
#include "ns3/network-module.h"
#include "ns3/p4-switch-module.h"

#include <filesystem>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <random>
#include <string>

#include "tracer.h"
#include "socket-utils.h"
#include "qlr-utils.h"
#include "utils.h"

using namespace ns3;

NS_LOG_COMPONENT_DEFINE("QLRoutingExample");

bool verbose = false;

uint32_t seed = 10;
std::mt19937 randomGen;

std::string resultsPath = "examples/qlrouting/results/5-nodes";

std::map<Ptr<Node>, uint32_t> nodeToNextTcpSocketIndex;

void
startTcpFlow(Ptr<Node> receiverHost,
             std::vector<Ptr<Ipv4Interface>> receiverInterfaces,
             Ptr<Node> senderHost,
             uint16_t port,
             std::string activeRateTcp,
             uint32_t tcpDataSize,
             std::string congestionControl = "TcpLinuxReno",
             float startTime = 1.0f)
{
    // ApplicationContainer hostReceiverApp = createSinkTcpApplication(port, receiverHost);
    // hostReceiverApp.Start(Seconds(0.0));

    ApplicationContainer hostSenderApp =
        createTcpApplication(receiverInterfaces[0]->GetAddress(0).GetAddress(),
                             port,
                             senderHost,
                             activeRateTcp,
                             tcpDataSize,
                             congestionControl);
    hostSenderApp.Start(Seconds(startTime));

    Ptr<BulkSendApplication> bulkApp = DynamicCast<BulkSendApplication>(hostSenderApp.Get(0));

    Ptr<Socket> socket = bulkApp->GetSocket();

    Ptr<TcpL4Protocol> tcp = senderHost->GetObject<TcpL4Protocol>();
    if (nodeToNextTcpSocketIndex.find(senderHost) == nodeToNextTcpSocketIndex.end())
    {
        nodeToNextTcpSocketIndex[senderHost] = 1;
    }
    uint32_t socketIndex = nodeToNextTcpSocketIndex[senderHost];
    nodeToNextTcpSocketIndex[senderHost] = socketIndex + 1;

    NS_LOG_INFO("Starting TCP Retransmission tracking for " + Names::FindName(senderHost) + " -> " +
                Names::FindName(receiverHost) + " on port " + std::to_string(port) +
                " with socket index " + std::to_string(socketIndex));
    std::string fileName = Names::FindName(senderHost) + "-" + Names::FindName(receiverHost) + "-" +
                           std::to_string(port);
    
    std::string retransmissionPath = getPath(getPath(resultsPath, "retransmissions"), fileName + ".rtx");
    Simulator::Schedule(Seconds(startTime + 0.1),
                        &startTcpRtx,
                        senderHost,
                        retransmissionPath,
                        socketIndex);

    std::string cwndPath = getPath(getPath(resultsPath, "cwnd"), fileName + ".cwnd");
        Simulator::Schedule(Seconds(startTime + 0.1),
                            &TraceCwnd,
                            cwndPath,
                            senderHost->GetId(),
                            socketIndex);

    std::string throughputFileName = Names::FindName(senderHost) + ".tp";
    std::string throughputPath = getPath(getPath(resultsPath, "throughput"), throughputFileName);
    Simulator::Schedule(Seconds(startTime + 0.1),
                        &startThroughputTrace,
                        throughputPath,
                        senderHost->GetId(),
                        0);
}

void
startUdpFlow(Ptr<Node> receiverHost,
             std::vector<Ptr<Ipv4Interface>> receiverInterfaces,
             Ptr<Node> senderHost,
             uint16_t port,
             std::string backupRateUdp,
             uint32_t start_time,
             uint32_t end_time,
             uint32_t udpDataSize,
             bool generateRandom)
{
    ApplicationContainer hostReceiverApp = createSinkUdpApplication(port, receiverHost);
    hostReceiverApp.Start(Seconds(0.0));

    ApplicationContainer hostSenderApp =
        createUdpApplication(receiverInterfaces[0]->GetAddress(0).GetAddress(),
                             port,
                             senderHost,
                             backupRateUdp,
                             udpDataSize);
    hostSenderApp.Start(Seconds(start_time));
    hostSenderApp.Stop(Seconds(end_time + 1.0));
}

int
main(int argc, char* argv[])

{
    uint32_t activeFlows = 1;
    uint32_t backupFlows = 1;
    bool generateRandom = false;
    std::string defaultBandwidth = "50Kbps";
    std::string resultName = "flow_monitor.xml";
    float flowEndTime = 11.0f;
    float endTime = 20.0f;
    float udpStartTime = 1.0f;
    float udpEndTime = 10.0f;
    float tcpStartTime = 1.0f;
    float tcpEndTime = 1.0f;
    std::string activeRateTcp = "50Kbps";
    std::string backupRateUdp = "50Kbps";
    std::string congestionControl = "TcpLinuxReno";
    uint32_t tcpDataSize = 150000000;
    uint32_t udpDataSize = 150000000;
    bool dumpTraffic = false;

    // Packet::EnablePrinting();

    CommandLine cmd;
    cmd.AddValue("results-path", "The path where to save results", resultsPath);
    cmd.AddValue("fm-name", "The name of the flow monitor result", resultName);
    cmd.AddValue("active-flows", "The number of concurrent flows on the active path", activeFlows);
    cmd.AddValue("backup-flows", "The number of concurrent flows on the backup path", backupFlows);
    cmd.AddValue("udp-random",
                 "Select whether UDP flows are randomly distributed.",
                 generateRandom);
    cmd.AddValue("udp-start-time", "The time to start UDP flows", udpStartTime);
    cmd.AddValue("udp-end-time", "The time to stop UDP flows", udpEndTime);
    cmd.AddValue("tcp-start-time", "The time to start UDP flows", tcpStartTime);
    cmd.AddValue("tcp-end-time", "The time to stop UDP flows", tcpEndTime);
    cmd.AddValue("default-bw",
                 "The bandwidth to set on all the sender/receiver links",
                 defaultBandwidth);
    cmd.AddValue("active-rate-tcp", "The TCP rate to set to the active flows", activeRateTcp);
    cmd.AddValue("backup-rate-udp", "The UDP rate to set to the backup flows", backupRateUdp);
    cmd.AddValue("flow-end", "Flows End Time", flowEndTime);
    cmd.AddValue("tcp-data-size", "Size of the data sent by TCP applications", tcpDataSize);
    cmd.AddValue("udp-data-size", "Size of the data sent by TCP applications", udpDataSize);
    cmd.AddValue("dump-traffic", "Dump traffic traces", dumpTraffic);
    cmd.AddValue("cc", "The TCP congestion control used for the experiment", congestionControl);

    cmd.AddValue("end", "Simulation End Time", endTime);
    cmd.AddValue("verbose", "Verbose output", verbose);

    cmd.Parse(argc, argv);

    LogComponentEnable("QLRoutingExample", LOG_LEVEL_INFO);
    // if (verbose)
    {
        // LogComponentEnable("FlowMonitor", LOG_LEVEL_DEBUG);
        // LogComponentEnable("P4SwitchNetDevice", LOG_LEVEL_WARN);
        // LogComponentEnable("SwitchMmu", LOG_LEVEL_DEBUG);
        // LogComponentEnable("P4Pipeline", LOG_LEVEL_DEBUG);
        // LogComponentEnable("TcpSocketBase", LOG_LEVEL_DEBUG);
    }

    NS_LOG_INFO("#### RUN PARAMETERS ####");
    NS_LOG_INFO("Results Path: " + resultsPath);
    NS_LOG_INFO("FLow Monitor Name: " + resultName);
    NS_LOG_INFO("Congestion Control: " + congestionControl);
    NS_LOG_INFO("Flow End Time: " + std::to_string(flowEndTime));
    NS_LOG_INFO("End Time: " + std::to_string(endTime));
    NS_LOG_INFO("Backup Rate UDP: " + backupRateUdp);
    NS_LOG_INFO("Data Size UDP: " + std::to_string(udpDataSize));

    NS_LOG_INFO("Configuring Congestion Control.");
    Config::SetDefault("ns3::TcpL4Protocol::SocketType", StringValue("ns3::" + congestionControl));
    Config::SetDefault("ns3::TcpSocket::SndBufSize", UintegerValue(2 << 17));
    Config::SetDefault("ns3::TcpSocket::RcvBufSize", UintegerValue(2 << 17));
    Config::SetDefault("ns3::TcpSocket::InitialCwnd", UintegerValue(10));
    Config::SetDefault("ns3::TcpSocket::DelAckCount", UintegerValue(2));
    Config::SetDefault("ns3::TcpSocket::SegmentSize", UintegerValue(1400));

    std::filesystem::create_directories(resultsPath);
    std::filesystem::create_directories(getPath(resultsPath, "cwnd"));
    std::filesystem::create_directories(getPath(resultsPath, "throughput"));
    std::filesystem::create_directories(getPath(resultsPath, "retransmissions"));

    randomGen = std::mt19937(seed);

    NodeContainer hosts;
    hosts.Create(5);

    NodeContainer switches;
    switches.Create(5);

    Ptr<Node> s1 = switches.Get(0);
    Names::Add("s1", s1);

    Ptr<Node> s2 = switches.Get(1);
    Names::Add("s2", s2);

    Ptr<Node> s3 = switches.Get(2);
    Names::Add("s3", s3);

    Ptr<Node> s4 = switches.Get(3);
    Names::Add("s4", s4);

    Ptr<Node> s5 = switches.Get(4);
    Names::Add("s5", s5);

    Ptr<Node> host1 = hosts.Get(0);
    Names::Add("host1", host1);

    Ptr<Node> host2 = hosts.Get(1);
    Names::Add("host2", host2);

    Ptr<Node> host3 = hosts.Get(2);
    Names::Add("host3", host3);

    Ptr<Node> host4 = hosts.Get(3);
    Names::Add("host4", host4);

    Ptr<Node> host5 = hosts.Get(4);
    Names::Add("host5", host5);

    CsmaHelper csma_sw;
    csma_sw.SetChannelAttribute("DataRate", StringValue(defaultBandwidth));
    csma_sw.SetDeviceAttribute("Mtu", UintegerValue(1500));
    // csma_sw.SetQueue("ns3::DropTailQueue", "MaxSize", StringValue(defaultBuffer));

    CsmaHelper csma_host;
    csma_host.SetChannelAttribute("DataRate", StringValue("1000Gbps"));
    csma_host.SetDeviceAttribute("Mtu", UintegerValue(1500));

    NetDeviceContainer host1Interfaces;
    NetDeviceContainer host2Interfaces;
    NetDeviceContainer host3Interfaces;
    NetDeviceContainer host4Interfaces;
    NetDeviceContainer host5Interfaces;
    NetDeviceContainer s1Interfaces;
    NetDeviceContainer s2Interfaces;
    NetDeviceContainer s3Interfaces;
    NetDeviceContainer s4Interfaces;
    NetDeviceContainer s5Interfaces;

    NetDeviceContainer link;
    link = csma_host.Install(NodeContainer(host1, s1));
    host1Interfaces.Add(link.Get(0));
    s1Interfaces.Add(link.Get(1));

    link = csma_host.Install(NodeContainer(host2, s2));
    host2Interfaces.Add(link.Get(0));
    s2Interfaces.Add(link.Get(1));

    link = csma_host.Install(NodeContainer(host3, s3));
    host3Interfaces.Add(link.Get(0));
    s3Interfaces.Add(link.Get(1));

    link = csma_host.Install(NodeContainer(host4, s4));
    host4Interfaces.Add(link.Get(0));
    s4Interfaces.Add(link.Get(1));

    link = csma_host.Install(NodeContainer(host5, s5));
    host5Interfaces.Add(link.Get(0));
    s5Interfaces.Add(link.Get(1));

    link = csma_sw.Install(NodeContainer(s1, s2));
    s1Interfaces.Add(link.Get(0));
    s2Interfaces.Add(link.Get(1));

    link = csma_sw.Install(NodeContainer(s1, s3));
    s1Interfaces.Add(link.Get(0));
    s3Interfaces.Add(link.Get(1));

    link = csma_sw.Install(NodeContainer(s2, s3));
    s2Interfaces.Add(link.Get(0));
    s3Interfaces.Add(link.Get(1));

    link = csma_sw.Install(NodeContainer(s2, s4));
    s2Interfaces.Add(link.Get(0));
    s4Interfaces.Add(link.Get(1));

    link = csma_sw.Install(NodeContainer(s3, s4));
    s3Interfaces.Add(link.Get(0));
    s4Interfaces.Add(link.Get(1));

    link = csma_sw.Install(NodeContainer(s3, s5));
    s3Interfaces.Add(link.Get(0));
    s5Interfaces.Add(link.Get(1));

    link = csma_sw.Install(NodeContainer(s4, s5));
    s4Interfaces.Add(link.Get(0));
    s5Interfaces.Add(link.Get(1));

    Ptr<RateErrorModel> em = CreateObject<RateErrorModel>();
    em->SetAttribute("ErrorRate", DoubleValue(0.01)); // 1% packet loss
    em->SetAttribute("ErrorUnit", StringValue("ERROR_UNIT_PACKET"));

    host1Interfaces.Get(0)->SetAttribute("ReceiveErrorModel", PointerValue(em));

    InternetStackHelper inetStack;
    inetStack.SetIpv4StackInstall(true);
    inetStack.SetIpv6StackInstall(false);
    inetStack.Install(hosts);

    Ipv4AddressHelper host1Ipv4Helper;
    host1Ipv4Helper.SetBase(Ipv4Address("10.0.1.0"), Ipv4Mask("/24"));
    host1Ipv4Helper.Assign(host1Interfaces);

    Ipv4AddressHelper host2Ipv4Helper;
    host2Ipv4Helper.SetBase(Ipv4Address("10.0.2.0"), Ipv4Mask("/24"));
    host2Ipv4Helper.Assign(host2Interfaces);

    Ipv4AddressHelper host3Ipv4Helper;
    host3Ipv4Helper.SetBase(Ipv4Address("10.0.3.0"), Ipv4Mask("/24"));
    host3Ipv4Helper.Assign(host3Interfaces);

    Ipv4AddressHelper host4Ipv4Helper;
    host4Ipv4Helper.SetBase(Ipv4Address("10.0.4.0"), Ipv4Mask("/24"));
    host4Ipv4Helper.Assign(host4Interfaces);

    Ipv4AddressHelper host5Ipv4Helper;
    host5Ipv4Helper.SetBase(Ipv4Address("10.0.5.0"), Ipv4Mask("/24"));
    host5Ipv4Helper.Assign(host5Interfaces);

    std::vector<Ptr<Ipv4Interface>> host1Ipv4Interfaces;
    std::vector<Ptr<Ipv4Interface>> host2Ipv4Interfaces;
    std::vector<Ptr<Ipv4Interface>> host3Ipv4Interfaces;
    std::vector<Ptr<Ipv4Interface>> host4Ipv4Interfaces;
    std::vector<Ptr<Ipv4Interface>> host5Ipv4Interfaces;

    Ptr<Ipv4Interface> host1Ipv4Interface = getIpv4Interface(host1Interfaces.Get(0));
    addIpv4Address(host1Ipv4Interface, &host1Ipv4Helper);
    host1Ipv4Interfaces.push_back(host1Ipv4Interface);

    Ptr<Ipv4Interface> host2Ipv4Interface = getIpv4Interface(host2Interfaces.Get(0));
    addIpv4Address(host2Ipv4Interface, &host2Ipv4Helper);
    host2Ipv4Interfaces.push_back(host2Ipv4Interface);

    Ptr<Ipv4Interface> host3Ipv4Interface = getIpv4Interface(host3Interfaces.Get(0));
    addIpv4Address(host3Ipv4Interface, &host3Ipv4Helper);
    host3Ipv4Interfaces.push_back(host3Ipv4Interface);

    Ptr<Ipv4Interface> host4Ipv4Interface = getIpv4Interface(host4Interfaces.Get(0));
    addIpv4Address(host4Ipv4Interface, &host4Ipv4Helper);
    host4Ipv4Interfaces.push_back(host4Ipv4Interface);

    Ptr<Ipv4Interface> host5Ipv4Interface = getIpv4Interface(host5Interfaces.Get(0));
    addIpv4Address(host5Ipv4Interface, &host5Ipv4Helper);
    host5Ipv4Interfaces.push_back(host5Ipv4Interface);

    // Add arp entries for the hosts
    addArpEntriesFromInterfaceAddresses(host1Ipv4Interface, host2Ipv4Interface);
    addArpEntriesFromInterfaceAddresses(host2Ipv4Interface, host1Ipv4Interface);

    addArpEntriesFromInterfaceAddresses(host1Ipv4Interface, host3Ipv4Interface);
    addArpEntriesFromInterfaceAddresses(host3Ipv4Interface, host1Ipv4Interface);

    addArpEntriesFromInterfaceAddresses(host1Ipv4Interface, host4Ipv4Interface);
    addArpEntriesFromInterfaceAddresses(host4Ipv4Interface, host1Ipv4Interface);

    addArpEntriesFromInterfaceAddresses(host1Ipv4Interface, host5Ipv4Interface);
    addArpEntriesFromInterfaceAddresses(host5Ipv4Interface, host1Ipv4Interface);

    addArpEntriesFromInterfaceAddresses(host2Ipv4Interface, host3Ipv4Interface);
    addArpEntriesFromInterfaceAddresses(host3Ipv4Interface, host2Ipv4Interface);

    addArpEntriesFromInterfaceAddresses(host2Ipv4Interface, host4Ipv4Interface);
    addArpEntriesFromInterfaceAddresses(host4Ipv4Interface, host2Ipv4Interface);

    addArpEntriesFromInterfaceAddresses(host2Ipv4Interface, host5Ipv4Interface);
    addArpEntriesFromInterfaceAddresses(host5Ipv4Interface, host2Ipv4Interface);

    addArpEntriesFromInterfaceAddresses(host3Ipv4Interface, host4Ipv4Interface);
    addArpEntriesFromInterfaceAddresses(host4Ipv4Interface, host3Ipv4Interface);

    addArpEntriesFromInterfaceAddresses(host3Ipv4Interface, host5Ipv4Interface);
    addArpEntriesFromInterfaceAddresses(host5Ipv4Interface, host3Ipv4Interface);

    addArpEntriesFromInterfaceAddresses(host4Ipv4Interface, host5Ipv4Interface);
    addArpEntriesFromInterfaceAddresses(host5Ipv4Interface, host4Ipv4Interface);

    P4SwitchHelper qlrHelper;
    qlrHelper.SetDeviceAttribute("PipelineJson",
                                 StringValue("/ns3/ns-3.40/examples/qlrouting/qlr_build/qlr.json"));
    qlrHelper.SetDeviceAttribute("PacketDeparser", PointerValue(CreateObject<QLRDeparser>()));

    qlrHelper.SetDeviceAttribute(
        "PipelineCommands",
        StringValue(loadCommands("/ns3/ns-3.40/examples/qlrouting/resources/5_nodes/s1.txt")));
    NetDeviceContainer s1p4Cont = qlrHelper.Install(s1, s1Interfaces);
    Ptr<P4SwitchNetDevice> s1p4 = DynamicCast<P4SwitchNetDevice>(s1p4Cont.Get(0));
    s1p4->m_mmu->SetAlphaIngress(1.0 / 8);
    s1p4->m_mmu->SetBufferPool(64 * 1024 * 1024);
    s1p4->m_mmu->SetIngressPool(64 * 1024 * 1024);
    s1p4->m_mmu->SetAlphaEgress(1.0 / 8);
    s1p4->m_mmu->SetEgressPool(64 * 1024 * 1024);
    s1p4->m_mmu->node_id = s1p4->GetNode()->GetId();
    computeQueueBufferSlice(s1p4);

    qlrHelper.SetDeviceAttribute(
        "PipelineCommands",
        StringValue(loadCommands("/ns3/ns-3.40/examples/qlrouting/resources/5_nodes/s2.txt")));
    NetDeviceContainer s2p4Cont = qlrHelper.Install(s2, s2Interfaces);
    Ptr<P4SwitchNetDevice> s2p4 = DynamicCast<P4SwitchNetDevice>(s2p4Cont.Get(0));
    s2p4->m_mmu->SetAlphaIngress(1.0 / 8);
    s2p4->m_mmu->SetBufferPool(64 * 1024 * 1024);
    s2p4->m_mmu->SetIngressPool(64 * 1024 * 1024);
    s2p4->m_mmu->SetAlphaEgress(1.0 / 8);
    s2p4->m_mmu->SetEgressPool(64 * 1024 * 1024);
    s2p4->m_mmu->node_id = s2p4->GetNode()->GetId();
    computeQueueBufferSlice(s2p4);

    qlrHelper.SetDeviceAttribute(
        "PipelineCommands",
        StringValue(loadCommands("/ns3/ns-3.40/examples/qlrouting/resources/5_nodes/s3.txt")));
    NetDeviceContainer s3p4Cont = qlrHelper.Install(s3, s3Interfaces);
    Ptr<P4SwitchNetDevice> s3p4 = DynamicCast<P4SwitchNetDevice>(s3p4Cont.Get(0));
    s3p4->m_mmu->SetAlphaIngress(1.0 / 8);
    s3p4->m_mmu->SetBufferPool(64 * 1024 * 1024);
    s3p4->m_mmu->SetIngressPool(64 * 1024 * 1024);
    s3p4->m_mmu->SetAlphaEgress(1.0 / 8);
    s3p4->m_mmu->SetEgressPool(64 * 1024 * 1024);
    s3p4->m_mmu->node_id = s3p4->GetNode()->GetId();
    computeQueueBufferSlice(s3p4);

    qlrHelper.SetDeviceAttribute(
        "PipelineCommands",
        StringValue(loadCommands("/ns3/ns-3.40/examples/qlrouting/resources/5_nodes/s4.txt")));
    NetDeviceContainer s4p4Cont = qlrHelper.Install(s4, s4Interfaces);
    Ptr<P4SwitchNetDevice> s4p4 = DynamicCast<P4SwitchNetDevice>(s4p4Cont.Get(0));
    s4p4->m_mmu->SetAlphaIngress(1.0 / 8);
    s4p4->m_mmu->SetBufferPool(64 * 1024 * 1024);
    s4p4->m_mmu->SetIngressPool(64 * 1024 * 1024);
    s4p4->m_mmu->SetAlphaEgress(1.0 / 8);
    s4p4->m_mmu->SetEgressPool(64 * 1024 * 1024);
    s4p4->m_mmu->node_id = s4p4->GetNode()->GetId();
    computeQueueBufferSlice(s4p4);

    qlrHelper.SetDeviceAttribute(
        "PipelineCommands",
        StringValue(loadCommands("/ns3/ns-3.40/examples/qlrouting/resources/5_nodes/s5.txt")));
    NetDeviceContainer s5p4Cont = qlrHelper.Install(s5, s5Interfaces);
    Ptr<P4SwitchNetDevice> s5p4 = DynamicCast<P4SwitchNetDevice>(s5p4Cont.Get(0));
    s5p4->m_mmu->SetAlphaIngress(1.0 / 8);
    s5p4->m_mmu->SetBufferPool(64 * 1024 * 1024);
    s5p4->m_mmu->SetIngressPool(64 * 1024 * 1024);
    s5p4->m_mmu->SetAlphaEgress(1.0 / 8);
    s5p4->m_mmu->SetEgressPool(64 * 1024 * 1024);
    s5p4->m_mmu->node_id = s5p4->GetNode()->GetId();
    computeQueueBufferSlice(s5p4);

    Simulator::Schedule(MicroSeconds(0), &updateQdepth, s1p4);
    Simulator::Schedule(MicroSeconds(0), &updateQdepth, s2p4);
    Simulator::Schedule(MicroSeconds(0), &updateQdepth, s3p4);
    Simulator::Schedule(MicroSeconds(0), &updateQdepth, s4p4);
    Simulator::Schedule(MicroSeconds(0), &updateQdepth, s5p4);

    NS_LOG_INFO("Create Applications.");
    NS_LOG_INFO("Create Active Flow Applications.");

    uint16_t activePort = 20000;

    ApplicationContainer host1ReceiverApp = createSinkTcpApplication(activePort + 1, host1);
    host1ReceiverApp.Start(Seconds(0.0));

    ApplicationContainer host2ReceiverApp = createSinkTcpApplication(activePort + 2, host2);
    host2ReceiverApp.Start(Seconds(0.0));

    ApplicationContainer host3ReceiverApp = createSinkTcpApplication(activePort + 3, host3);
    host3ReceiverApp.Start(Seconds(0.0));

    ApplicationContainer host4ReceiverApp = createSinkTcpApplication(activePort + 4, host4);
    host4ReceiverApp.Start(Seconds(0.0));

    ApplicationContainer host5ReceiverApp = createSinkTcpApplication(activePort + 5, host5);
    host5ReceiverApp.Start(Seconds(0.0));

    startTcpFlow(host1,
                 host1Ipv4Interfaces,
                 host2,
                 activePort + 1,
                 activeRateTcp,
                 tcpDataSize,
                 congestionControl);
    startTcpFlow(host1,
                 host1Ipv4Interfaces,
                 host3,
                 activePort + 1,
                 activeRateTcp,
                 tcpDataSize,
                 congestionControl);
    startTcpFlow(host1,
                 host1Ipv4Interfaces,
                 host4,
                 activePort + 1,
                 activeRateTcp,
                 tcpDataSize,
                 congestionControl);
    startTcpFlow(host1,
                 host1Ipv4Interfaces,
                 host5,
                 activePort + 1,
                 activeRateTcp,
                 tcpDataSize,
                 congestionControl);

    startTcpFlow(host2,
                 host2Ipv4Interfaces,
                 host1,
                 activePort + 2,
                 activeRateTcp,
                 tcpDataSize,
                 congestionControl);
    startTcpFlow(host2,
                 host2Ipv4Interfaces,
                 host3,
                 activePort + 2,
                 activeRateTcp,
                 tcpDataSize,
                 congestionControl);
    startTcpFlow(host2,
                 host2Ipv4Interfaces,
                 host4,
                 activePort + 2,
                 activeRateTcp,
                 tcpDataSize,
                 congestionControl);
    startTcpFlow(host2,
                 host2Ipv4Interfaces,
                 host5,
                 activePort + 2,
                 activeRateTcp,
                 tcpDataSize,
                 congestionControl);

    startTcpFlow(host3,
                 host3Ipv4Interfaces,
                 host1,
                 activePort + 3,
                 activeRateTcp,
                 tcpDataSize,
                 congestionControl);
    startTcpFlow(host3,
                 host3Ipv4Interfaces,
                 host2,
                 activePort + 3,
                 activeRateTcp,
                 tcpDataSize,
                 congestionControl);
    startTcpFlow(host3,
                 host3Ipv4Interfaces,
                 host4,
                 activePort + 3,
                 activeRateTcp,
                 tcpDataSize,
                 congestionControl);
    startTcpFlow(host3,
                 host3Ipv4Interfaces,
                 host5,
                 activePort + 3,
                 activeRateTcp,
                 tcpDataSize,
                 congestionControl);

    startTcpFlow(host4,
                 host4Ipv4Interfaces,
                 host1,
                 activePort + 4,
                 activeRateTcp,
                 tcpDataSize,
                 congestionControl);
    startTcpFlow(host4,
                 host4Ipv4Interfaces,
                 host2,
                 activePort + 4,
                 activeRateTcp,
                 tcpDataSize,
                 congestionControl);
    startTcpFlow(host4,
                 host4Ipv4Interfaces,
                 host3,
                 activePort + 4,
                 activeRateTcp,
                 tcpDataSize,
                 congestionControl);
    startTcpFlow(host4,
                 host4Ipv4Interfaces,
                 host5,
                 activePort + 4,
                 activeRateTcp,
                 tcpDataSize,
                 congestionControl);

    startTcpFlow(host5,
                 host5Ipv4Interfaces,
                 host1,
                 activePort + 5,
                 activeRateTcp,
                 tcpDataSize,
                 congestionControl);
    startTcpFlow(host5,
                 host5Ipv4Interfaces,
                 host2,
                 activePort + 5,
                 activeRateTcp,
                 tcpDataSize,
                 congestionControl);
    startTcpFlow(host5,
                 host5Ipv4Interfaces,
                 host3,
                 activePort + 5,
                 activeRateTcp,
                 tcpDataSize,
                 congestionControl);
    startTcpFlow(host5,
                 host5Ipv4Interfaces,
                 host4,
                 activePort + 5,
                 activeRateTcp,
                 tcpDataSize,
                 congestionControl);

    uint16_t backupPort = 30000;
    NS_LOG_INFO("Create Backup Flow Applications.");
    if (backupFlows > 0)
    {
        for (uint32_t i = 1; i <= backupFlows; i++)
        {
            startUdpFlow(host5,
                         host5Ipv4Interfaces,
                         host1,
                         backupPort + i,
                         backupRateUdp,
                         udpStartTime,
                         udpEndTime,
                         udpDataSize,
                         generateRandom);
        }
    }

    if (dumpTraffic)
    {
        std::string tracesPath = getPath(resultsPath, "traces");
        std::filesystem::create_directories(tracesPath);

        csma_sw.EnablePcapAll(getPath(tracesPath, "p4-switch"), true);
        csma_host.EnablePcapAll(getPath(tracesPath, "p4-switch"), true);
    }

    FlowMonitorHelper flowHelper;
    Ptr<FlowMonitor> flowMon = flowHelper.Install(NodeContainer(switches, hosts));

    printSimulationTime();

    NS_LOG_INFO("Run Simulation.");
    Simulator::Stop(Seconds(endTime));
    Simulator::Run();

    flowMon->CheckForLostPackets();
    Ptr<Ipv4FlowClassifier> classifier =
        DynamicCast<Ipv4FlowClassifier>(flowHelper.GetClassifier());
    auto stats = flowMon->GetFlowStats();

    double tcpThroughputSum = 0.0;
    double udpThroughputSum = 0.0;
    uint32_t tcpCount = 0;
    uint32_t udpCount = 0;

    for (const auto& flow : stats)
    {
        Ipv4FlowClassifier::FiveTuple t = classifier->FindFlow(flow.first);
        double duration =
            flow.second.timeLastRxPacket.GetSeconds() - flow.second.timeFirstRxPacket.GetSeconds();
        double throughput = (duration > 0) ? (flow.second.rxBytes * 8.0 / duration / 1e6) : 0;

        std::string proto;
        if (t.protocol == 6)
        {
            proto = "TCP";
            tcpThroughputSum += throughput;
            tcpCount++;
        }
        else if (t.protocol == 17)
        {
            proto = "UDP";
            udpThroughputSum += throughput;
            udpCount++;
        }
        else
        {
            proto = "OTHER";
        }

        std::cout << "Flow " << flow.first << " (" << t.sourceAddress << " -> "
                  << t.destinationAddress << ") [" << proto << "] Throughput: " << throughput
                  << " Mbit/s" << std::endl;
    }

    if (tcpCount > 0)
        std::cout << "Average TCP Throughput: " << (tcpThroughputSum / tcpCount) << " Mbit/s"
                  << std::endl;
    else
        std::cout << "No TCP flows detected." << std::endl;

    if (udpCount > 0)
        std::cout << "Average UDP Throughput: " << (udpThroughputSum / udpCount) << " Mbit/s"
                  << std::endl;
    else
        std::cout << "No UDP flows detected." << std::endl;

    flowMon->SerializeToXmlFile(getPath(resultsPath, resultName), true, true);

    Simulator::Destroy();
    NS_LOG_INFO("Done.");
}
