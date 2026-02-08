/* -*- P4_16 -*- */
#include <core.p4>
#include <v1model.p4>

#include "include/defines.p4"
#include "include/headers.p4"
#include "include/parser.p4"
#include "include/checksums.p4"

#define MIN_VALUE(i, j)                                                                 \
    min_value = row##i##_value[7:0];                                                    \
    min_index = 0;                                                                      \
    min8(min_value, row##i##_value[15:8], 1);                                           \
    min8(min_value, row##i##_value[23:16], 2);                                          \
    min8(min_value, row##i##_value[31:24], 3);                                          \
    min8(min_value, row##i##_value[39:32], 4);                                          \
    min8(min_value, row##i##_value[47:40], 5);                                          \
    min8(min_value, row##i##_value[55:48], 6);                                          \
    min8(min_value, row##i##_value[63:56], 7);                                          \
    log_msg("row {} min: {} - min_index: {}", {(bit<8>) ##i##, min_value, min_index});  \
    if (row_num != i) {                                                                 \
        hdr.qlr_updates[j].setValid();                                                  \
        hdr.qlr_updates[j].dst_id = i;                                                  \
        hdr.qlr_updates[j].value = min_value;                                           \
    } else {                                                                            \
        hdr.qlr_updates[j].setValid();                                                  \
        hdr.qlr_updates[j].dst_id = i;                                                  \
        hdr.qlr_updates[j].value = 0;                                                   \
        col_num = min_index;                                                            \
    }

control IngressPipe(inout headers hdr,
                    inout metadata meta,
                    inout standard_metadata_t standard_metadata) {
    register<bit<64>>(1) row1;
    register<bit<64>>(1) row2;
    register<bit<64>>(1) row3;
    register<bit<64>>(1) row4;
    register<bit<64>>(1) row5;
    register<bit<8>>(NODES_NUM) ig_qdepths;
    
    action drop() {
        mark_to_drop(standard_metadata);
    }
    
    /* Convert the IP prefix to a row number */
    bit<8> row_num = 0;    
    action get_row_num(bit<8> num) {
        row_num = num;
    }

    /* Selects the outgoing port of this packet */
    action set_nhop(bit<9> port) {
        standard_metadata.egress_spec = port;
        hdr.ipv4.ttl = hdr.ipv4.ttl - 1;
    }
    
    table select_row {
        key = {
            hdr.ipv4.dst_addr: lpm;
            hdr.ipv4.protocol: exact;
        }
        actions = {
            get_row_num;
            set_nhop;
            drop;
        }
        size = 1024;
        default_action = drop;
    }


    bit<8> probe_type = 0;
    action send_probe(bit<9> port, bit<8> num) {
        standard_metadata.egress_spec = port;
        hdr.ipv4.ttl = hdr.ipv4.ttl - 1;
        row_num = num;
        hdr.ipv4.ecn[1:1] = 0x1;
        probe_type = 1;
    }

    action process_probe() {
        mark_to_drop(standard_metadata);
        probe_type = 2;
    }

    table handle_update {
        key = {
            hdr.ipv4.dst_addr: lpm;
            hdr.ipv4.protocol: exact;
            meta.l4_lookup.dst_port: exact;
            meta.qlearning_probe: exact;
        }
        actions = {
            send_probe;
            process_probe;
        }
        size = 2;
    }


    bit<8> col_num = 0;
    table select_port_from_row_col {
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

    /* Get the ingress port qdepth and the port index */
    bit<8> ig_qdepth = 0;
    bit<32> ig_idx = 0;
    action get_ig_qdepth_and_idx(bit<32> idx) {
        ig_qdepths.read(ig_qdepth, idx);
        ig_idx = idx + 1;
        log_msg("Reading ig_qdepth idx: idx={} ig_idx={}", {idx, ig_idx});
        log_msg("Reading ig_qdepth: ig_qdepth={}", {ig_qdepth});
    }

    table read_ig_qdepth {
        key = {
            standard_metadata.ingress_port: exact;
        }
        actions = {
            get_ig_qdepth_and_idx;
        }
        size = 64;
    }

    /* Include the qmatrix_update actions and table */
    bit<64> row1_value = 0;
    bit<64> row2_value = 0;
    bit<64> row3_value = 0;
    bit<64> row4_value = 0;
    bit<64> row5_value = 0;
    #include "lut/qmatrix_update.p4"

    /* Include the qlr_pkt_updates actions and table */
    #include "lut/qlr_pkt_updates.p4"

    /* Helper to compute the min value */
    bit<8> min_value = 1;
    bit<8> min_index = 0;
    action min8(bit<8> a, bit<8> b, bit<8> index) {
        if (b < a) {
            min_value = b;
            min_index = index;
        } else {
            min_value = a;
        }

        log_msg("min8: a={} b={} curr_index={} min_value={} min_index={}", {a, b, index, min_value, min_index});
    }

    apply {
        bit<8> do_qlr = 2;
        /* Read ingress port qdepth and get the ingress port index */
        read_ig_qdepth.apply();

        /* Handle QLR packet or probe */
        if (!handle_update.apply().hit) {
            switch (select_row.apply().action_run) {
                get_row_num: {
                    do_qlr = 1;
                }
                set_nhop: {
                    do_qlr = 0;
                }
            }
        }

        if (meta.qlearning_update == 1 || probe_type == 2) {
            /* Update rows using the pkt information */
            qmatrix_update.apply();
        }
        if (do_qlr == 1 || probe_type == 1) {
            row1.read(row1_value, 0);
            row2.read(row2_value, 0);
            row3.read(row3_value, 0);
            row4.read(row4_value, 0);
            row5.read(row5_value, 0);
            MIN_VALUE(1, 0)
            MIN_VALUE(2, 1)
            MIN_VALUE(3, 2)
            MIN_VALUE(4, 3)
            MIN_VALUE(5, 4)
        }

        

        if (do_qlr == 1) {
            log_msg("selected destination: {} - selected col: {}", {row_num, col_num});
            select_port_from_row_col.apply();
            log_msg("selected port: {}", {standard_metadata.egress_spec});
        } else if (do_qlr == 0) {
            hdr.ipv4.ecn = 0x0;
            
            hdr.qlr_updates[0].setInvalid();
            hdr.qlr_updates[1].setInvalid();
            hdr.qlr_updates[2].setInvalid();
            hdr.qlr_updates[3].setInvalid();
            hdr.qlr_updates[4].setInvalid();
        }

        if (do_qlr == 1 || probe_type == 1) {
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
