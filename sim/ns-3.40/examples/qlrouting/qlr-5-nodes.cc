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

int
main(int argc, char* argv[])

{
    uint32_t qlrFlows = 1;
    uint32_t burstFlows = 1;
    std::string defaultBandwidth = "50Kbps";
    std::string resultName = "flow_monitor.xml";
    float endTime = 20.0f;
    float burstMaxTime = 0.5;
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
    uint32_t seed = 10;

    std::string resultsPath = "";

    // Packet::EnablePrinting();

    CommandLine cmd;
    cmd.AddValue("results-path", "The path where to save results", resultsPath);
    cmd.AddValue("fm-name", "The name of the flow monitor result", resultName);
    cmd.AddValue("qlr-flows", "The number of concurrent qlr flows", qlrFlows);
    cmd.AddValue("burst-flows", "The number of concurrent bursts", burstFlows);
    cmd.AddValue("burst-max-time", "The maximum lenght in second for a burst", burstMaxTime);
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
    cmd.AddValue("seed", "The seed to use for the experiment", seed);

    cmd.Parse(argc, argv);
    ;

    // if (verbose)
    {
        // LogComponentEnable("FlowMonitor", LOG_LEVEL_DEBUG);
        // LogComponentEnable("SwitchMmu", LOG_LEVEL_DEBUG);
        // LogComponentEnable("P4Pipeline", LOG_LEVEL_DEBUG);
        // LogComponentEnable("P4SwitchNetDevice", LOG_LEVEL_WARN);
        // LogComponentEnable("P4SwitchHelper", LOG_LEVEL_WARN);
        // LogComponentEnable("TcpSocketBase", LOG_LEVEL_DEBUG);
        // LogComponentEnable("utils", LOG_LEVEL_DEBUG);
        LogComponentEnable("qlr-utils", LOG_LEVEL_INFO);
        LogComponentEnable("socket-utils", LOG_LEVEL_DEBUG);
        LogComponentEnable("QLRoutingExample", LOG_LEVEL_INFO);
        LogComponentEnable("Tracer", LOG_LEVEL_DEBUG);
    }

    NS_LOG_INFO("#### RUN PARAMETERS ####");
    NS_LOG_INFO("Results Path: " + resultsPath);
    NS_LOG_INFO("Flow Monitor Name: " + resultName);
    NS_LOG_INFO("QLR Flows: " + std::to_string(qlrFlows));
    NS_LOG_INFO("Burst Flows: " + std::to_string(burstFlows));
    NS_LOG_INFO("Burst Max Time: " + std::to_string(burstMaxTime));
    NS_LOG_INFO("Burst Num: " + std::to_string(burstNum));
    NS_LOG_INFO("Burst Interval: " + std::to_string(burstInterval));
    NS_LOG_INFO("QLR Start Time: " + std::to_string(qlrFlowStartTime));
    NS_LOG_INFO("QLR End Time: " + std::to_string(qlrFlowEndTime));
    NS_LOG_INFO("Default Bandwidth: " + defaultBandwidth);
    NS_LOG_INFO("QLR Rate: " + qlrRate);
    NS_LOG_INFO("Burst Rate: " + burstRate);
    NS_LOG_INFO("QLR Data Size: " + std::to_string(qlrFlowDataSize));
    NS_LOG_INFO("Burst Data Size: " + std::to_string(burstDataSize));
    NS_LOG_INFO("Dump Traffic: " + std::string(dumpTraffic ? "true" : "false"));
    NS_LOG_INFO("Congestion Control: " + congestionControl);
    NS_LOG_INFO("End Time: " + std::to_string(endTime));
    NS_LOG_INFO("Verbose: " + std::string(verbose ? "true" : "false"));
    NS_LOG_INFO("Seed: " + std::to_string(seed));

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

    std::map<Ptr<Node>, Ptr<P4SwitchNetDevice>> p4SwitchMap;

    std::pair<NodeContainer, NodeContainer> nodes =
        createTopology({{0, 1}, {0, 2}, {1, 2}, {1, 3}, {2, 3}, {2, 4}, {3, 4}},
                       5,
                       defaultBandwidth,
                       "100Gbps",
                       dumpTraffic,
                       resultsPath,
                       p4SwitchMap);

    NodeContainer switches = nodes.first;
    NodeContainer hosts = nodes.second;

    NS_LOG_INFO("Create Applications.");
    NS_LOG_INFO("Create Active Flow Applications.");

    generateWorkload(hosts,
                     endTime,
                     qlrFlowStartTime,
                     qlrFlowDataSize,
                     congestionControl,
                     burstFlows,
                     burstNum,
                     burstMaxTime,
                     burstRate,
                     burstDataSize,
                     seed,
                     resultsPath);

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

        if (verbose) {
        std::cout << "Flow " << flow.first << " (" << t.sourceAddress << " -> "
                  << t.destinationAddress << ") [" << proto << "] Throughput: " << throughput
                  << " Mbit/s" << std::endl;
        }
    }

    if (verbose && tcpCount > 0)
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
