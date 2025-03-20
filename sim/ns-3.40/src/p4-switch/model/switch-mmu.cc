#include "switch-mmu.h"

#include "ns3/assert.h"
#include "ns3/boolean.h"
#include "ns3/global-value.h"
#include "ns3/log.h"
#include "ns3/object-vector.h"
#include "ns3/packet.h"
#include "ns3/pointer.h"
#include "ns3/simulator.h"
#include "ns3/uinteger.h"

#include <fstream>
#include <iostream>

#define LOSSLESS 0
#define LOSSY 1
#define DUMMY 2

#define DT 101
#define FAB 102
#define CS 103
#define IB 104
#define ABM 110
#define REVERIE 111

NS_LOG_COMPONENT_DEFINE("SwitchMmu");

namespace ns3
{
TypeId
SwitchMmu::GetTypeId(void)
{
    static TypeId tid = TypeId("ns3::SwitchMmu").SetParent<Object>().AddConstructor<SwitchMmu>();
    return tid;
}

/*
We model the switch shared memory (purely based on our understanding and experience).
The switch has an on-chip buffer which has `bufferPool` size.
This buffer is shared across all port and queues in the switch.

`bufferPool` is further split into multiple pools at the ingress and egress.

It would be easier to understand from here on if you consider Ingress/Egress are merely just
counters. These are not separate buffer locations or chips...!

First, `ingressPool` (size) accounts for ingress buffering shared by both lossy and lossless
traffic. Additionally, there exists a headroom pool of size xoffTotal, and each queue may use
xoff[port][q] configurable amount at each port p and queue q. When a queue at the ingress exceeds
its ingress threshold, a PFC pause message is sent and any incoming packets can use upto a maximum
of xoff[port][q] headroom.

Second, at the egress, `egressPool[LOSSY]` (size) accounts for buffering lossy traffic at the egress
and similarly `egressPool[LOSSLESS]` for lossless traffic.
*/

SwitchMmu::SwitchMmu(void)
{
    // Here we just initialize some default values.
    // The buffer can be configured using Set functions through the simulation file later.
    // Buffer pools
    bufferPool = 24 * 1024 * 1024; // ASIC buffer size i.e, total shared buffer
    // Size of ingress pool. Note: This is shared by both lossless and lossy traffic.
    ingressPool = 18 * 1024 * 1024;
    egressPool = 24 * 1024 * 1024; // Size of egress lossy pool.

    // aggregate run time
    // `totalUsed` IMPORTANT TO NOTE: THIS IS NOT bytes in the "ingress pool".
    // This is the total bytes USED in the switch buffer, which includes occupied buffer in reserved
    // + headroom + ingresspool.
    totalUsed = 0;
    egressPoolUsed = 0; // Total bytes USED in the egress pool
    // It is sometimes useful to keep track of total bytes used specifically from ingressPool. We
    // don't need an additional variable. This is equal to (totalUsed - xoffTotalUsed).
    for (uint32_t port = 0; port < pCnt; port++)
    {
        for (uint32_t q = 0; q < qCnt; q++)
        {
            // buffer configuration.
            alphaEgress[port][q] =
                1; // per queue alpha value used by Buffer Management/PFC Threshold at egress
            alphaIngress[port][q] =
                1; // per queue alpha value used by Buffer Management/PFC Threshold at ingress

            // per queue run time
            ingress_bytes[port][q] =
                0; // total ingress bytes USED at each queue. This includes, bytes from reserved,
                   // ingress pool as well as any headroom.
            egress_bytes[port][q] = 0; // Per queue egress bytes USED at each queue
        }
    }

    memset(ingress_bytes, 0, sizeof(ingress_bytes));
    memset(egress_bytes, 0, sizeof(egress_bytes));
}

void
SwitchMmu::SetBufferPool(uint64_t b)
{
    bufferPool = b;
}

void
SwitchMmu::SetIngressPool(uint64_t b)
{
    ingressPool = b;
}

void
SwitchMmu::SetEgressPool(uint64_t b)
{
    egressPool = b;
}

void
SwitchMmu::SetAlphaIngress(double value, uint32_t port, uint32_t q)
{
    alphaIngress[port][q] = value;
}

void
SwitchMmu::SetAlphaIngress(double value)
{
    for (uint32_t port = 0; port < pCnt; port++)
    {
        for (uint32_t q = 0; q < qCnt; q++)
        {
            alphaIngress[port][q] = value;
        }
    }
}

void
SwitchMmu::SetAlphaEgress(double value, uint32_t port, uint32_t q)
{
    alphaEgress[port][q] = value;
}

void
SwitchMmu::SetAlphaEgress(double value)
{
    for (uint32_t port = 0; port < pCnt; port++)
    {
        for (uint32_t q = 0; q < qCnt; q++)
        {
            alphaEgress[port][q] = value;
        }
    }
}

uint64_t
SwitchMmu::Threshold(uint32_t port, uint32_t qIndex, std::string inout)
{
    uint64_t thresh = DynamicThreshold(port, qIndex, inout);
    return thresh;
}

// DT's threshold = Alpha x remaining.
// A sky high threshold for a queue can be emulated by setting the corresponding alpha to a large
// value. eg., UINT32_MAX
uint64_t
SwitchMmu::DynamicThreshold(uint32_t port, uint32_t qIndex, std::string inout)
{
    if (inout == "ingress")
    {
        double remaining = 0;
        uint64_t ingressPoolSharedUsed = totalUsed;
        uint64_t ingressSharedPool = ingressPool;
        if (ingressSharedPool > ingressPoolSharedUsed)
        {
            uint64_t remaining = ingressSharedPool - ingressPoolSharedUsed;
            return std::min(uint64_t(alphaIngress[port][qIndex] * (remaining)),
                            UINT64_MAX - 1024 * 1024);
        }
        else
        {
            // ingressPoolShared is full. There is no `remaining` buffer in ingressPoolShared.
            // DT's threshold returns zero in this case, but using if else just to avoid threshold
            // computations even in the simple case.
            return 0;
        }
    }
    else if (inout == "egress")
    {
        double remaining = 0;
        if (egressPool > egressPoolUsed)
        {
            uint64_t remaining = egressPool - egressPoolUsed;
            // UINT64_MAX - 1024*1024 is just a randomly chosen big value.
            // Just don't want to return UINT64_MAX value, sometimes causes overflow issues later.
            uint64_t threshold = std::min(uint64_t(alphaEgress[port][qIndex] * (remaining)),
                                          UINT64_MAX - 1024 * 1024);
            return threshold;
        }
        else
        {
            return 0;
        }
    }
}

bool
SwitchMmu::CheckIngressAdmission(uint32_t port, uint32_t qIndex, uint32_t psize)
{
    // if ingress bytes is greater than the ingress threshold
    if ((psize + ingress_bytes[port][qIndex] > Threshold(port, qIndex, "ingress"))
        // or if the ingress pool is full
        || (psize + totalUsed > ingressPool)
        // or if the switch buffer is full
        || (psize + totalUsed > bufferPool))
    {
        return false;
    }
    else
    {
        return true;
    }
}

void
SwitchMmu::UpdateIngressAdmission(uint32_t port, uint32_t qIndex, uint32_t psize)
{
    // NOTE: ingress_bytes simple counts total bytes occupied by port, qIndex,
    ingress_bytes[port][qIndex] += psize;
    totalUsed += psize; // IMPORTANT: totalUsed is only updated in the ingress. No need to update in
                        // egress. Avoid double counting.
}

void
SwitchMmu::RemoveFromIngressAdmission(uint32_t port, uint32_t qIndex, uint32_t psize)
{
    // If else are simply unnecessary but its a safety check to avoid magic scenarios (if a packet
    // vanishes in the buffer) where we might assign negative value to unsigned intergers.
    if (ingress_bytes[port][qIndex] >= psize)
        ingress_bytes[port][qIndex] -= psize;
    else
        ingress_bytes[port][qIndex] = 0;

    if (totalUsed >= psize) // IMPORTANT: totalUsed is only updated in the ingress. No need to
                            // update in egress. Avoid double counting.
        totalUsed -= psize;
    else
        totalUsed = 0;
}

bool
SwitchMmu::CheckEgressAdmission(uint32_t port, uint32_t qIndex, uint32_t psize)
{
    // if the egress queue length is greater than the threshold
    if ((psize + egress_bytes[port][qIndex] > Threshold(port, qIndex, "egress"))
        // or if the egress pool is full
        || (psize + egressPoolUsed > egressPool)
        // or if the switch buffer is full
        || (psize + totalUsed > bufferPool))
    {
        return false;
    }
    else
    {
        return true;
    }

    return true;
}

void
SwitchMmu::UpdateEgressAdmission(uint32_t port, uint32_t qIndex, uint32_t psize)
{
    egress_bytes[port][qIndex] += psize;
    egressPoolUsed += psize;
}

void
SwitchMmu::RemoveFromEgressAdmission(uint32_t port, uint32_t qIndex, uint32_t psize)
{
    if (egress_bytes[port][qIndex] >= psize)
        egress_bytes[port][qIndex] -= psize;
    else
        egress_bytes[port][qIndex] = 0;

    if (egressPoolUsed >= psize)
        egressPoolUsed -= psize;
    else
        egressPoolUsed = 0;
}
} // namespace ns3
