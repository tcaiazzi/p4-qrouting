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
    action get_row_num(num) {
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
    bit<8> col_num;
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
    #include "lut/qlr_updates.p4"

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
        if (select_dst.apply().hit) {
            /* Update rows using the pkt information */
            qmatrix_update.apply();

            max_value = row1_value[7:0];
            max_index = 0;
            max8(max_value, row1_value[15:8], 1);
            max8(max_value, row1_value[23:16], 2);
            max8(max_value, row1_value[31:24], 3);
            max8(max_value, row1_value[39:32], 4);
            max8(max_value, row1_value[47:40], 5);
            max8(max_value, row1_value[55:48], 6);
            max8(max_value, row1_value[63:56], 7);
            log_msg("row1 max: {}", {max_value});
            
            if (row_num != 1) {
                hdr.qlr_updates[0].dst_id = 1;
                hdr.qlr_updates[0].value = max_value;
            } else {
                col_num = max_index;
            }

            max_value = row2_value[7:0];
            max_index = 0;
            max8(max_value, row2_value[15:8], 1);
            max8(max_value, row2_value[23:16], 2);
            max8(max_value, row2_value[31:24], 3);
            max8(max_value, row2_value[39:32], 4);
            max8(max_value, row2_value[47:40], 5);
            max8(max_value, row2_value[55:48], 6);
            max8(max_value, row2_value[63:56], 7);
            log_msg("row2 max: {}", {max_value});

            if (row_num != 2) {
                hdr.qlr_updates[1].dst_id = 2;
                hdr.qlr_updates[1].value = max_value;
            } else {
                col_num = max_index;
            }

            max_value = row3_value[7:0];
            max_index = 0;
            max8(max_value, row3_value[15:8], 1);
            max8(max_value, row3_value[23:16], 2);
            max8(max_value, row3_value[31:24], 3);
            max8(max_value, row3_value[39:32], 4);
            max8(max_value, row3_value[47:40], 5);
            max8(max_value, row3_value[55:48], 6);
            max8(max_value, row3_value[63:56], 7);
            log_msg("row3 max: {}", {max_value});
            if (row_num != 3) {
                hdr.qlr_updates[2].dst_id = 3;
                hdr.qlr_updates[2].value = max_value;
            } else {
                col_num = max_index;
            }

            max_value = row4_value[7:0];
            max_index = 0;
            max8(max_value, row4_value[15:8], 1);
            max8(max_value, row4_value[23:16], 2);
            max8(max_value, row4_value[31:24], 3);
            max8(max_value, row4_value[39:32], 4);
            max8(max_value, row4_value[47:40], 5);
            max8(max_value, row4_value[55:48], 6);
            max8(max_value, row4_value[63:56], 7);
            log_msg("row4 max: {}", {max_value});

            if (row_num != 4) {
                hdr.qlr_updates[3].dst_id = 4;
                hdr.qlr_updates[3].value = max_value;
            } else {
                col_num = max_index;
            }

            max_value = row5_value[7:0];
            max_index = 0;
            max8(max_value, row5_value[15:8], 1);
            max8(max_value, row5_value[23:16], 2);
            max8(max_value, row5_value[31:24], 3);
            max8(max_value, row5_value[39:32], 4);
            max8(max_value, row5_value[47:40], 5);
            max8(max_value, row5_value[55:48], 6);
            max8(max_value, row5_value[63:56], 7);
            log_msg("row5 max: {}", {max_value});

            if (row_num != 5) {
                hdr.qlr_updates[4].dst_id = 5;
                hdr.qlr_updates[4].value = max_value;
            } else {
                col_num = max_index;
            }

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
