#pragma once
#include "ns3/core-module.h"
#include "ns3/internet-module.h"
#include "ns3/network-module.h"
#include "ns3/p4-switch-module.h"

#include <map>
#include <random>

using namespace ns3;

extern std::map<uint32_t, uint64_t> queueBufferSlice;

void computeQueueBufferSlice(Ptr<P4SwitchNetDevice> p4Device);

void updateQdepth(Ptr<P4SwitchNetDevice> p4Device);

void traceQdepthUpdate(Ptr<P4SwitchNetDevice> p4Device, Ptr<OutputStreamWrapper> qdepthFile);

void traceQdepth(Ptr<P4SwitchNetDevice> p4Device, std::string fileName);

void startTcpFlow(Ptr<Node> receiverHost,
                  uint16_t addressIndex,
                  Ptr<Node> senderHost,
                  uint16_t port,
                  float startTime,
                  uint32_t qlrFlowDataSize,
                  std::string resultsPath,
                  std::string congestionControl = "TcpLinuxReno");

void startUdpFlow(Ptr<Node> receiverHost,
                  uint16_t addressIndex,
                  Ptr<Node> senderHost,
                  uint16_t port,
                  std::string rate,
                  float start_time,
                  float end_time,
                  float burstDataSize);

void startBackgroundTraffic(NodeContainer hosts,
                            uint32_t addressIndex,
                            uint16_t destinationPort,
                            uint32_t backgroundFlowsForHost,
                            std::string dataRate,
                            float startTime,
                            float endTime,
                            uint32_t dataSize);

void startBurstTraffic(Ptr<Node> sourceNode,
                       Ptr<Node> destinationNode,
                       uint16_t addressIndex,
                       uint16_t destinationPort,
                       std::string dataRate,
                       float startTime,
                       float endTime,
                       uint16_t dataSize,
                       uint16_t burstFlows);

std::pair<NodeContainer, NodeContainer> createTopology(
    const std::vector<std::pair<int, int>> edges,
    std::vector<int> hostsVector,
    uint16_t numNodes,
    std::string switchBandwidth,
    std::string hostBandwidth,
    bool dumpTraffic,
    std::string resultsPath,
    std::map<Ptr<Node>, Ptr<P4SwitchNetDevice>>& p4SwitchMap);

NodeContainer addHosts(NodeContainer switches,
                       const std::vector<int> hostsVector,
                       std::string hostBandwidth,
                       bool dumpTraffic,
                       std::string resultsPath);

void generateWorkload(NodeContainer hosts,
                      float endTime,
                      uint32_t destinationId,
                      uint32_t qlrFlowsForHost,
                      float qlrFlowStartTime,
                      uint32_t qlrFlowDataSize,
                      std::string congestionControl,
                      uint32_t backgroundFlowsForHost,
                      std::string backgroundFlowRate,
                      uint32_t burstFlows,
                      float burstMinStartTime,
                      float burstMaxStartTime,
                      float burstMinDuration,
                      float burstMaxDuration,
                      float burstMinInterval,
                      float burstMaxInterval,
                      std::string burstRate,
                      uint32_t burstDataSize,
                      int seed,
                      std::string resultsPath);

Ptr<P4SwitchNetDevice> configureP4Switch(Ptr<Node> switchNode,
                                         std::string commandsPath,
                                         P4SwitchHelper switchHelper);

class QLRDeparser : public P4PacketDeparser
{
  public:
    Ptr<Packet> get_ns3_packet(std::unique_ptr<bm::Packet> bm_packet);
};

struct TopologyResult
{
    ns3::NodeContainer switches;
    std::map<uint32_t, ns3::NetDeviceContainer> switchInterfaces;
};