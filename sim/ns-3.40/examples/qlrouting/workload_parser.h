#ifndef WORKLOAD_PARSER_H
#define WORKLOAD_PARSER_H

#include <string>
#include <vector>

struct WorkloadFlow {
    u_int16_t sourceId;
    u_int16_t destinationId;
    double startTime = 0.0;
    double endTime = 0.0;
    u_int16_t protocol = 0;
    u_int16_t dstPort = 0;
    std::string dataRate;
    u_int32_t packetSize = 1400;
    u_int32_t dataSize;
    u_int32_t flowsNumber = 1;
};

class WorkloadParser {
public:
    // Parse CSV file and return vector of Workload entries.
    // Throws std::runtime_error on file open failure or malformed numeric fields.
    static std::vector<WorkloadFlow> parseFile(std::string filename);
};

#endif // WORKLOAD_PARSER_H