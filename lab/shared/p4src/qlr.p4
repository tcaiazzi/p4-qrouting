/* -*- P4_16 -*- */
#include <core.p4>
#include <v1model.p4>

#include "include/defines.p4"
#include "include/headers.p4"
#include "include/parser.p4"
#include "include/checksums.p4"

control IngressPipe(inout headers hdr,
                    inout metadata meta,
                    inout standard_metadata_t standard_metadata) {
    register<bit<64>>(1) dst1;
    register<bit<64>>(1) dst2;
    register<bit<64>>(1) dst3;
    register<bit<64>>(1) dst4;
    register<bit<64>>(1) dst5;
    

    action drop() {
        mark_to_drop(standard_metadata);
    }

    action set_nhop(bit<9> port) {
        standard_metadata.egress_spec = port;
        hdr.ipv4.ttl = hdr.ipv4.ttl - 1;
    }

    bit<8> dst_num = 0;    
    bit<64> dst_value = 0;
    
    action get_dst1() {
        dst_num = 1;
        dst1.read(dst_value, 0);
    }

    action get_dst2() {
        dst_num = 2;
        dst2.read(dst_value, 0);
    }

    action get_dst3() {
        dst_num = 3;
        dst3.read(dst_value, 0);
    }

    action get_dst4() {
        dst_num = 4;
        dst4.read(dst_value, 0);
    }

    action get_dst5() {
        dst_num = 5;
        dst5.read(dst_value, 0);
    }
    
    table select_dst {
        key = {
            hdr.ipv4.dst_addr: lpm;
        }
        actions = {
            get_dst1;
            get_dst2;
            get_dst3;
            get_dst4;
            get_dst5;
            drop;
        }
        size = 1024;
        default_action = drop;
    }

    bit<8> max_value;
    action max8(bit<8> a, bit<8> b) {
        if(a > b){
            max_value = a;
        } else {
            max_value = b;
        }
    }

    bit<8> min_value;
    bit<8> min_index;
    action min8(bit<8> a, bit<8> b, bit<8> index) {
        if(a < b){
            min_value = a;
        } else {
            min_value = b;
            min_index = index;
        }
        log_msg("min8: {} {} {}", {a, b, min_value});
    }


    table select_port_from_index {
        key = {
            min_index: exact;
        }
        actions = {
            set_nhop;
            drop;
        }
        size = 1024;
        default_action = drop;
    }

    bit<8> current_qdepth;
    action set_qdepth(bit<8> qdepth) {
        current_qdepth = qdepth;
    }

    table get_qdepth {
        key = {
            standard_metadata.egress_spec: exact;
        }
        actions = {
            set_qdepth;
            drop;
        }
        size = 1024;
        default_action = drop;
    }

    apply {
        if (select_dst.apply().hit) {
            min_value = dst_value[7:0];
            min_index = 0;
            min8(min_value, dst_value[15:8], 1);
            min8(min_value, dst_value[23:16], 2);
            min8(min_value, dst_value[31:24], 3);
            min8(min_value, dst_value[39:32], 4);
            min8(min_value, dst_value[47:40], 5);
            min8(min_value, dst_value[55:48], 6);
            min8(min_value, dst_value[63:56], 7);
            log_msg("min: {}", {min_value});
            select_port_from_index.apply();
            log_msg("selected port: {}", {standard_metadata.egress_spec});
        }
    }
}

control EgressPipe(inout headers hdr,
                   inout metadata meta,
                   inout standard_metadata_t standard_metadata) {
    apply {
        
    }
}

V1Switch(
    PktParser(),
    PktVerifyChecksum(),
    IngressPipe(),
    EgressPipe(),
    PktComputeChecksum(),
    PktDeparser()
) main;
