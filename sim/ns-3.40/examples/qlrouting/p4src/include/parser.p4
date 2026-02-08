#ifndef __PARSER__
#define __PARSER__

#include "defines.p4"

parser PktParser(packet_in packet,
                 out headers hdr,
                 inout metadata meta,
                 inout standard_metadata_t standard_metadata) {
    state start {
        meta.l4_lookup = {0, 0};
        transition parse_ethernet;
    }

    state parse_ethernet {
        packet.extract(hdr.ethernet);
        transition select(hdr.ethernet.ether_type) {
            ETHERTYPE_IPV4: parse_ipv4;
            default: accept;
        }
    }

    state parse_ipv4 {
        packet.extract(hdr.ipv4);
        meta.qlearning_update = (bit<8>) hdr.ipv4.ecn[0:0];
        meta.qlearning_probe = (bit<8>) hdr.ipv4.ecn[1:1];
        transition select(hdr.ipv4.protocol) {
            PROTO_TCP: parse_tcp;
            PROTO_UDP: parse_udp;
            default: accept;
        }
    }

    state parse_tcp {
        packet.extract(hdr.tcp);
        meta.l4_lookup = {hdr.tcp.src_port, hdr.tcp.dst_port};
        bit<7> tcp_hdr_bytes_left = 4 * (bit<7>) (hdr.tcp.data_offset - 5);
        packet.extract(hdr.tcp_options, (bit<32>) (8 * (bit<32>) tcp_hdr_bytes_left));
        transition select(meta.qlearning_update) {
            1: parse_qlr_update;
            default: accept;
        }
    }

    state parse_udp {
        packet.extract(hdr.udp);
        meta.l4_lookup = {hdr.udp.src_port, hdr.udp.dst_port};
        transition select(meta.qlearning_update) {
            1: parse_qlr_update;
            default: accept;
        }
    }

    state parse_qlr_update {
        packet.extract(hdr.qlr_updates.next); 
        transition select(hdr.qlr_updates.last.has_next) {
            1: parse_qlr_update;
            default: accept;
        }
    }
}

control PktDeparser(packet_out packet, in headers hdr) {
    apply {
        packet.emit(hdr);
    }
}

#endif