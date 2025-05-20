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
 *
 * Author: Mariano Scazzariello <marianos@kth.se>
 */
#ifndef P4_SWITCH_NET_DEVICE_H
#define P4_SWITCH_NET_DEVICE_H

#define DEFAULT_MAX_PRIO_Q 7

#include "ns3/drop-tail-queue.h"
#include "ns3/mac48-address.h"
#include "ns3/net-device.h"
#include "ns3/nstime.h"
#include "ns3/p4-packet-deparser.h"
#include "ns3/p4-pipeline.h"
#include "ns3/p4-switch-channel.h"
#include "ns3/switch-mmu.h"

#include <deque>
#include <list>
#include <map>
#include <stdint.h>
#include <string>

/**
 * \file
 * \ingroup p4-switch
 * ns3::P4SwitchNetDevice declaration.
 */

namespace ns3
{

class Node;

/**
 * \defgroup p4-switch P4 Switch Network Device
 *
 * \brief a virtual net device that runs a P4 pipeline
 *
 * The P4SwitchNetDevice object is a "virtual" netdevice that aggregates
 * multiple "real" netdevices and implements the data plane forwarding
 * part using a pre-compiled P4 program.
 */

/**
 * \ingroup p4-switch
 * \brief a virtual net device that runs a P4 pipeline
 */
class P4SwitchNetDevice : public NetDevice
{
  public:
    /**
     * \brief Get the type ID.
     * \return the object TypeId
     */
    static TypeId GetTypeId();
    P4SwitchNetDevice();
    ~P4SwitchNetDevice() override;

    P4SwitchNetDevice(const P4SwitchNetDevice&) = delete;
    P4SwitchNetDevice& operator=(const P4SwitchNetDevice&) = delete;

    void AddPort(Ptr<NetDevice> port);
    uint32_t GetNPorts() const;
    Ptr<NetDevice> GetPort(uint32_t n) const;
    uint32_t GetPortN(Ptr<NetDevice> port);

    std::string GetPipelineJson() const;
    void SetPipelineJson(std::string pipeline_json);
    std::string GetPipelineCommands() const;
    void SetPipelineCommands(std::string pipeline_commands);
    Ptr<P4PacketDeparser> GetPktDeparser() const;
    void SetPktDeparser(Ptr<P4PacketDeparser> pkt_deparser);

    std::string RunPipelineCommands(std::string commands);

    // inherited from NetDevice base class.
    void SetIfIndex(const uint32_t index) override;
    uint32_t GetIfIndex() const override;
    Ptr<Channel> GetChannel() const override;
    void SetAddress(Address address) override;
    Address GetAddress() const override;
    bool SetMtu(const uint16_t mtu) override;
    uint16_t GetMtu() const override;
    bool IsLinkUp() const override;
    void AddLinkChangeCallback(Callback<void> callback) override;
    bool IsBroadcast() const override;
    Address GetBroadcast() const override;
    bool IsMulticast() const override;
    Address GetMulticast(Ipv4Address multicastGroup) const override;
    bool IsPointToPoint() const override;
    bool IsBridge() const override;
    bool Send(Ptr<Packet> packet, const Address& dest, uint16_t protocolNumber) override;
    bool SendFrom(Ptr<Packet> packet,
                  const Address& source,
                  const Address& dest,
                  uint16_t protocolNumber) override;
    Ptr<Node> GetNode() const override;
    void SetNode(Ptr<Node> node) override;
    bool NeedsArp() const override;
    void SetReceiveCallback(NetDevice::ReceiveCallback cb) override;
    void SetPromiscReceiveCallback(NetDevice::PromiscReceiveCallback cb) override;
    bool SupportsSendFrom() const override;
    Address GetMulticast(Ipv6Address addr) const override;

    P4Pipeline* m_p4_pipeline; //!< The P4 pipeline
    Ptr<SwitchMmu> m_mmu;

  protected:
    void DoDispose() override;

    void ReceiveFromDevice(Ptr<NetDevice> device,
                           Ptr<const Packet> packet,
                           uint16_t protocol,
                           const Address& source,
                           const Address& destination,
                           PacketType packetType);
    void DeparseAndEnqueue(uint32_t outport_n,
                           uint16_t qid,
                           std::unique_ptr<bm::Packet> out_pkt,
                           Ptr<const Packet> input_pkt);
    void DequeueRR(uint32_t p);
    void DequeueCallback(uint32_t port_idx, Ptr<const Packet> packet);
    void TxEndCallback(uint32_t port_idx, Ptr<const Packet> packet);

    void InitPipeline();

  private:
    // Same as SwitchMmu
    static const uint32_t pCnt = 257; // Number of ports used
    static const uint32_t qCnt = 8;   // Number of queues/priorities used

    NetDevice::ReceiveCallback m_rxCallback;               //!< receive callback
    NetDevice::PromiscReceiveCallback m_promiscRxCallback; //!< promiscuous receive callback

    Mac48Address m_address; //!< MAC address of the NetDevice, this is the MAC Address of the first
                            //!< interface added

    std::string m_pipeline_json;          //!< The bmv2 JSON file (generated by the p4c backend)
    std::string m_pipeline_commands;      //!< The CLI commands to run
    Ptr<P4PacketDeparser> m_pkt_deparser; //!< Packet deparser (from bmv2 to ns3)

    Ptr<Node> m_node;                    //!< node owning this NetDevice
    Ptr<P4SwitchChannel> m_channel;      //!< virtual channel
    std::vector<Ptr<NetDevice>> m_ports; //!< ports
    uint32_t m_ifIndex;                  //!< Interface index
    uint16_t m_mtu;                      //!< MTU of the NetDevice

    DropTailQueue<Packet> eg_queues[pCnt][qCnt];
    uint32_t qIndexLast[pCnt];
    bool portBusy[pCnt];
};
} // namespace ns3

#endif /* P4_SWITCH_NET_DEVICE_H */
