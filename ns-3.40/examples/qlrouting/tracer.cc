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
 */
#include "ns3/applications-module.h"
#include "ns3/core-module.h"
#include "ns3/point-to-point-module.h"
#include "ns3/error-model.h"
#include "ns3/flow-monitor-helper.h"
#include "ns3/flow-monitor-module.h"
#include "ns3/internet-module.h"
#include "ns3/network-module.h"
#include "ns3/p4-switch-module.h"

#include <filesystem>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <random>
#include <string>

#include "utils.h"

using namespace ns3;

NS_LOG_COMPONENT_DEFINE("Tracer");

std::map<uint32_t, std::map<uint32_t, bool>> firstCwnd; //!< First congestion window.
std::map<uint32_t, std::map<uint32_t, Ptr<OutputStreamWrapper>>>
    cWndStream; //!< Congestion window output stream per node and socket.
std::map<uint32_t, std::map<uint32_t, uint32_t>> cWndValue; //!< congestion window value.

uint32_t
GetNodeIdFromContext(std::string context)
{
    const std::size_t n1 = context.find_first_of('/', 1);
    const std::size_t n2 = context.find_first_of('/', n1 + 1);
    std::string nodeIdStr = context.substr(n1 + 1, n2 - n1 - 1);
    return std::stoul(nodeIdStr);
}

uint32_t
GetSocketIdFromContext(std::string context)
{
    const std::size_t n1 = context.find_first_of('/', 1);
    const std::size_t n2 = context.find_first_of('/', n1 + 1);
    const std::size_t n3 = context.find_first_of('/', n2 + 1);
    const std::size_t n4 = context.find_first_of('/', n3 + 1);
    const std::size_t n5 = context.find_first_of('/', n4 + 1);
    std::string socketIdStr = context.substr(n4 + 1, n5 - n4 - 1);
    return std::stoul(socketIdStr);
}

void
CwndTracer(std::string context, uint32_t oldval, uint32_t newval)
{
    uint32_t nodeId = GetNodeIdFromContext(context);
    uint32_t socketId = GetSocketIdFromContext(context);

    if (firstCwnd[nodeId][socketId])
    {
        *cWndStream[nodeId][socketId]->GetStream() << "0.0 " << oldval << std::endl;
        firstCwnd[nodeId][socketId] = false;
    }
    *cWndStream[nodeId][socketId]->GetStream()
        << Simulator::Now().GetSeconds() << " " << newval << std::endl;
    *cWndStream[nodeId][socketId]->GetStream() << std::flush;
    cWndValue[nodeId][socketId] = newval;
}

void
TraceCwnd(std::string fileName, uint32_t nodeId, uint32_t socketId)
{
    firstCwnd[nodeId][socketId] = true;
    cWndStream[nodeId][socketId] = Create<OutputStreamWrapper>(fileName.c_str(), std::ios::out);

    AsciiTraceHelper ascii;
    auto it = cWndStream[nodeId].find(socketId);
    if (it == cWndStream[nodeId].end())
        cWndStream[nodeId][socketId] = ascii.CreateFileStream(fileName);
    Config::Connect("/NodeList/" + std::to_string(nodeId) + "/$ns3::TcpL4Protocol/SocketList/" +
                        std::to_string(socketId) + "/CongestionWindow",
                    MakeCallback(&CwndTracer));

    
}

std::map<std::string, std::pair<uint64_t, uint64_t>> ctx2tpInfo;
std::map<std::string, FILE*> tpStream;
Time period = Time::FromInteger(100, Time::Unit::MS);

void
tracePktTxNetDevice(std::string context, Ptr<const Packet> p)
{
    uint64_t lastTs = Simulator::Now().GetNanoSeconds();
    uint32_t pktSize = p->GetSize() * 8;

    Ptr<Packet> pCopy = p->Copy();
    PppHeader pppHdr;
    pCopy->RemoveHeader(pppHdr);
    Ipv4Header ipHdr;
    uint8_t proto = 0;
    if (pCopy->PeekHeader(ipHdr)) // returns true/false or just fills header (call is valid)
    {
        proto = ipHdr.GetProtocol();
    }

    if (proto != 6)
        return;

    auto ctxIt = ctx2tpInfo.find(context);
    if (ctxIt == ctx2tpInfo.end())
    {
        /* First entry for the context, store the current time and the first size in bits */
        ctx2tpInfo.insert(std::make_pair(context, std::make_pair(lastTs, pktSize)));
    }
    else
    {
        /* An entry already exists, check if we have reached the interval */
        Time interval(lastTs - (*ctxIt).second.first);
        (*ctxIt).second.second += pktSize;
        if (interval.Compare(period) >= 0)
        {
            /* Yes, compute the bps and store it */
            double bps = (*ctxIt).second.second * (1000000 / interval.GetMicroSeconds());
            fprintf(tpStream[context], "%f %f\n", Simulator::Now().GetSeconds(), bps);
            fflush(tpStream[context]);
            fsync(fileno(tpStream[context]));

            /* Delete this entry so it can restart for the next period */
            ctx2tpInfo.erase(ctxIt);
        }
    }
}

void
startThroughputPortTrace(std::string fileName, uint32_t nodeId, uint32_t ifaceId)
{
    std::string nsString = "/NodeList/" + std::to_string(nodeId) + "/DeviceList/" +
                           std::to_string(ifaceId) + "/$ns3::PointToPointNetDevice/MacTx";

    NS_LOG_DEBUG("Connecting to " << nsString << " for throughput tracking"); 

    auto it = tpStream.find(nsString);
    if (it == tpStream.end())
        tpStream[nsString] = fopen(fileName.c_str(), "w");

    Config::Connect(nsString, MakeCallback(&tracePktTxNetDevice));
}

void
startThroughputTrace(Ptr<Node> node, float startTime, std::string resultsPath)
{   
    for (uint32_t i = 0; i < node->GetNDevices(); ++i)
    {
        std::string throughputFileName = Names::FindName(node) + "-" + std::to_string(i) + ".tp";
        std::string throughputPath = getPath(resultsPath, throughputFileName);
        Simulator::Schedule(Seconds(startTime + 0.1),
                            &startThroughputPortTrace,
                            throughputPath,
                            node->GetId(),
                            i);
    }
}


/* Functions to track TCP Retransmissions */
std::map<std::string, std::pair<SequenceNumber32, uint32_t>> ctx2rtxInfo;
std::map<std::string, FILE*> rtxStream;
Time rtxPeriod = Time::FromInteger(10, Time::Unit::MS);

void
tcpRx(std::string context,
      const Ptr<const Packet> p,
      const TcpHeader& hdr,
      const Ptr<const TcpSocketBase> skt)
{
    auto it = ctx2rtxInfo.find(context);
    if (it == ctx2rtxInfo.end())
    {
        return;
    }

    SequenceNumber32 currSeqno = hdr.GetSequenceNumber();

    if (currSeqno <= (*it).second.first)
    {
        (*it).second.second++;
        fprintf(rtxStream[context], "%f %d\n", Simulator::Now().GetSeconds(), (*it).second.second);
        fflush(rtxStream[context]);
        fsync(fileno(rtxStream[context]));
    }
    else
    {
        (*it).second.first = currSeqno;
    }
}

void
startTcpRtx(Ptr<Node> node, std::string fileName, uint32_t socketId)
{
    std::string nsString = "/NodeList/" + std::to_string(node->GetId()) +
                           "/$ns3::TcpL4Protocol/SocketList/" + std::to_string(socketId) + "/Tx";

    NS_LOG_DEBUG("Connecting to " << nsString << " for TCP Retransmission tracking");
    auto fileIt = rtxStream.find(nsString);
    if (fileIt == rtxStream.end())
        rtxStream[nsString] = fopen(fileName.c_str(), "w");

    auto seqnoIt = ctx2rtxInfo.find(nsString);
    if (seqnoIt == ctx2rtxInfo.end())
    {
        SequenceNumber32 prevSeqno(0);
        ctx2rtxInfo[nsString] = std::make_pair(prevSeqno, 0);
    }

    Config::Connect(nsString, MakeCallback(&tcpRx));
}
