#pragma once
#include "ns3/core-module.h"
#include "ns3/network-module.h"
#include "ns3/internet-module.h"
#include "ns3/p4-switch-module.h"
#include <map>

using namespace ns3;

extern std::map<uint32_t, uint64_t> queueBufferSlice;

void computeQueueBufferSlice(Ptr<P4SwitchNetDevice> p4Device);

void updateQdepth(Ptr<P4SwitchNetDevice> p4Device);

void traceQdepthUpdate(Ptr<P4SwitchNetDevice> p4Device, Ptr<OutputStreamWrapper> qdepthFile);

void traceQdepth(Ptr<P4SwitchNetDevice> p4Device, std::string fileName);

class QLRDeparser : public P4PacketDeparser
{
  public:
    Ptr<Packet> get_ns3_packet(std::unique_ptr<bm::Packet> bm_packet);
};