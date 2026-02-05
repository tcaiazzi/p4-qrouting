#ifndef QLR_UTILS_H
#define QLR_UTILS_H

#include "ns3/core-module.h"
#include "ns3/internet-module.h"
#include "ns3/network-module.h"
#include "ns3/p4-switch-module.h"

#include <map>
#include <random>

using namespace ns3;

extern std::map<uint32_t, uint64_t> queueBufferSlice;

void computeQueueBufferSlice(Ptr<P4SwitchNetDevice> p4Device);

void updateQdepth(Ptr<P4SwitchNetDevice> p4Device, std::string colorUpdateInterval = "200ns");

void traceQdepthUpdate(Ptr<P4SwitchNetDevice> p4Device, Ptr<OutputStreamWrapper> qdepthFile);

void traceQdepth(Ptr<P4SwitchNetDevice> p4Device, std::string fileName);

void startTcpFlow(Ptr<Node> receiverHost,
                  uint16_t addressIndex,
                  Ptr<Node> senderHost,
                  uint16_t port,
                  float startTime,
                  uint32_t flowDataSize,
                  std::string resultsPath,
                  std::string congestionControl = "TcpLinuxReno");

void startUdpFlow(Ptr<Node> receiverHost,
                  uint16_t addressIndex,
                  Ptr<Node> senderHost,
                  uint16_t port,
                  std::string rate,
                  uint32_t packetSize,
                  float start_time,
                  float end_time,
                  float burstDataSize);

std::pair<NodeContainer, NodeContainer> createTopology(
    const std::vector<std::pair<int, int>> edges,
    std::vector<int> hostsVector,
    uint16_t numNodes,
    std::string switchBandwidth,
    std::string hostBandwidth,
    bool dumpTraffic,
    std::string resultsPath,
    std::map<Ptr<Node>, Ptr<P4SwitchNetDevice>>& p4SwitchMap,
    std::string mode,
    std::string colorUpdateInterval,
    std::string p4programPath,
    std::string p4baseCommandPath);

NodeContainer addHosts(NodeContainer switches,
                       const std::vector<int> hostsVector,
                       std::string hostBandwidth,
                       bool dumpTraffic,
                       std::string resultsPath);

void generateWorkloadFromFile(NodeContainer hosts,
                              std::string workloadFilePath,
                              std::string congestionControl,
                              std::string resultsPath);

Ptr<P4SwitchNetDevice> configureP4Switch(Ptr<Node> switchNode,
                                         std::string commandsPath,
                                         P4SwitchHelper switchHelper,
                                         std::string colorUpdateInterval,
                                         std::string mode);

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

#endif