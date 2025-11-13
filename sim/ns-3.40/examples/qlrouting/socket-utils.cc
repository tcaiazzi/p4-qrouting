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
                     uint32_t maxBytes,
                     std::string congestionControl)
{

    NS_LOG_DEBUG("Creating TCP Application to " << addressToReach << ":" << port
                                               << " on node " << node->GetId()
                                               << " with maxBytes=" << maxBytes
                                               << " using CC=" << congestionControl);
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
                     uint32_t packetSize,
                     uint32_t maxBytes)
{
    OnOffHelper source("ns3::UdpSocketFactory", Address(InetSocketAddress(addressToReach, port)));
    source.SetConstantRate(DataRate(dataRate), packetSize);
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

uint32_t GetSocketCount(Ptr<Node> node)
{
    std::ostringstream path;
    path << "/NodeList/" << node->GetId() << "/$ns3::TcpL4Protocol/SocketList/*";

    Config::MatchContainer matches = Config::LookupMatches(path.str());
    return matches.GetN();
}

void PrintTcpSocketsOfNode(uint32_t nodeId)
{
  // build the config path that matches the node's TcpL4Protocol socket list
  std::ostringstream path;
  path << "/NodeList/" << nodeId << "/$ns3::TcpL4Protocol/SocketList/*";

  // LookupMatches returns a MatchContainer with Ptr<Object> for every match
  Config::MatchContainer matches = Config::LookupMatches(path.str());

  std::cout << "Node " << nodeId << " TCP sockets: " << matches.GetN() << "\n";

  for (uint32_t i = 0; i < matches.GetN(); ++i)
    {
      Ptr<Object> obj = matches.Get(i);
      // sockets are TcpSocketBase-derived
      Ptr<TcpSocketBase> sock = DynamicCast<TcpSocketBase>(obj);
      if (sock)
        {
          Address local;
          Address peer;
          sock->GetSockName(local);
          sock->GetPeerName(peer);
          // Print something useful (local address / port)
          Ipv4Address src_addr = InetSocketAddress::ConvertFrom(local).GetIpv4 ();
          uint16_t src_port = InetSocketAddress::ConvertFrom(local).GetPort ();
          Ipv4Address dst_addr = InetSocketAddress::ConvertFrom(peer).GetIpv4 ();
          uint16_t dst_port = InetSocketAddress::ConvertFrom(peer).GetPort ();
          std::cout << "  socket[" << i << "]: src_addr=" << src_addr << ":" << src_port << ", dst_addr: " << dst_addr << ":" << dst_port << std::endl;
        }
      else
        {
          // fallback: try generic Socket
          Ptr<Socket> s = DynamicCast<Socket>(obj);
          std::cout << "  socket[" << i << "] (non-TCP or cannot cast)\n";
        }
    }
}

void PrintTcpSocketsOfNodes(NodeContainer nodes)
{
  for (uint32_t i = 0; i < nodes.GetN(); ++i)
    {
      PrintTcpSocketsOfNode(nodes.Get(i)->GetId());
    }
}
