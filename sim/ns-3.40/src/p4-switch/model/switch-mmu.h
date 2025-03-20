#ifndef SWITCH_MMU_H
#define SWITCH_MMU_H

#include <ns3/node.h>
#include <ns3/traced-callback.h>

#include <unordered_map>

namespace ns3
{

class Packet;

class SwitchMmu : public Object
{
  public:
    static const uint32_t pCnt = 257; // Number of ports used
    static const uint32_t qCnt = 8;   // Number of queues/priorities used

    static TypeId GetTypeId(void);

    SwitchMmu(void);

    uint64_t Threshold(uint32_t port, uint32_t qIndex, std::string inout);
    uint64_t DynamicThreshold(uint32_t port, uint32_t qIndex, std::string inout);

    bool CheckIngressAdmission(uint32_t port, uint32_t qIndex, uint32_t psize);
    void UpdateIngressAdmission(uint32_t port, uint32_t qIndex, uint32_t psize);
    void RemoveFromIngressAdmission(uint32_t port, uint32_t qIndex, uint32_t psize);

    bool CheckEgressAdmission(uint32_t port, uint32_t qIndex, uint32_t psize);
    void UpdateEgressAdmission(uint32_t port, uint32_t qIndex, uint32_t psize);
    void RemoveFromEgressAdmission(uint32_t port, uint32_t qIndex, uint32_t psize);

    void SetBufferPool(uint64_t b);

    void SetIngressPool(uint64_t b);

    void SetEgressPool(uint64_t b);

    void SetAlphaIngress(double value, uint32_t port, uint32_t q);
    void SetAlphaIngress(double value);

    void SetAlphaEgress(double value, uint32_t port, uint32_t q);
    void SetAlphaEgress(double value);

    uint64_t GetIngressBytes(uint32_t p, uint32_t q) { return ingress_bytes[p][q]; }
    uint64_t GetEgressBytes(uint32_t p, uint32_t q) { return egress_bytes[p][q]; }

    // config
    uint32_t node_id;

    // Buffer pools
    uint64_t bufferPool;
    uint64_t ingressPool;
    uint64_t egressPool;

    // aggregate run time
    uint64_t totalUsed;
    uint64_t egressPoolUsed;

    // buffer configuration.
    double alphaEgress[pCnt][qCnt];
    double alphaIngress[pCnt][qCnt];

    // per queue run time
    uint64_t ingress_bytes[pCnt][qCnt];
    uint64_t egress_bytes[pCnt][qCnt];
};

} /* namespace ns3 */

#endif /* SWITCH_MMU_H */
