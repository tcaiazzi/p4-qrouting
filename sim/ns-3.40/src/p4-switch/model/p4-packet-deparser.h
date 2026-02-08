/* -*- Mode:C++; c-file-style:"gnu"; indent-tabs-mode:nil; -*- */
/*
 * Copyright (c) 2025 RISE Research Institutes of Sweden
 *
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
 * Author: Mariano Scazzariello <mariano.scazzariello@ri.se>
 */

#ifndef P4_DEPARSER_H
#define P4_DEPARSER_H

#include <bm/bm_sim/packet.h>

#include <ns3/packet.h>
#include <ns3/pointer.h>

namespace ns3
{
/**
 * \ingroup p4-switch
 *
 * Class that needs to be implemented by the user.
 * Converts a bmv2 packet into a ns3 packet.
 */
class P4PacketDeparser : public Object
{
  public:
    /**
     * \brief Converts a bmv2 packet to a ns3 packet. Needs to be user-defined.
     */
    virtual Ptr<Packet> get_ns3_packet(std::unique_ptr<bm::Packet> bm_packet) = 0;
};

} // namespace ns3

#endif /* P4_DEPARSER_H */
