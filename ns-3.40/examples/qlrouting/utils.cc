#include "ns3/core-module.h"
#include "ns3/internet-module.h"
#include "ns3/network-module.h"
#include "ns3/point-to-point-module.h"

#include <fstream>
#include <sstream>
#include <stdexcept>
#include <string>
#include <chrono>
#include <iomanip>

using namespace ns3;

static auto g_realStart = std::chrono::steady_clock::now();

NS_LOG_COMPONENT_DEFINE("utils");

Mac48Address
convertToMacAddress(Address address)
{
    Mac48Address senderMacAddress = Mac48Address();
    senderMacAddress = senderMacAddress.ConvertFrom(address);
    return senderMacAddress;
}

std::string
getPath(std::string directory, std::string file)
{
    return SystemPath::Append(directory, file);
}

void
addIpv4Address(Ptr<Node> host5,
                NetDeviceContainer host5Interfaces,
                std::string address,
                std::string netmask)
{
    Ptr<Ipv4> ipv4Host = host5->GetObject<Ipv4>();
    uint32_t ifaceIndex = ipv4Host->GetInterfaceForDevice(host5Interfaces.Get(0));
    Ipv4Address addr = Ipv4Address(address.c_str());
    Ipv4Mask mask = Ipv4Mask(netmask.c_str());
    Ipv4InterfaceAddress ifaceAddress = Ipv4InterfaceAddress(addr, mask);
    ipv4Host->AddAddress(ifaceIndex, ifaceAddress);
    ipv4Host->SetUp(ifaceIndex);
}

Ptr<Ipv4Interface>
getIpv4Interface(Ptr<NetDevice> netDevice)
{
    Ptr<Node> node = netDevice->GetNode();
    int32_t interface_index = node->GetObject<Ipv4>()->GetInterfaceForDevice(netDevice);
    return node->GetObject<Ipv4L3Protocol>()->GetInterface(interface_index);
}

void
printRoutes(Ptr<Ipv4StaticRouting> routing)
{
    for (uint32_t i = 0; i < routing->GetNRoutes(); i++)
    {
        std::ostringstream oss;
        oss << routing->GetRoute(i);
        std::cout << oss.str() << std::endl;
    }
}

void
addRoutesFromInterfaceAddresses(Ptr<Ipv4Interface> nodeInterface,
                                    Ptr<Ipv4Interface> ipv4Interface)
{
    Ipv4StaticRoutingHelper ipv4StaticRouting;
    Ptr<Ipv4StaticRouting> routing = ipv4StaticRouting.GetStaticRouting(
        nodeInterface->GetDevice()->GetNode()->GetObject<Ipv4>());
    for (uint32_t i = 0; i < ipv4Interface->GetNAddresses(); i++)
    {
        Ipv4Address address = ipv4Interface->GetAddress(i).GetAddress();
        routing->AddHostRouteTo(address, 1);
    }

    std::ostringstream oss;
    oss << "Routes for " << Names::FindName(nodeInterface->GetDevice()->GetNode()) << std::endl;
    for (uint32_t i = 0; i < routing->GetNRoutes(); i++)
    {
        oss << routing->GetRoute(i) << std::endl;
    }
    NS_LOG_DEBUG(oss.str());
}

std::string
loadCommands(std::string path)
{
    std::ifstream commandFile(path);
    std::ostringstream commands;

    if (!commandFile)
    {
        throw std::runtime_error("Failed to open commands file: " + path);
    }

    std::string line;
    while (std::getline(commandFile, line))
    {
        commands << line << "\n";
    }

    return commands.str();
}

void
printSimulationTime()
{
    int64_t ms = Simulator::Now().GetMilliSeconds();
    int64_t s  = ms / 1000;
    int64_t ms_part = ms % 1000;
    auto realElapsed = std::chrono::steady_clock::now() - g_realStart;
    int64_t real_ms = std::chrono::duration_cast<std::chrono::milliseconds>(realElapsed).count();
    int64_t real_s  = real_ms / 1000;
    int64_t real_ms_part = real_ms % 1000;
    std::cout << "Simulation Time: "
              << s << "." << std::setw(3) << std::setfill('0') << ms_part << " s"
              << "  (real: "
              << real_s << "." << std::setw(3) << std::setfill('0') << real_ms_part << " s)"
              << std::endl;
    Simulator::Schedule(MilliSeconds(100), printSimulationTime);
}


NetDeviceContainer getAllDevices (Ptr<Node> node) {
    NetDeviceContainer devices;
    for (uint32_t i = 0; i < node->GetNDevices(); i++) {
        devices.Add(node->GetDevice(i));
    }
    return devices;
}