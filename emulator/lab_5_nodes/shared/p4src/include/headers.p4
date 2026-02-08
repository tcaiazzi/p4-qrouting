#ifndef __HEADERS__
#define __HEADERS__

#include "defines.p4"

#define MAX_SEGMENTS 10

header ethernet_h {
    mac_addr_t dst_addr;
    mac_addr_t src_addr;
    bit<16> ether_type;
}

header ipv4_h {
    bit<4>    version;
    bit<4>    ihl;
    bit<6>    dscp;
    bit<2>    ecn;
    bit<16>   total_len;
    bit<16>   identification;
    bit<3>    flags;
    bit<13>   frag_offset;
    bit<8>    ttl;
    bit<8>    protocol;
    bit<16>   hdr_checksum;
    ipv4_addr_t src_addr;
    ipv4_addr_t dst_addr;
}

header tcp_h {
    bit<16> src_port;
    bit<16> dst_port;
    bit<32> seq_no;
    bit<32> ack_no;
    bit<4>  data_offset;
    bit<3>  res;
    bit<3>  ecn;
    bit<6>  ctrl;
    bit<16> window;
    bit<16> checksum;
    bit<16> urgent_ptr;
}

header tcp_options_h {
    varbit<256> options;
}

header udp_h {
    bit<16> src_port;
    bit<16> dst_port;
    bit<16> len;
    bit<16> checksum;
}

header qlr_h {
    bit<8> last_byte;
}

header qlr_update_h {
    bit<8> dst_id;
    bit<8> value;
    bit<8> has_next; 
}

struct metadata {
    l4_lookup_t l4_lookup;
    bit<8> qlearning_update;
}

struct headers {
    ethernet_h ethernet;
    ipv4_h ipv4;
    tcp_h tcp;
    tcp_options_h tcp_options;
    udp_h udp;
    qlr_h qlr;
    qlr_update_h[NODES_NUM] qlr_updates;
}

#endif