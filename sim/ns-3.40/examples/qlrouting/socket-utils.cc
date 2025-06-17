#include "ns3/applications-module.h"
#include "ns3/core-module.h"
#include "ns3/internet-module.h"
#include "ns3/network-module.h"


using namespace ns3;

NS_LOG_COMPONENT_DEFINE("socket-utils");


ApplicationContainer
createTcpApplication(Ipv4Address addressToReach,
                     uint16_t port,
                     Ptr<Node> node,
                     std::string dataRate,
                     uint32_t maxBytes,
                     std::string congestionControl)
{
    TypeId congestionControlTid = TypeId::LookupByName("ns3::" + congestionControl);

    Config::Set("/NodeList/" + std::to_string(node->GetId()) + "/$ns3::TcpL4Protocol/SocketType",
                TypeIdValue(congestionControlTid));

    BulkSendHelper source("ns3::TcpSocketFactory",
                          Address(InetSocketAddress(addressToReach, port)));
    source.SetAttribute("MaxBytes", UintegerValue(maxBytes));

    return source.Install(node);
}

ApplicationContainer
createSinkTcpApplication(uint16_t port, Ptr<Node> node)
{
    PacketSinkHelper sink("ns3::TcpSocketFactory",
                          Address(InetSocketAddress(Ipv4Address::GetAny(), port)));

    return sink.Install(node);
}

ApplicationContainer
createUdpApplication(Ipv4Address addressToReach,
                     uint16_t port,
                     Ptr<Node> node,
                     std::string dataRate,
                     uint32_t maxBytes)
{
    OnOffHelper source("ns3::UdpSocketFactory", Address(InetSocketAddress(addressToReach, port)));
    source.SetConstantRate(DataRate(dataRate), 1400);
    source.SetAttribute("MaxBytes", UintegerValue(maxBytes));

    ApplicationContainer senderApp = source.Install(node);

    return senderApp;
}

ApplicationContainer
createSinkUdpApplication(uint16_t port, Ptr<Node> node)
{
    PacketSinkHelper sink("ns3::UdpSocketFactory",
                          Address(InetSocketAddress(Ipv4Address::GetAny(), port)));
    return sink.Install(node);
}
