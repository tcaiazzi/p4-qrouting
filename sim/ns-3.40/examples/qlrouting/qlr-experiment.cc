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
    std::string hostVectorString = "1,1,1,1,1";
    uint32_t numSwitches = 5;

    uint32_t destinationId;
    uint32_t qlrFlowsForHost;
    float qlrFlowStartTime;
    uint32_t qlrFlowDataSize;
    std::string congestionControl;

    uint32_t backgroundFlowsForHost;
    std::string backgroundFlowRate;

    uint32_t burstFlows;
    float burstMinStartTime;
    float burstMaxStartTime;
    float burstMinDuration;
    float burstMaxDuration;
    float burstMinInterval;
    float burstMaxInterval;
    uint32_t burstDataSize;
    std::string burstRate;
    uint32_t seed = 10;

    std::string switchBandwidth;
    std::string hostBandwidth;

    float endTime;
    std::string resultName = "flow_monitor.xml";
    bool dumpTraffic = false;
    std::string resultsPath;

    // Packet::EnablePrinting();

    CommandLine cmd;
    cmd.AddValue("edges", "Edge list as pairs of node IDs (format: 0,1;0,2;1,2;...)", edgesString);
    cmd.AddValue("hosts", "Host vector for each switch (format: 1,1,1,1,1)", hostVectorString);
    cmd.AddValue("switches", "Number of switches", numSwitches);
    cmd.AddValue("destination-id", "Destination node ID", destinationId);
    cmd.AddValue("qlr-flows", "The number of qlr flows from each source", qlrFlowsForHost);
    cmd.AddValue("qlr-start-time", "The time to start QLR flows", qlrFlowStartTime);
    cmd.AddValue("qlr-data-size", "Size of the data sent by QLR flows", qlrFlowDataSize);
    cmd.AddValue("cc", "The TCP congestion control used for the experiment", congestionControl);

    cmd.AddValue("background-flows", "Number of background flows per host", backgroundFlowsForHost);
    cmd.AddValue("background-rate", "Rate of background flows", backgroundFlowRate);
    cmd.AddValue("burst-flows", "The number of concurrent bursts", burstFlows);
    cmd.AddValue("burst-min-start-time", "Minimum start time for bursts", burstMinStartTime);
    cmd.AddValue("burst-max-start-time", "Maximum start time for bursts", burstMaxStartTime);
    cmd.AddValue("burst-min-duration", "Minimum duration for bursts", burstMinDuration);
    cmd.AddValue("burst-max-duration", "Maximum duration for bursts", burstMaxDuration);
    cmd.AddValue("burst-min-interval", "Minimum interval between bursts", burstMinInterval);
    cmd.AddValue("burst-max-interval", "Maximum interval between bursts", burstMaxInterval);
    cmd.AddValue("burst-data-size", "Size of the data sent by bursty flows", burstDataSize);
    cmd.AddValue("burst-rate", "The rate to set to the bursty flows", burstRate);
    cmd.AddValue("seed", "The seed to use for the experiment", seed);
    cmd.AddValue("switch-bw",
                 "The bandwidth to set on all inter-switch links",
                 switchBandwidth);
    cmd.AddValue("host-bw",
                     "The bandwidth to set on all the host-switch links",
                     hostBandwidth);
    cmd.AddValue("end", "Simulation End Time", endTime);
    cmd.AddValue("fm-name", "The name of the flow monitor result", resultName);
    cmd.AddValue("dump-traffic", "Dump traffic traces", dumpTraffic);
    cmd.AddValue("results-path", "The path where to save results", resultsPath);

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
    NS_LOG_INFO("edges: " + edgesString);
    NS_LOG_INFO("hostVector: " + hostVectorString);
    NS_LOG_INFO("numSwitches: " + std::to_string(numSwitches));
    NS_LOG_INFO("destinationId: " + std::to_string(destinationId));
    NS_LOG_INFO("qlrFlowsForHost: " + std::to_string(qlrFlowsForHost));
    NS_LOG_INFO("qlrFlowStartTime: " + std::to_string(qlrFlowStartTime));
    NS_LOG_INFO("qlrFlowDataSize: " + std::to_string(qlrFlowDataSize));
    NS_LOG_INFO("congestionControl: " + congestionControl);

    NS_LOG_INFO("backgroundFlowsForHost: " + std::to_string(backgroundFlowsForHost));
    NS_LOG_INFO("backgroundFlowRate: " + backgroundFlowRate);

    NS_LOG_INFO("burstFlows: " + std::to_string(burstFlows));
    NS_LOG_INFO("burstMinStartTime: " + std::to_string(burstMinStartTime));
    NS_LOG_INFO("burstMaxStartTime: " + std::to_string(burstMaxStartTime));
    NS_LOG_INFO("burstMinDuration: " + std::to_string(burstMinDuration));
    NS_LOG_INFO("burstMaxDuration: " + std::to_string(burstMaxDuration));
    NS_LOG_INFO("burstMinInterval: " + std::to_string(burstMinInterval));
    NS_LOG_INFO("burstMaxInterval: " + std::to_string(burstMaxInterval));
    NS_LOG_INFO("burstDataSize: " + std::to_string(burstDataSize));
    NS_LOG_INFO("burstRate: " + burstRate);
    NS_LOG_INFO("seed: " + std::to_string(seed));

    NS_LOG_INFO("switchBandwidth: " + switchBandwidth);
    NS_LOG_INFO("hostBandwidth: " + hostBandwidth);

    NS_LOG_INFO("endTime: " + std::to_string(endTime));
    NS_LOG_INFO("resultName: " + resultName);
    NS_LOG_INFO("dumpTraffic: " + std::string(dumpTraffic ? "true" : "false"));
    NS_LOG_INFO("resultsPath: " + resultsPath);

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
        createTopology(edges,
                       hostVector,
                       numSwitches,
                       switchBandwidth,
                       hostBandwidth,
                       dumpTraffic,
                       resultsPath,
                       p4SwitchMap);

    NodeContainer switches = nodes.first;
    NodeContainer hosts = nodes.second;

    NS_LOG_INFO("Create Applications.");
    NS_LOG_INFO("Create Active Flow Applications.");

    generateWorkload(hosts,
                     endTime,
                     destinationId,
                     qlrFlowsForHost,
                     qlrFlowStartTime,
                     qlrFlowDataSize,
                     congestionControl,
                     backgroundFlowsForHost,
                     backgroundFlowRate,
                     burstFlows,
                     burstMinStartTime,
                     burstMaxStartTime,
                     burstMinDuration,
                     burstMaxDuration,
                     burstMinInterval,
                     burstMaxInterval,
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

        if (verbose)
        {
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
