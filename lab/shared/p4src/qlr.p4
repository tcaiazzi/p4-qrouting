/* -*- P4_16 -*- */
#include <core.p4>
#include <v1model.p4>

#include "include/defines.p4"
#include "include/headers.p4"
#include "include/parser.p4"
#include "include/checksums.p4"

#define MAX_VALUE(i, j)                                       \
    max_value = row##i##_value[7:0];                          \
    max_index = 0;                                            \
    max8(max_value, row##i##_value[15:8], 1);                 \
    max8(max_value, row##i##_value[23:16], 2);                \
    max8(max_value, row##i##_value[31:24], 3);                \
    max8(max_value, row##i##_value[39:32], 4);                \
    max8(max_value, row##i##_value[47:40], 5);                \
    max8(max_value, row##i##_value[55:48], 6);                \
    max8(max_value, row##i##_value[63:56], 7);                \
    log_msg("row ##i max: {}", {max_value});                  \
    if (row_num != i) {                                       \
        hdr.qlr_updates[j].dst_id = i;                        \
        hdr.qlr_updates[j].value = max_value;                 \
    } else {                                                  \
        col_num = max_index;                                  \
    }


control IngressPipe(inout headers hdr,
                    inout metadata meta,
                    inout standard_metadata_t standard_metadata) {
    register<bit<64>>(1) row1;
    register<bit<64>>(1) row2;
    register<bit<64>>(1) row3;
    register<bit<64>>(1) row4;
    register<bit<64>>(1) row5;
    
    action drop() {
        mark_to_drop(standard_metadata);
    }
    
    /* Convert the IP prefix to a row number */
    bit<8> row_num = 0;    
    action get_row_num(bit<8> num) {
        row_num = num;
    }
    
    table select_row {
        key = {
            hdr.ipv4.dst_addr: lpm;
        }
        actions = {
            get_row_num;
            drop;
        }
        size = NODES_NUM;
        default_action = drop;
    }

    /* Selects the outgoing port of this packet */
    bit<8> col_num = 0;
    action set_nhop(bit<9> port) {
        standard_metadata.egress_spec = port;
        hdr.ipv4.ttl = hdr.ipv4.ttl - 1;
    }

    table select_port_from_index {
        key = {
            row_num: exact;
            col_num: exact;
        }
        actions = {
            set_nhop;
            drop;
        }
        size = 1024;
        default_action = drop;
    }

    /* TODO: Add table to get the ig_qdepth */
    bit<8> ig_qdepth = 0;

    /* Include the qmatrix_update actions and table */
    bit<64> row1_value = 0;
    bit<64> row2_value = 0;
    bit<64> row3_value = 0;
    bit<64> row4_value = 0;
    bit<64> row5_value = 0;
    #include "lut/qmatrix_update.p4"

    /* Include the qlr_pkt_updates actions and table */
    #include "lut/qlr_pkt_updates.p4"

    /* Helper to compute the max value */
    bit<8> max_value = 0;
    bit<8> max_index = 0;
    action max8(bit<8> a, bit<8> b, bit<8> index) {
        if (a > b) {
            max_value = a;
        } else {
            max_value = b;
            max_index = index;
        }

        log_msg("max8: {} {} {}", {a, b, max_value});
    }

    apply {
        if (select_row.apply().hit) {
            /* Update rows using the pkt information */
            qmatrix_update.apply();

            MAX_VALUE(1, 0)
            MAX_VALUE(2, 1)
            MAX_VALUE(3, 2)
            MAX_VALUE(4, 3)
            MAX_VALUE(5, 4)

            log_msg("selected destination: {}", {row_num});
            select_port_from_index.apply();
            log_msg("selected port: {}", {standard_metadata.egress_spec});

            /* Activate update headers (table is populated from the DAGs) */
            qlr_pkt_updates.apply();
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
