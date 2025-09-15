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
#include "qlr-utils.h"
#include "socket-utils.h"
#include "tracer.h"
#include "utils.h"

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
             uint16_t addressIndex,
             Ptr<Node> senderHost,
             uint16_t port,
             float startTime,
             std::string qlrRate,
             uint32_t qlrFlowDataSize,
             std::string congestionControl = "TcpLinuxReno"
             )
{
    ApplicationContainer hostSenderApp =
        createTcpApplication(receiverInterfaces[0]->GetAddress(addressIndex).GetAddress(),
                             port,
                             senderHost,
                             qlrRate,
                             qlrFlowDataSize,
                             congestionControl);
    hostSenderApp.Start(Seconds(startTime));

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

    std::string retransmissionPath =
        getPath(getPath(resultsPath, "retransmissions"), fileName + ".rtx");
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
}

void
startUdpFlow(std::vector<Ptr<Ipv4Interface>> receiverInterfaces,
             uint16_t addressIndex,
             Ptr<Node> senderHost,
             uint16_t port,
             std::string rate,
             uint32_t start_time,
             float end_time,
             float burstDataSize)
{
    Ipv4Address dst_addr = receiverInterfaces[0]->GetAddress(addressIndex).GetAddress();

    NS_LOG_INFO("Starting UDP flow from " << Names::FindName(senderHost) << " to " << dst_addr
                                          << " on port " << std::to_string(port));

    ApplicationContainer hostSenderApp =
        createUdpApplication(dst_addr, port, senderHost, rate, burstDataSize);
    hostSenderApp.Start(Seconds(start_time));
    if (end_time > 0)
        hostSenderApp.Stop(Seconds(end_time));
}

Ptr<P4SwitchNetDevice>
configureP4Switch(Ptr<Node> switchNode,
                  std::string commandsPath,
                  NetDeviceContainer switchInterfaces,
                  P4SwitchHelper switchHelper)
{
    switchHelper.SetDeviceAttribute("PipelineCommands", StringValue(loadCommands(commandsPath)));
    NetDeviceContainer p4DevContainer = switchHelper.Install(switchNode, switchInterfaces);
    Ptr<P4SwitchNetDevice> p4Switch = DynamicCast<P4SwitchNetDevice>(p4DevContainer.Get(0));
    p4Switch->m_mmu->SetAlphaIngress(1.0 / 8);
    p4Switch->m_mmu->SetBufferPool(64 * 1024 * 1024);
    p4Switch->m_mmu->SetIngressPool(64 * 1024 * 1024);
    p4Switch->m_mmu->SetAlphaEgress(1.0 / 8);
    p4Switch->m_mmu->SetEgressPool(64 * 1024 * 1024);
    p4Switch->m_mmu->node_id = p4Switch->GetNode()->GetId();
    computeQueueBufferSlice(p4Switch);
    return p4Switch;
}

int
main(int argc, char* argv[])

{
    uint32_t qlrFlows = 1;
    uint32_t burstFlows = 1;
    std::string defaultBandwidth = "50Kbps";
    std::string resultName = "flow_monitor.xml";
    float endTime = 20.0f;
    float burstStartTime = 2.0f;
    float burstEndTime = 2.1f;
    float burstNum = 2;
    float burstInterval = 0.5f;
    float qlrFlowStartTime = 1.0f;
    float qlrFlowEndTime = 1.0f;
    std::string qlrRate = "100Mbps";
    std::string burstRate = "50Kbps";
    std::string congestionControl = "TcpLinuxReno";
    uint32_t qlrFlowDataSize = 150000000;
    uint32_t burstDataSize = 150000000;
    bool dumpTraffic = false;

    // Packet::EnablePrinting();

    CommandLine cmd;
    cmd.AddValue("results-path", "The path where to save results", resultsPath);
    cmd.AddValue("fm-name", "The name of the flow monitor result", resultName);
    cmd.AddValue("qlr-flows", "The number of concurrent qlr flows", qlrFlows);
    cmd.AddValue("burst-flows", "The number of concurrent bursts", burstFlows);
    cmd.AddValue("burst-start-time", "The time to start bursts", burstStartTime);
    cmd.AddValue("burst-end-time", "The time to stop bursts", burstEndTime);
    cmd.AddValue("burst-num", "The number of bursts", burstNum);
    cmd.AddValue("burst-interval", "The interval time between bursts", burstInterval);
    cmd.AddValue("qlr-start-time", "The time to start QLR flows", qlrFlowStartTime);
    cmd.AddValue("qlr-end-time", "The time to stop QLR flows", qlrFlowEndTime);
    cmd.AddValue("default-bw",
                 "The bandwidth to set on all the sender/receiver links",
                 defaultBandwidth);
    cmd.AddValue("qlr-rate", "The rate to set to the QLR flows", qlrRate);
    cmd.AddValue("burst-rate", "The rate to set to the bursty flows", burstRate);
    cmd.AddValue("qlr-data-size", "Size of the data sent by QLR flows", qlrFlowDataSize);
    cmd.AddValue("burst-data-size", "Size of the data sent by bursty flows", burstDataSize);
    cmd.AddValue("dump-traffic", "Dump traffic traces", dumpTraffic);
    cmd.AddValue("cc", "The TCP congestion control used for the experiment", congestionControl);

    cmd.AddValue("end", "Simulation End Time", endTime);
    cmd.AddValue("verbose", "Verbose output", verbose);

    cmd.Parse(argc, argv);

    LogComponentEnable("QLRoutingExample", LOG_LEVEL_INFO);
    // LogComponentEnable("P4Pipeline", LOG_LEVEL_DEBUG);
    // LogComponentEnable("P4SwitchNetDevice", LOG_LEVEL_WARN);
    LogComponentEnable("qlr-utils", LOG_LEVEL_DEBUG);

    // if (verbose)
    {
        // LogComponentEnable("FlowMonitor", LOG_LEVEL_DEBUG);
        // LogComponentEnable("P4SwitchNetDevice", LOG_LEVEL_WARN);
        // LogComponentEnable("SwitchMmu", LOG_LEVEL_DEBUG);
        // LogComponentEnable("P4Pipeline", LOG_LEVEL_DEBUG);
        // LogComponentEnable("TcpSocketBase", LOG_LEVEL_DEBUG);
        // LogComponentEnable("utils", LOG_LEVEL_DEBUG);
    }

    NS_LOG_INFO("#### RUN PARAMETERS ####");
    NS_LOG_INFO("Results Path: " + resultsPath);
    NS_LOG_INFO("FLow Monitor Name: " + resultName);
    NS_LOG_INFO("Congestion Control: " + congestionControl);
    NS_LOG_INFO("End Time: " + std::to_string(endTime));
    NS_LOG_INFO("Backup Rate UDP: " + burstRate);
    NS_LOG_INFO("Data Size UDP: " + std::to_string(burstDataSize));

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
    std::filesystem::create_directories(getPath(resultsPath, "qdepth"));

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
    host1Ipv4Interfaces.push_back(host1Ipv4Interface);

    Ptr<Ipv4Interface> host2Ipv4Interface = getIpv4Interface(host2Interfaces.Get(0));
    host2Ipv4Interfaces.push_back(host2Ipv4Interface);

    Ptr<Ipv4Interface> host3Ipv4Interface = getIpv4Interface(host3Interfaces.Get(0));
    host3Ipv4Interfaces.push_back(host3Ipv4Interface);

    Ptr<Ipv4Interface> host4Ipv4Interface = getIpv4Interface(host4Interfaces.Get(0));
    host4Ipv4Interfaces.push_back(host4Ipv4Interface);

    Ptr<Ipv4Interface> host5Ipv4Interface = getIpv4Interface(host5Interfaces.Get(0));
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

    Ptr<P4SwitchNetDevice> s1p4 =
        configureP4Switch(s1,
                          "/ns3/ns-3.40/examples/qlrouting/resources/5_nodes/s1.txt",
                          s1Interfaces,
                          qlrHelper);

    Ptr<P4SwitchNetDevice> s2p4 =
        configureP4Switch(s2,
                          "/ns3/ns-3.40/examples/qlrouting/resources/5_nodes/s2.txt",
                          s2Interfaces,
                          qlrHelper);

    Ptr<P4SwitchNetDevice> s3p4 =
        configureP4Switch(s3,
                          "/ns3/ns-3.40/examples/qlrouting/resources/5_nodes/s3.txt",
                          s3Interfaces,
                          qlrHelper);

    Ptr<P4SwitchNetDevice> s4p4 =
        configureP4Switch(s4,
                          "/ns3/ns-3.40/examples/qlrouting/resources/5_nodes/s4.txt",
                          s4Interfaces,
                          qlrHelper);

    Ptr<P4SwitchNetDevice> s5p4 =
        configureP4Switch(s5,
                          "/ns3/ns-3.40/examples/qlrouting/resources/5_nodes/s5.txt",
                          s5Interfaces,
                          qlrHelper);

    Simulator::Schedule(MicroSeconds(0), &updateQdepth, s1p4);
    // Simulator::Schedule(MicroSeconds(0), &updateQdepth, s2p4);
    // Simulator::Schedule(MicroSeconds(0), &updateQdepth, s3p4);
    // Simulator::Schedule(MicroSeconds(0), &updateQdepth, s4p4);
    // Simulator::Schedule(MicroSeconds(0), &updateQdepth, s5p4);

    startThroughputTrace(s1, s1Interfaces, 1.0, getPath(resultsPath, "throughput"));

    traceQdepth(s1p4, getPath(resultsPath, "qdepth/s1.txt"));

    NS_LOG_INFO("Create Applications.");
    NS_LOG_INFO("Create Active Flow Applications.");

    uint16_t qlrPort = 22222;
    uint16_t defaultPort = 20000;

    ApplicationContainer host1ReceiverApp = createSinkTcpApplication(qlrPort, host1);
    host1ReceiverApp.Start(Seconds(0.0));
    ApplicationContainer defaultHost1ReceiverApp = createSinkUdpApplication(defaultPort, host1);
    defaultHost1ReceiverApp.Start(Seconds(0.0));

    ApplicationContainer host2ReceiverApp = createSinkTcpApplication(qlrPort, host2);
    host2ReceiverApp.Start(Seconds(0.0));
    ApplicationContainer defaultHost2ReceiverApp = createSinkUdpApplication(defaultPort, host2);
    defaultHost2ReceiverApp.Start(Seconds(0.0));

    ApplicationContainer host3ReceiverApp = createSinkTcpApplication(qlrPort, host3);
    host3ReceiverApp.Start(Seconds(0.0));
    ApplicationContainer defaultHost3ReceiverApp = createSinkUdpApplication(defaultPort, host3);
    defaultHost3ReceiverApp.Start(Seconds(0.0));

    ApplicationContainer host4ReceiverApp = createSinkTcpApplication(qlrPort, host4);
    host4ReceiverApp.Start(Seconds(0.0));
    ApplicationContainer defaultHost4ReceiverApp = createSinkUdpApplication(defaultPort, host4);
    defaultHost4ReceiverApp.Start(Seconds(0.0));

    ApplicationContainer host5ReceiverApp = createSinkTcpApplication(qlrPort, host5);
    host5ReceiverApp.Start(Seconds(0.0));
    ApplicationContainer defaultHost5ReceiverApp = createSinkUdpApplication(defaultPort, host5);
    defaultHost5ReceiverApp.Start(Seconds(0.0));

    startTcpFlow(host5,
                 host5Ipv4Interfaces,
                 0,
                 host1,
                 qlrPort,
                 qlrFlowStartTime,
                 qlrRate,
                 qlrFlowDataSize,
                 congestionControl);

    startUdpFlow(host1Ipv4Interfaces, 0, host2, defaultPort, "1Mbps", qlrFlowStartTime, endTime, 0);
    startUdpFlow(host1Ipv4Interfaces, 0, host3, defaultPort, "1Mbps", qlrFlowStartTime, endTime, 0);
    startUdpFlow(host1Ipv4Interfaces, 0, host4, defaultPort, "1Mbps", qlrFlowStartTime, endTime, 0);
    startUdpFlow(host1Ipv4Interfaces, 0, host5, defaultPort, "1Mbps", qlrFlowStartTime, endTime, 0);

    startUdpFlow(host2Ipv4Interfaces, 0, host1, defaultPort, "1Mbps", qlrFlowStartTime, endTime, 0);
    startUdpFlow(host2Ipv4Interfaces, 0, host3, defaultPort, "1Mbps", qlrFlowStartTime, endTime, 0);
    startUdpFlow(host2Ipv4Interfaces, 0, host4, defaultPort, "1Mbps", qlrFlowStartTime, endTime, 0);
    startUdpFlow(host2Ipv4Interfaces, 0, host5, defaultPort, "1Mbps", qlrFlowStartTime, endTime, 0);

    startUdpFlow(host3Ipv4Interfaces, 0, host1, defaultPort, "1Mbps", qlrFlowStartTime, endTime, 0);
    startUdpFlow(host3Ipv4Interfaces, 0, host2, defaultPort, "1Mbps", qlrFlowStartTime, endTime, 0);
    startUdpFlow(host3Ipv4Interfaces, 0, host4, defaultPort, "1Mbps", qlrFlowStartTime, endTime, 0);
    startUdpFlow(host3Ipv4Interfaces, 0, host5, defaultPort, "1Mbps", qlrFlowStartTime, endTime, 0);

    startUdpFlow(host4Ipv4Interfaces, 0, host1, defaultPort, "1Mbps", qlrFlowStartTime, endTime, 0);
    startUdpFlow(host4Ipv4Interfaces, 0, host2, defaultPort, "1Mbps", qlrFlowStartTime, endTime, 0);
    startUdpFlow(host4Ipv4Interfaces, 0, host3, defaultPort, "1Mbps", qlrFlowStartTime, endTime, 0);
    startUdpFlow(host4Ipv4Interfaces, 0, host5, defaultPort, "1Mbps", qlrFlowStartTime, endTime, 0);

    startUdpFlow(host5Ipv4Interfaces, 0, host2, defaultPort, "1Mbps", qlrFlowStartTime, endTime, 0);
    startUdpFlow(host5Ipv4Interfaces, 0, host3, defaultPort, "1Mbps", qlrFlowStartTime, endTime, 0);
    startUdpFlow(host5Ipv4Interfaces, 0, host4, defaultPort, "1Mbps", qlrFlowStartTime, endTime, 0);

    if (burstFlows > 0)
    {
        for (uint32_t burstIdx = 1; burstIdx <= burstNum; burstIdx++)
        {
            for (uint32_t i = 1; i <= burstFlows; i++)
            {
                startUdpFlow(host3Ipv4Interfaces,
                             0,
                             host1,
                             defaultPort,
                             burstRate,
                             burstStartTime + (burstIdx - 1) * burstInterval,
                             burstEndTime + (burstIdx - 1) * burstInterval,
                             0);
            }
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
