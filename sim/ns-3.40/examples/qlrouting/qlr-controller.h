#ifndef QLR_CONTROLLER_H
#define QLR_CONTROLLER_H

#include "qlr-utils.h"

#include "ns3/core-module.h"
#include "ns3/internet-module.h"
#include "ns3/network-module.h"
#include "ns3/p4-switch-module.h"

#include <map>
#include <stdexcept>
#include <string>
#include <unordered_map>
#include <vector>

using namespace ns3;

class QlrController : public Object
{
  public:
    QlrController() = default;

    void Init(const NodeContainer& switches,
              const NodeContainer& hosts,
              const std::map<Ptr<Node>, Ptr<P4SwitchNetDevice>> p4SwitchMap)
    {
        m_switches = switches;
        m_hosts = hosts;
        m_p4SwitchMap = p4SwitchMap;

        for (const auto& item : p4SwitchMap)
        {
            item.second->TraceConnectWithoutContext("PipelineInit",
                                                    MakeCallback(&QlrController::SwitchInit, this));
        }

        m_nodeToSwIndex.clear();
        for (uint32_t i = 0; i < m_switches.GetN(); ++i)
        {
            m_nodeToSwIndex[m_switches.Get(i)] = i;
        }
    }

    void RegisterDestinations(uint32_t interfaceIndex = 1, uint32_t addressIndex = 0)
    {
        for (uint32_t hIdx = 0; hIdx < m_hosts.GetN(); ++hIdx)
        {
            Ptr<Node> host = m_hosts.Get(hIdx);
            Ptr<Ipv4> ipv4 = host->GetObject<Ipv4>();
            if (!ipv4)
            {
                NS_FATAL_ERROR("Host has no Ipv4 object installed");
            }
            Ipv4Address addr = ipv4->GetAddress(interfaceIndex, addressIndex).GetAddress();

            std::string key = m_hostPrefix + std::to_string(hIdx);
            m_destinations[key] = addr;
        }
    }

    void BuildAdjacency(const std::vector<std::pair<int, int>>& edges)
    {
        uint32_t n = m_switches.GetN();
        m_adj.assign(n, {});

        for (const auto& e : edges)
        {
            int a = e.first;
            int b = e.second;
            if (a < 0 || b < 0)
                continue;

            uint32_t u = static_cast<uint32_t>(a);
            uint32_t v = static_cast<uint32_t>(b);
            if (u >= n || v >= n)
                continue;

            m_adj[u].push_back(v);
            m_adj[v].push_back(u);
        }

        for (auto& nbrs : m_adj)
        {
            std::sort(nbrs.begin(), nbrs.end());
            nbrs.erase(std::unique(nbrs.begin(), nbrs.end()), nbrs.end());
        }
    }

    void BuildDAGs(const std::string& dags)
    {
        m_dagNextHops.clear();

        std::stringstream ss(dags);
        std::string dagPart;

        // split by ';'  (each DAG)
        while (std::getline(ss, dagPart, ';'))
        {
            if (dagPart.empty())
                continue;

            // split "dst:edges"
            auto colonPos = dagPart.find(':');
            if (colonPos == std::string::npos)
                continue;

            uint32_t dstIdx = std::stoul(dagPart.substr(0, colonPos));

            std::string dstKey = m_hostPrefix + std::to_string(dstIdx);

            std::string edgesStr = dagPart.substr(colonPos + 1);

            std::stringstream es(edgesStr);
            std::string edgeTok;

            // split edges by ','
            while (std::getline(es, edgeTok, ','))
            {
                if (edgeTok.empty())
                    continue;

                // parse "u-v"
                auto dashPos = edgeTok.find('-');
                if (dashPos == std::string::npos)
                    continue;

                uint32_t u = std::stoul(edgeTok.substr(0, dashPos));
                uint32_t v = std::stoul(edgeTok.substr(dashPos + 1));

                m_dagNextHops[dstKey][u].push_back(v);
            }
        }
    }

    void Start()
    {
        m_nextInstallPeriod.resize(m_switches.GetN());
        Simulator::Schedule(Seconds(0), &QlrController::Tick, this);
    }

    void Stop()
    {
        m_running = false;
        if (m_nextControlPeriod.IsRunning())
        {
            Simulator::Cancel(m_nextControlPeriod);
        }

        for (auto ev : m_nextInstallPeriod)
        {
            if (ev.IsRunning())
            {
                Simulator::Cancel(ev);
            }
        }
    }

    void SetControlPeriod(Time period)
    {
        m_controlPeriod = period;
    }

    void SetInstallPeriod(Time period)
    {
        m_installPeriod = period;
    }

  private:
    std::unordered_map<uint32_t, std::vector<uint64_t>> GetQLengths()
    {
        std::unordered_map<uint32_t, std::vector<uint64_t>> out;
        for (const auto& item : m_p4SwitchMap)
        {
            Ptr<Node> swNode = item.first;
            Ptr<P4SwitchNetDevice> p4Device = item.second;
            if (!p4Device)
                continue;

            auto itIdx = m_nodeToSwIndex.find(swNode);
            if (itIdx == m_nodeToSwIndex.end())
            {
                continue;
            }
            uint32_t swIndex = itIdx->second;

            P4Pipeline* pline = p4Device->m_p4_pipeline;
            if (pline == nullptr)
                continue;

            uint32_t nPorts = p4Device->GetNPorts();
            if (nPorts <= 1)
            {
                out[swIndex] = {};
                continue;
            }

            uint64_t totalBufferSlice = queueBufferSlice[p4Device->GetNode()->GetId()];
            uint64_t colorSlice = (uint64_t)(totalBufferSlice / 4.0f);

            std::vector<uint64_t> qlens;
            qlens.reserve(nPorts - 1);

            uint64_t color = 0;
            for (uint32_t p = 1; p < nPorts; ++p)
            {
                uint64_t egressBytes = p4Device->m_mmu->GetEgressBytes(p, 0);
                if (egressBytes <= colorSlice - 1)
                {
                    color = 10;
                }
                else if (egressBytes >= colorSlice && egressBytes <= ((colorSlice * 2) - 1))
                {
                    color = 5;
                }
                else if (egressBytes >= (colorSlice * 2) && egressBytes <= ((colorSlice * 3) - 1))
                {
                    color = 2;
                }
                else if (egressBytes >= (colorSlice * 3) && egressBytes <= ((colorSlice * 4) - 1))
                {
                    color = 0;
                }
                qlens.push_back(color);
            }

            out[swIndex] = std::move(qlens);
        }

        return out;
    }

    /* QLearning Helpers */
    /* Creates QTable for a destination */
    void EnsureQ(const std::string& dstKey)
    {
        const uint32_t nSwitches = m_switches.GetN();

        auto& Q = m_Q[dstKey];
        if (Q.size() != nSwitches)
        {
            Q.assign(nSwitches, {});
        }

        for (uint32_t sw = 0; sw < nSwitches; ++sw)
        {
            uint32_t numA = 0;
            auto itDst = m_dagNextHops.find(dstKey);
            if (itDst != m_dagNextHops.end())
            {
                auto itSw = itDst->second.find(sw);
                if (itSw != itDst->second.end())
                {
                    numA = static_cast<uint32_t>(itSw->second.size());
                }
            }

            if (Q[sw].size() != numA)
            {
                Q[sw].assign(numA, 10.0);
            }
        }
    }

    /* Compute max in a row */
    double MaxRow(const std::vector<double>& row)
    {
        double mx = 0.0;
        for (double v : row)
            mx = std::max(mx, v);
        return mx;
    }

    /* Get the index of the action with the max value */
    uint32_t ArgMax(const std::vector<double>& row)
    {
        double bestV = row[0];
        uint32_t bestA = 0;
        for (uint32_t a = 1; a < row.size(); ++a)
        {
            if (row[a] > bestV)
            {
                bestV = row[a];
                bestA = a;
            }
        }

        /* Return max, we stick with one to avoid path oscillations */
        return bestA;
    }

    /* Reward is -qlen */
    double RewardForChoice(uint32_t sw,
                           size_t idx,
                           const std::unordered_map<uint32_t, std::vector<uint64_t>>& qlens)
    {
        auto itQ = qlens.find(sw);
        if (itQ == qlens.end())
            return 0.0;

        const std::vector<uint64_t>& qs = itQ->second;
        if (idx >= qs.size())
            return 0.0;

        /* Adj indexing starts at 0 and also qlen, so we keep idx intact */
        uint64_t qlen = qs[idx];
        return static_cast<double>(qlen);
    }

    bool NeighborToPort(uint32_t sw, uint32_t nextSw, uint32_t* port) const
    {
        const auto& neighs = m_adj[sw];
        for (size_t idx = 0; idx < neighs.size(); ++idx)
        {
            if (neighs[idx] == nextSw)
            {
                *port = static_cast<uint32_t>(idx);
                return true;
            }
        }

        return false;
    }

    void InstallP4Rules(uint32_t sw, const std::unordered_map<std::string, uint32_t>& dests)
    {
        Ptr<Node> swObj = m_switches.Get(sw);
        auto p4DevIt = m_p4SwitchMap.find(swObj);
        if (p4DevIt == m_p4SwitchMap.end())
            return;

        /* Get the P4 Pipeline reference */
        Ptr<P4SwitchNetDevice> p4Device = p4DevIt->second;
        if (!p4Device)
            return;
        P4Pipeline* pline = p4Device->m_p4_pipeline;
        if (!pline)
            return;

        pline->mt_clear_entries(0, "IngressPipe.select_port", false);

        for (const auto& ip2port : dests)
        {
            /* TCP */
            /* Build key for the table */
            std::vector<bm::MatchKeyParam> key;
            key.emplace_back(bm::MatchKeyParam::Type::LPM, ip2port.first, 32);
            std::string proto(1, static_cast<char>(6));
            key.emplace_back(bm::MatchKeyParam::Type::EXACT, proto);

            /* Build action data */
            bm::ActionData data;
            data.push_back_action_data(ip2port.second);

            /* Insert the rule */
            bm::entry_handle_t handle;
            pline->mt_add_entry(0,
                                "IngressPipe.select_port",
                                key,
                                "IngressPipe.set_nhop",
                                data,
                                &handle);

            /* UDP */
            /* Build key for the table */
            std::vector<bm::MatchKeyParam> key1;
            key1.emplace_back(bm::MatchKeyParam::Type::LPM, ip2port.first, 32);
            std::string proto1(1, static_cast<char>(17));
            key1.emplace_back(bm::MatchKeyParam::Type::EXACT, proto1);

            /* Build action data */
            bm::ActionData data1;
            data1.push_back_action_data(m_updIpToPort[sw][ip2port.first]);

            /* Insert the rule */
            bm::entry_handle_t handle1;
            pline->mt_add_entry(0,
                                "IngressPipe.select_port",
                                key1,
                                "IngressPipe.set_nhop",
                                data1,
                                &handle1);
        }

        m_running = true;
    }

    /* QLearning Logic */
    void DoQLearning(uint32_t sw, const std::unordered_map<uint32_t, std::vector<uint64_t>>& qlens)
    {
        std::unordered_map<std::string, uint32_t> swRules;

        const uint32_t nSwitches = m_switches.GetN();

        for (const auto& dstItem : m_destinations)
        {
            const std::string& dstKey = dstItem.first;
            uint8_t buf[4];
            dstItem.second.Serialize(buf);
            std::string k(reinterpret_cast<char*>(buf), 4);

            auto itDag = m_dagNextHops.find(dstKey);
            if (itDag == m_dagNextHops.end())
                continue;

            auto itSw = itDag->second.find(sw);
            if (itSw == itDag->second.end())
                continue;

            const std::vector<uint32_t>& actions = itSw->second;
            if (actions.empty())
                continue;

            EnsureQ(dstKey);
            auto& Q = m_Q[dstKey];

            if (sw >= Q.size() || Q[sw].size() != actions.size())
                continue;

            uint32_t a = ArgMax(Q[sw]);
            uint32_t nextSw = actions[a];

            /* Get the port idx */
            uint32_t idx;
            bool found = NeighborToPort(sw, nextSw, &idx);
            double r = (found) ? RewardForChoice(sw, idx, qlens) : 0.0;
            double nextMax = 0.0;
            if (nextSw < nSwitches && nextSw < Q.size() && !Q[nextSw].empty())
            {
                nextMax = MaxRow(Q[nextSw]);
            }

            Q[sw][a] = (1 - m_alpha) * Q[sw][a] + m_LearningRate * (r + m_DiscountFactor * nextMax - Q[sw][a]);

            if (!found)
            {
                continue;
            }

            /* Adj indexing starts at 0 but ports in bmv2 start and 1 + port=1 is host */
            idx += 2;
            swRules[k] = idx;
        }

        /* Add own rule */
        auto ipIt = m_destinations.find("h" + std::to_string(sw));
        if (ipIt != m_destinations.end())
        {
            uint8_t buf[4];
            ipIt->second.Serialize(buf);
            std::string k(reinterpret_cast<char*>(buf), 4);
            swRules[k] = 1;
        }

        m_nextInstallPeriod[sw] =
            Simulator::Schedule(m_installPeriod, &QlrController::InstallP4Rules, this, sw, swRules);
    }

    void DoControlLogic(const std::unordered_map<uint32_t, std::vector<uint64_t>>& qlens)
    {
        const uint32_t nSwitches = m_switches.GetN();
        for (uint32_t sw = 0; sw < nSwitches; ++sw)
        {
            DoQLearning(sw, qlens);
        }
    }

    std::vector<int> BfsParentTowardRoot(uint32_t root) const
    {
        uint32_t n = m_switches.GetN();
        std::vector<int> parent(n, -1);

        std::queue<uint32_t> q;
        parent[root] = static_cast<int>(root);
        q.push(root);

        while (!q.empty())
        {
            uint32_t u = q.front();
            q.pop();

            for (uint32_t v : m_adj[u])
            {
                if (parent[v] == -1)
                {
                    parent[v] = static_cast<int>(u);
                    q.push(v);
                }
            }
        }

        return parent;
    }

    std::unordered_map<std::string, uint32_t> BuildBfsRulesForSwitch(uint32_t sw)
    {
        std::unordered_map<std::string, uint32_t> swRules;

        uint32_t n = m_switches.GetN();
        if (m_hosts.GetN() != n)
        {
            NS_FATAL_ERROR("hostsVector size must equal number of switches");
        }

        for (uint32_t dstIdx = 0; dstIdx < n; ++dstIdx)
        {
            std::string dstKey = m_hostPrefix + std::to_string(dstIdx);

            auto itAddr = m_destinations.find(dstKey);
            if (itAddr == m_destinations.end())
                continue;

            uint8_t buf[4];
            itAddr->second.Serialize(buf);
            std::string ipKey(reinterpret_cast<char*>(buf), 4);

            uint32_t root = dstIdx;
            if (sw == root)
            {
                swRules[ipKey] = 1;
                continue;
            }

            auto parent = BfsParentTowardRoot(root);
            int p = parent[sw];
            if (p < 0)
            {
                continue;
            }

            uint32_t nextSw = static_cast<uint32_t>(p);
            uint32_t outPort;
            bool found = NeighborToPort(sw, nextSw, &outPort);
            if (!found)
            {
                continue;
            }

            swRules[ipKey] = outPort + 2;
        }

        return swRules;
    }

    void Tick()
    {
        if (m_running)
        {
            m_running = false;
            auto qlens = GetQLengths();
            DoControlLogic(qlens);
        }

        m_nextControlPeriod = Simulator::Schedule(m_controlPeriod, &QlrController::Tick, this);
    }

    void SwitchInit(Ptr<P4SwitchNetDevice> sw)
    {
        Ptr<Node> n = sw->GetNode();
        auto idxIt = m_nodeToSwIndex.find(n);
        if (idxIt == m_nodeToSwIndex.end())
        {
            return;
        }

        /* Do BFS when the switch boots */
        auto swRules = BuildBfsRulesForSwitch(idxIt->second);
        m_updIpToPort[idxIt->second] = std::move(swRules);
        InstallP4Rules(idxIt->second, m_updIpToPort[idxIt->second]);
    }

  private:
    /* Generic constants */
    static constexpr uint32_t kInfDist = std::numeric_limits<uint32_t>::max();
    const std::string m_hostPrefix = "h";

    /* QLearning hyperparameters */
    double m_alpha = 0.1;
    double m_LearningRate = 0.5;
    double m_DiscountFactor = 0.3;

    bool m_running = false;
    Time m_controlPeriod = MilliSeconds(50);
    Time m_installPeriod = MilliSeconds(20);
    EventId m_nextControlPeriod;
    std::vector<EventId> m_nextInstallPeriod;

    /* Containers */
    NodeContainer m_switches;
    NodeContainer m_hosts;
    std::map<Ptr<Node>, Ptr<P4SwitchNetDevice>> m_p4SwitchMap;
    std::unordered_map<Ptr<Node>, uint32_t> m_nodeToSwIndex;
    std::unordered_map<std::string, Ipv4Address> m_destinations;
    std::vector<std::vector<uint32_t>> m_adj;
    std::unordered_map<std::string, std::unordered_map<uint32_t, std::vector<uint32_t>>>
        m_dagNextHops;

    std::unordered_map<std::string, std::vector<std::vector<double>>> m_Q;

    std::unordered_map<uint32_t, std::unordered_map<std::string, uint32_t>> m_updIpToPort;
};

#endif