#pragma once
#include "ns3/core-module.h"
#include "ns3/network-module.h"
#include "ns3/internet-module.h"
#include <map>
#include <string>
#include <cstdio>

using namespace ns3;

// Declare tracer globals
extern std::map<uint32_t, std::map<uint32_t, bool>> firstCwnd;
extern std::map<uint32_t, std::map<uint32_t, Ptr<OutputStreamWrapper>>> cWndStream;
extern std::map<uint32_t, std::map<uint32_t, uint32_t>> cWndValue;

extern std::map<std::string, std::pair<uint64_t, uint64_t>> ctx2tpInfo;
extern std::map<std::string, FILE*> tpStream;
extern Time period;

extern std::map<std::string, std::pair<SequenceNumber32, uint32_t>> ctx2rtxInfo;
extern std::map<std::string, FILE*> rtxStream;
extern Time rtxPeriod;

// Function declarations
uint32_t GetNodeIdFromContext(std::string context);
uint32_t GetSocketIdFromContext(std::string context);
void CwndTracer(std::string context, uint32_t oldval, uint32_t newval);
void TraceCwnd(std::string fileName, uint32_t nodeId, uint32_t socketId);
void tracePktTxNetDevice(std::string context, Ptr<const Packet> p);
void startThroughputPortTrace(std::string fileName, uint32_t nodeId, uint32_t ifaceId);
void startThroughputTrace(Ptr<Node> node, NetDeviceContainer nodeInterfaces, uint32_t startTime, std::string resultsPath);
void tcpRx(std::string context, const Ptr<const Packet> p, const TcpHeader& hdr, const Ptr<const TcpSocketBase> skt);
void startTcpRtx(Ptr<Node> node, std::string fileName, uint32_t socketId);