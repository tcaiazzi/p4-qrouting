#pragma once
#include "ns3/core-module.h"
#include "ns3/internet-module.h"
#include "ns3/network-module.h"

#include <map>
#include <string>
#include <vector>

using namespace ns3;

ApplicationContainer createTcpApplication(Ipv4Address addressToReach,
                                          uint16_t port,
                                          Ptr<Node> node,
                                          std::string dataRate,
                                          uint32_t maxBytes,
                                          std::string congestionControl);
ApplicationContainer createSinkTcpApplication(uint16_t port, Ptr<Node> node);
ApplicationContainer createUdpApplication(Ipv4Address addressToReach,
                                          uint16_t port,
                                          Ptr<Node> node,
                                          std::string dataRate,
                                          uint32_t maxBytes);
ApplicationContainer createSinkUdpApplication(uint16_t port, Ptr<Node> node);