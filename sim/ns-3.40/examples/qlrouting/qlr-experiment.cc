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
#include "qlr-controller.h"
#include "qlr-utils.h"
#include "socket-utils.h"
#include "tracer.h"
#include "utils.h"

#include "ns3/flow-monitor-helper.h"
#include "ns3/flow-monitor-module.h"

#include <filesystem>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <random>
#include <string>

using namespace ns3;

NS_LOG_COMPONENT_DEFINE("QLRoutingExample");

bool verbose = false;

int
main(int argc, char* argv[])

{
    std::vector<std::pair<int, int>> edges =
        {{0, 1}, {0, 2}, {1, 2}, {1, 3}, {2, 3}, {2, 4}, {3, 4}};
    std::string edgesString = "0,1;0,2;1,2;1,3;2,3;2,4;3,4";
    std::vector<int> hostVector = {1, 1, 1, 1, 1};
    std::string dags = "";
    std::string hostVectorString = "1,1,1,1,1";
    uint32_t numSwitches = 5;
    std::string congestionControl;
    std::string workloadFilePath;
    std::string switchBandwidth;
    std::string hostBandwidth;
    std::string colorUpdateInterval = "200ms";
    std::string p4program = "examples/qlrouting/qlr_build/qlr.json";
    std::string p4baseCommand = "";
    std::string mode = "qlr";

    float endTime;
    bool dumpTraffic = false;
    std::string resultsPath;

    // Packet::EnablePrinting();

    CommandLine cmd;
    cmd.AddValue("edges", "Edge list as pairs of node IDs (format: 0,1;0,2;1,2;...)", edgesString);
    cmd.AddValue("hosts", "Host vector for each switch (format: 1,1,1,1,1)", hostVectorString);
    cmd.AddValue("switches", "Number of switches", numSwitches);
    cmd.AddValue("dags", "Per-destination DAGs", dags);
    cmd.AddValue("cc", "The TCP congestion control used for the experiment", congestionControl);
    cmd.AddValue("workload-file", "Path to the workload file", workloadFilePath);
    cmd.AddValue("switch-bw", "The bandwidth to set on all inter-switch links", switchBandwidth);
    cmd.AddValue("host-bw", "The bandwidth to set on all the host-switch links", hostBandwidth);
    cmd.AddValue("end", "Simulation End Time", endTime);
    cmd.AddValue("dump-traffic", "Dump traffic traces", dumpTraffic);
    cmd.AddValue("results-path", "The path where to save results", resultsPath);
    cmd.AddValue("color-update-interval", "The path where to save results", colorUpdateInterval);
    cmd.AddValue("p4-program", "The path of the P4 program to load", p4program);
    cmd.AddValue("p4-command",
                 "The base path for commands to install in each P4 switch",
                 p4baseCommand);
    cmd.AddValue("mode", "Mode of operation: either qlr or central", mode);

    cmd.Parse(argc, argv);

    edges.clear();
    std::stringstream ss(edgesString);
    std::string edgePair;
    while (std::getline(ss, edgePair, ';'))
    {
        std::stringstream edgeStream(edgePair);
        std::string node1Str, node2Str;
        if (std::getline(edgeStream, node1Str, ',') && std::getline(edgeStream, node2Str, ','))
        {
            int node1 = std::stoi(node1Str);
            int node2 = std::stoi(node2Str);
            edges.push_back({node1, node2});
        }
    }

    hostVector.clear();
    std::stringstream hvStream(hostVectorString);
    std::string hostCountStr;
    while (std::getline(hvStream, hostCountStr, ','))
    {
        hostVector.push_back(std::stoi(hostCountStr));
    }

    // if (verbose)
    {
        // LogComponentEnable("FlowMonitor", LOG_LEVEL_DEBUG);
        // LogComponentEnable("SwitchMmu", LOG_LEVEL_DEBUG);
        // LogComponentEnable("P4Pipeline", LOG_LEVEL_DEBUG);
        // LogComponentEnable("P4SwitchNetDevice", LOG_LEVEL_DEBUG);
        LogComponentEnable("P4SwitchHelper", LOG_LEVEL_DEBUG);
        // LogComponentEnable("TcpSocketBase", LOG_LEVEL_DEBUG);
        //  LogComponentEnable("utils", LOG_LEVEL_DEBUG);
        // LogComponentEnable("TcpOptionRfc793", LOG_LEVEL_DEBUG);
        LogComponentEnable("qlr-utils", LOG_LEVEL_INFO);
        LogComponentEnable("socket-utils", LOG_LEVEL_DEBUG);
        LogComponentEnable("QLRoutingExample", LOG_LEVEL_INFO);
        LogComponentEnable("Tracer", LOG_LEVEL_DEBUG);
    }

    NS_LOG_INFO("#### RUN PARAMETERS ####");
    NS_LOG_INFO("edges: " + edgesString);
    NS_LOG_INFO("hostVector: " + hostVectorString);
    NS_LOG_INFO("numSwitches: " + std::to_string(numSwitches));
    NS_LOG_INFO("workloadFilePath: " + workloadFilePath);
    NS_LOG_INFO("switchBandwidth: " + switchBandwidth);
    NS_LOG_INFO("hostBandwidth: " + hostBandwidth);
    NS_LOG_INFO("endTime: " + std::to_string(endTime));
    NS_LOG_INFO("dumpTraffic: " + std::string(dumpTraffic ? "true" : "false"));
    NS_LOG_INFO("resultsPath: " + resultsPath);
    NS_LOG_INFO("colorUpdateInterval: " + colorUpdateInterval);
    NS_LOG_INFO("p4program: " + p4program);
    NS_LOG_INFO("p4baseCommand: " + p4baseCommand);
    NS_LOG_INFO("mode: " + mode);

    NS_LOG_INFO("Configuring Congestion Control.");
    std::string queueDisc = "FifoQueueDisc";
    queueDisc = std::string("ns3::") + queueDisc;

    Config::SetDefault("ns3::TcpL4Protocol::SocketType", StringValue("ns3::" + congestionControl));
    Config::SetDefault("ns3::TcpSocket::SndBufSize", UintegerValue(2 << 17));
    Config::SetDefault("ns3::TcpSocket::RcvBufSize", UintegerValue(2 << 17));
    Config::SetDefault("ns3::TcpSocket::InitialCwnd", UintegerValue(100));
    // Config::SetDefault("ns3::TcpSocket::DelAckCount", UintegerValue(2));
    // Config::SetDefault("ns3::TcpSocket::SegmentSize", UintegerValue(1400));

    std::filesystem::create_directories(resultsPath);
    std::filesystem::create_directories(getPath(resultsPath, "cwnd"));
    std::filesystem::create_directories(getPath(resultsPath, "throughput"));
    std::filesystem::create_directories(getPath(resultsPath, "retransmissions"));
    std::filesystem::create_directories(getPath(resultsPath, "qdepth"));

    std::map<Ptr<Node>, Ptr<P4SwitchNetDevice>> p4SwitchMap;

    std::pair<NodeContainer, NodeContainer> nodes = createTopology(edges,
                                                                   hostVector,
                                                                   numSwitches,
                                                                   switchBandwidth,
                                                                   hostBandwidth,
                                                                   dumpTraffic,
                                                                   resultsPath,
                                                                   p4SwitchMap,
                                                                   colorUpdateInterval,
                                                                   mode,
                                                                   p4program,
                                                                   p4baseCommand);

    NodeContainer switches = nodes.first;
    NodeContainer hosts = nodes.second;

    Ptr<QlrController> ctrl = CreateObject<QlrController>();
    if (mode == "central")
    {
        ctrl->Init(switches, hosts, p4SwitchMap);
        ctrl->RegisterDestinations(/*interfaceIndex=*/1, /*addressIndex=*/0);
        ctrl->BuildAdjacency(edges);
        ctrl->BuildDAGs(dags);
        ctrl->SetControlPeriod(MilliSeconds(2));
        ctrl->SetInstallPeriod(MilliSeconds(20));
        ctrl->Start();
    }

    startThroughputPortTrace(getPath(resultsPath, "throughput/s1-1.tp"),
                             switches.Get(0)->GetId(),
                             1);

    startThroughputPortTrace(getPath(resultsPath, "throughput/s1-2.tp"),
                             switches.Get(0)->GetId(),
                             2);

    startThroughputPortTrace(getPath(resultsPath, "throughput/h1-0.tp"), hosts.Get(0)->GetId(), 0);

    NS_LOG_INFO("Create Applications.");
    generateWorkloadFromFile(hosts, workloadFilePath, congestionControl, resultsPath);

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

        if (verbose)
        {
            std::cout << "Flow " << flow.first << " (" << t.sourceAddress << " -> "
                      << t.destinationAddress << ") [" << proto << "] Throughput: " << throughput
                      << " Mbit/s" << std::endl;
        }
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

    flowMon->SerializeToXmlFile(getPath(resultsPath, "flow_monitor.xml"), true, true);

    ctrl->Stop();
    Simulator::Destroy();
    NS_LOG_INFO("Done.");
}
