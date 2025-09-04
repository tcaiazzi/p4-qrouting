#pragma once
#include "ns3/network-module.h"
#include "ns3/internet-module.h"
#include <string>

using namespace ns3;

Mac48Address convertToMacAddress(Address address);
std::string getPath(std::string directory, std::string file);
void addIpv4ArpEntry(Ptr<Ipv4Interface> interface, Ipv4Address ipv4Address, Mac48Address macAddress);
Ptr<Ipv4Interface> getIpv4Interface(Ptr<NetDevice> netDevice);
void printRoutes(Ptr<Ipv4StaticRouting> routing);
void addArpEntriesFromInterfaceAddresses(Ptr<Ipv4Interface> nodeInterface, Ptr<Ipv4Interface> ipv4Interface);
void addIpv4Address(Ptr<Ipv4Interface> ipv4Interface, Ipv4AddressHelper* ipv4AddressHelper);
void addIpv4Address2(Ptr<Node> host5, NetDeviceContainer host5Interfaces, Ipv4Address address, Ipv4Mask netmask);
std::string loadCommands(std::string path);
void printSimulationTime();
