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

header tcp_option_end_h {
    bit<8> kind;
}

header tcp_option_nop_h {
    bit<8> kind;
}

header tcp_option_ss_h {
    bit<8>  kind;
    bit<32> maxSegmentSize;
}

header tcp_option_s_h {
    bit<8>  kind;
    bit<24> scale;
}

header tcp_option_sack_h {
    bit<8>         kind;
    bit<8>         length;
    varbit<256>    sack;
}

header_union tcp_option_h {
    tcp_option_end_h  end;
    tcp_option_nop_h  nop;
    tcp_option_ss_h   ss;
    tcp_option_s_h    s;
    tcp_option_sack_h sack;
}

// Defines a stack of 10 tcp options
typedef tcp_option_h[10] tcp_option_stack;

header tcp_option_padding_h {
    varbit<256> padding;
}

error {
    TcpDataOffsetTooSmall,
    TcpOptionTooLongForHeader,
    TcpBadSackOptionLength
}

struct tcp_option_sack_top
{
    bit<8> kind;
    bit<8> length;
}

header udp_h {
    bit<16> src_port;
    bit<16> dst_port;
    bit<16> len;
    bit<16> checksum;
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
    tcp_option_stack tcp_options_vec;
    tcp_option_padding_h tcp_options_padding;
    udp_h udp;
    qlr_update_h[NODES_NUM] qlr_updates;
}

#endif