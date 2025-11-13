#include "workload_parser.h"

#include <fstream>
#include <sstream>
#include <stdexcept>
#include <algorithm>
#include <cctype>
#include <limits>

static inline void trim_inplace(std::string &s) {
    while (!s.empty() && std::isspace((unsigned char)s.front())) s.erase(s.begin());
    while (!s.empty() && std::isspace((unsigned char)s.back())) s.pop_back();
}

static unsigned long parseUnsigned(const std::string &s, const std::string &fieldName, const std::string &line) {
    try {
        size_t pos = 0;
        unsigned long val = std::stoul(s, &pos, 10);
        if (pos != s.size()) throw std::invalid_argument("trailing chars");
        return val;
    } catch (const std::exception &e) {
        throw std::runtime_error("Invalid numeric field '" + fieldName + "' in line: " + line + " (" + e.what() + ")");
    }
}

std::vector<WorkloadFlow> WorkloadParser::parseFile(std::string filename) {
    std::vector<WorkloadFlow> workloads;
    std::ifstream file(filename);
    if (!file.is_open()) {
        throw std::runtime_error("Unable to open file: " + filename);
    }

    std::string line;
    while (std::getline(file, line)) {
        // skip empty or comment lines
        bool all_ws = std::all_of(line.begin(), line.end(), [](unsigned char c){ return std::isspace(c); });
        if (all_ws) continue;
        trim_inplace(line);
        if (line.empty() || line.front() == '#') continue;

        std::istringstream ss(line);
        WorkloadFlow wl;
        std::string srcStr, dstStr, startStr, endStr, protoStr, portStr, dataRateStr, packetSizeStr, dataSizeStr, flowsNumberStr;

        // Parse comma-separated values. Expect up to 9 fields but tolerate missing trailing fields.
        if (!std::getline(ss, srcStr, ',')) continue;
        if (!std::getline(ss, dstStr, ',')) continue;
        if (!std::getline(ss, startStr, ',')) continue;
        if (!std::getline(ss, endStr, ',')) continue;
        if (!std::getline(ss, protoStr, ',')) continue;
        if (!std::getline(ss, portStr, ',')) continue;
        if (!std::getline(ss, dataRateStr, ',')) continue;
        if (!std::getline(ss, packetSizeStr, ',')) continue;
        if (!std::getline(ss, dataSizeStr, ',')) dataSizeStr.clear(); // allow empty
        if (!std::getline(ss, flowsNumberStr)) flowsNumberStr.clear(); // optional final field

        // Trim individual fields
        trim_inplace(srcStr); trim_inplace(dstStr);
        trim_inplace(startStr); trim_inplace(endStr);
        trim_inplace(protoStr); trim_inplace(portStr);
        trim_inplace(dataRateStr); trim_inplace(packetSizeStr); trim_inplace(dataSizeStr);
        trim_inplace(flowsNumberStr);

        try {
            // sourceId / destinationId
            unsigned long srcId = parseUnsigned(srcStr, "sourceId", line);
            unsigned long dstId = parseUnsigned(dstStr, "destinationId", line);
            if (srcId > std::numeric_limits<u_int16_t>::max() || dstId > std::numeric_limits<u_int16_t>::max()) {
                throw std::runtime_error("source/destination id out of range in line: " + line);
            }
            wl.sourceId = static_cast<u_int16_t>(srcId);
            wl.destinationId = static_cast<u_int16_t>(dstId);

            // start / end times
            wl.startTime = std::stod(startStr);
            wl.endTime = std::stod(endStr);

            // protocol: accept numeric or names ("tcp"/"udp")
            if (!protoStr.empty()) {
                // try numeric first
                try {
                    unsigned long p = parseUnsigned(protoStr, "protocol", line);
                    if (p > std::numeric_limits<u_int16_t>::max()) throw std::runtime_error("protocol out of range");
                    wl.protocol = static_cast<u_int16_t>(p);
                } catch (...) {
                    // fallback to textual names
                    std::string protoLower = protoStr;
                    std::transform(protoLower.begin(), protoLower.end(), protoLower.begin(), [](unsigned char c){ return std::tolower(c); });
                    if (protoLower == "tcp") wl.protocol = 6;
                    else if (protoLower == "udp") wl.protocol = 17;
                    else throw std::runtime_error("Unknown protocol string '" + protoStr + "' in line: " + line);
                }
            }

            // dstPort (may be zero)
            if (!portStr.empty()) {
                unsigned long p = parseUnsigned(portStr, "dstPort", line);
                if (p > std::numeric_limits<u_int16_t>::max()) throw std::runtime_error("dstPort out of range in line: " + line);
                wl.dstPort = static_cast<u_int16_t>(p);
            }

            // dataRate: keep as-is (may be "0" or "1Mbps")
            wl.dataRate = dataRateStr;

            if (!packetSizeStr.empty()) {
                unsigned long ps = parseUnsigned(packetSizeStr, "packetSize", line);
                if (ps > std::numeric_limits<u_int32_t>::max()) throw std::runtime_error("packetSize out of range in line: " + line);
                wl.packetSize = static_cast<u_int32_t>(ps);
            } else {
                wl.packetSize = 1400;
            }


            // dataSize: numeric (allow zero)
            if (!dataSizeStr.empty()) {
                unsigned long ds = parseUnsigned(dataSizeStr, "dataSize", line);
                if (ds > std::numeric_limits<u_int32_t>::max()) throw std::runtime_error("dataSize out of range in line: " + line);
                wl.dataSize = static_cast<u_int32_t>(ds);
            } else {
                wl.dataSize = 0;
            }


            // flowsNumber: optional, default 1
            if (!flowsNumberStr.empty()) {
                unsigned long fn = parseUnsigned(flowsNumberStr, "flowsNumber", line);
                if (fn == 0) {
                    // zero flows doesn't make sense; treat as error
                    throw std::runtime_error("flowsNumber must be >= 1 in line: " + line);
                }
                if (fn > std::numeric_limits<u_int32_t>::max()) throw std::runtime_error("flowsNumber out of range in line: " + line);
                wl.flowsNumber = static_cast<u_int32_t>(fn);
            } else {
                wl.flowsNumber = 1;
            }
        } catch (const std::exception &e) {
            throw; // propagate descriptive error
        }

        workloads.push_back(std::move(wl));
    }

    return workloads;
}