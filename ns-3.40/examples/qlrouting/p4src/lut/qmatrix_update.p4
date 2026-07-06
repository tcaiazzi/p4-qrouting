#ifndef __QMATRIX_UPDATE__
#define __QMATRIX_UPDATE__

action qmatrix_update_r1_c1() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[7:0]});
    row1_value[7:0] = row1_value[7:0] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[7:0]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[7:0]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r1_c2() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[15:8]});
    row1_value[15:8] = row1_value[15:8] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[15:8]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[15:8]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r1_c3() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[23:16]});
    row1_value[23:16] = row1_value[23:16] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[23:16]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[23:16]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r1_c4() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[31:24]});
    row1_value[31:24] = row1_value[31:24] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[31:24]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[31:24]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r1_c5() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[39:32]});
    row1_value[39:32] = row1_value[39:32] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[39:32]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[39:32]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r1_c6() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[47:40]});
    row1_value[47:40] = row1_value[47:40] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[47:40]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[47:40]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r1_c7() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[55:48]});
    row1_value[55:48] = row1_value[55:48] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[55:48]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[55:48]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r1_c8() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[63:56]});
    row1_value[63:56] = row1_value[63:56] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[63:56]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[63:56]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r1_r2_c1() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[7:0]});
    row1_value[7:0] = row1_value[7:0] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[7:0]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[7:0]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[7:0]});
    row2_value[7:0] = row2_value[7:0] + (color_weights[15:8] + hdr.qlr_updates[1].value - row2_value[7:0]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[7:0]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r1_r2_c2() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[15:8]});
    row1_value[15:8] = row1_value[15:8] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[15:8]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[15:8]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[15:8]});
    row2_value[15:8] = row2_value[15:8] + (color_weights[15:8] + hdr.qlr_updates[1].value - row2_value[15:8]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[15:8]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r1_r2_c3() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[23:16]});
    row1_value[23:16] = row1_value[23:16] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[23:16]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[23:16]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[23:16]});
    row2_value[23:16] = row2_value[23:16] + (color_weights[15:8] + hdr.qlr_updates[1].value - row2_value[23:16]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[23:16]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r1_r2_c4() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[31:24]});
    row1_value[31:24] = row1_value[31:24] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[31:24]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[31:24]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[31:24]});
    row2_value[31:24] = row2_value[31:24] + (color_weights[15:8] + hdr.qlr_updates[1].value - row2_value[31:24]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[31:24]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r1_r2_c5() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[39:32]});
    row1_value[39:32] = row1_value[39:32] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[39:32]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[39:32]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[39:32]});
    row2_value[39:32] = row2_value[39:32] + (color_weights[15:8] + hdr.qlr_updates[1].value - row2_value[39:32]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[39:32]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r1_r2_c6() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[47:40]});
    row1_value[47:40] = row1_value[47:40] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[47:40]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[47:40]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[47:40]});
    row2_value[47:40] = row2_value[47:40] + (color_weights[15:8] + hdr.qlr_updates[1].value - row2_value[47:40]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[47:40]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r1_r2_c7() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[55:48]});
    row1_value[55:48] = row1_value[55:48] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[55:48]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[55:48]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[55:48]});
    row2_value[55:48] = row2_value[55:48] + (color_weights[15:8] + hdr.qlr_updates[1].value - row2_value[55:48]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[55:48]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r1_r2_c8() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[63:56]});
    row1_value[63:56] = row1_value[63:56] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[63:56]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[63:56]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[63:56]});
    row2_value[63:56] = row2_value[63:56] + (color_weights[15:8] + hdr.qlr_updates[1].value - row2_value[63:56]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[63:56]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r1_r2_r3_c1() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[7:0]});
    row1_value[7:0] = row1_value[7:0] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[7:0]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[7:0]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[7:0]});
    row2_value[7:0] = row2_value[7:0] + (color_weights[15:8] + hdr.qlr_updates[1].value - row2_value[7:0]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[7:0]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[7:0]});
    row3_value[7:0] = row3_value[7:0] + (color_weights[23:16] + hdr.qlr_updates[2].value - row3_value[7:0]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[7:0]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r1_r2_r3_c2() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[15:8]});
    row1_value[15:8] = row1_value[15:8] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[15:8]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[15:8]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[15:8]});
    row2_value[15:8] = row2_value[15:8] + (color_weights[15:8] + hdr.qlr_updates[1].value - row2_value[15:8]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[15:8]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[15:8]});
    row3_value[15:8] = row3_value[15:8] + (color_weights[23:16] + hdr.qlr_updates[2].value - row3_value[15:8]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[15:8]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r1_r2_r3_c3() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[23:16]});
    row1_value[23:16] = row1_value[23:16] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[23:16]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[23:16]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[23:16]});
    row2_value[23:16] = row2_value[23:16] + (color_weights[15:8] + hdr.qlr_updates[1].value - row2_value[23:16]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[23:16]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[23:16]});
    row3_value[23:16] = row3_value[23:16] + (color_weights[23:16] + hdr.qlr_updates[2].value - row3_value[23:16]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[23:16]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r1_r2_r3_c4() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[31:24]});
    row1_value[31:24] = row1_value[31:24] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[31:24]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[31:24]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[31:24]});
    row2_value[31:24] = row2_value[31:24] + (color_weights[15:8] + hdr.qlr_updates[1].value - row2_value[31:24]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[31:24]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[31:24]});
    row3_value[31:24] = row3_value[31:24] + (color_weights[23:16] + hdr.qlr_updates[2].value - row3_value[31:24]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[31:24]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r1_r2_r3_c5() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[39:32]});
    row1_value[39:32] = row1_value[39:32] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[39:32]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[39:32]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[39:32]});
    row2_value[39:32] = row2_value[39:32] + (color_weights[15:8] + hdr.qlr_updates[1].value - row2_value[39:32]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[39:32]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[39:32]});
    row3_value[39:32] = row3_value[39:32] + (color_weights[23:16] + hdr.qlr_updates[2].value - row3_value[39:32]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[39:32]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r1_r2_r3_c6() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[47:40]});
    row1_value[47:40] = row1_value[47:40] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[47:40]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[47:40]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[47:40]});
    row2_value[47:40] = row2_value[47:40] + (color_weights[15:8] + hdr.qlr_updates[1].value - row2_value[47:40]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[47:40]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[47:40]});
    row3_value[47:40] = row3_value[47:40] + (color_weights[23:16] + hdr.qlr_updates[2].value - row3_value[47:40]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[47:40]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r1_r2_r3_c7() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[55:48]});
    row1_value[55:48] = row1_value[55:48] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[55:48]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[55:48]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[55:48]});
    row2_value[55:48] = row2_value[55:48] + (color_weights[15:8] + hdr.qlr_updates[1].value - row2_value[55:48]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[55:48]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[55:48]});
    row3_value[55:48] = row3_value[55:48] + (color_weights[23:16] + hdr.qlr_updates[2].value - row3_value[55:48]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[55:48]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r1_r2_r3_c8() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[63:56]});
    row1_value[63:56] = row1_value[63:56] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[63:56]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[63:56]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[63:56]});
    row2_value[63:56] = row2_value[63:56] + (color_weights[15:8] + hdr.qlr_updates[1].value - row2_value[63:56]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[63:56]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[63:56]});
    row3_value[63:56] = row3_value[63:56] + (color_weights[23:16] + hdr.qlr_updates[2].value - row3_value[63:56]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[63:56]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r1_r2_r3_r4_c1() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[7:0]});
    row1_value[7:0] = row1_value[7:0] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[7:0]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[7:0]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[7:0]});
    row2_value[7:0] = row2_value[7:0] + (color_weights[15:8] + hdr.qlr_updates[1].value - row2_value[7:0]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[7:0]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[7:0]});
    row3_value[7:0] = row3_value[7:0] + (color_weights[23:16] + hdr.qlr_updates[2].value - row3_value[7:0]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[7:0]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[7:0]});
    row4_value[7:0] = row4_value[7:0] + (color_weights[31:24] + hdr.qlr_updates[3].value - row4_value[7:0]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[7:0]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r1_r2_r3_r4_c2() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[15:8]});
    row1_value[15:8] = row1_value[15:8] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[15:8]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[15:8]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[15:8]});
    row2_value[15:8] = row2_value[15:8] + (color_weights[15:8] + hdr.qlr_updates[1].value - row2_value[15:8]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[15:8]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[15:8]});
    row3_value[15:8] = row3_value[15:8] + (color_weights[23:16] + hdr.qlr_updates[2].value - row3_value[15:8]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[15:8]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[15:8]});
    row4_value[15:8] = row4_value[15:8] + (color_weights[31:24] + hdr.qlr_updates[3].value - row4_value[15:8]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[15:8]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r1_r2_r3_r4_c3() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[23:16]});
    row1_value[23:16] = row1_value[23:16] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[23:16]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[23:16]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[23:16]});
    row2_value[23:16] = row2_value[23:16] + (color_weights[15:8] + hdr.qlr_updates[1].value - row2_value[23:16]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[23:16]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[23:16]});
    row3_value[23:16] = row3_value[23:16] + (color_weights[23:16] + hdr.qlr_updates[2].value - row3_value[23:16]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[23:16]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[23:16]});
    row4_value[23:16] = row4_value[23:16] + (color_weights[31:24] + hdr.qlr_updates[3].value - row4_value[23:16]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[23:16]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r1_r2_r3_r4_c4() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[31:24]});
    row1_value[31:24] = row1_value[31:24] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[31:24]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[31:24]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[31:24]});
    row2_value[31:24] = row2_value[31:24] + (color_weights[15:8] + hdr.qlr_updates[1].value - row2_value[31:24]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[31:24]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[31:24]});
    row3_value[31:24] = row3_value[31:24] + (color_weights[23:16] + hdr.qlr_updates[2].value - row3_value[31:24]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[31:24]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[31:24]});
    row4_value[31:24] = row4_value[31:24] + (color_weights[31:24] + hdr.qlr_updates[3].value - row4_value[31:24]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[31:24]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r1_r2_r3_r4_c5() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[39:32]});
    row1_value[39:32] = row1_value[39:32] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[39:32]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[39:32]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[39:32]});
    row2_value[39:32] = row2_value[39:32] + (color_weights[15:8] + hdr.qlr_updates[1].value - row2_value[39:32]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[39:32]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[39:32]});
    row3_value[39:32] = row3_value[39:32] + (color_weights[23:16] + hdr.qlr_updates[2].value - row3_value[39:32]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[39:32]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[39:32]});
    row4_value[39:32] = row4_value[39:32] + (color_weights[31:24] + hdr.qlr_updates[3].value - row4_value[39:32]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[39:32]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r1_r2_r3_r4_c6() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[47:40]});
    row1_value[47:40] = row1_value[47:40] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[47:40]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[47:40]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[47:40]});
    row2_value[47:40] = row2_value[47:40] + (color_weights[15:8] + hdr.qlr_updates[1].value - row2_value[47:40]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[47:40]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[47:40]});
    row3_value[47:40] = row3_value[47:40] + (color_weights[23:16] + hdr.qlr_updates[2].value - row3_value[47:40]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[47:40]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[47:40]});
    row4_value[47:40] = row4_value[47:40] + (color_weights[31:24] + hdr.qlr_updates[3].value - row4_value[47:40]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[47:40]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r1_r2_r3_r4_c7() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[55:48]});
    row1_value[55:48] = row1_value[55:48] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[55:48]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[55:48]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[55:48]});
    row2_value[55:48] = row2_value[55:48] + (color_weights[15:8] + hdr.qlr_updates[1].value - row2_value[55:48]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[55:48]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[55:48]});
    row3_value[55:48] = row3_value[55:48] + (color_weights[23:16] + hdr.qlr_updates[2].value - row3_value[55:48]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[55:48]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[55:48]});
    row4_value[55:48] = row4_value[55:48] + (color_weights[31:24] + hdr.qlr_updates[3].value - row4_value[55:48]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[55:48]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r1_r2_r3_r4_c8() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[63:56]});
    row1_value[63:56] = row1_value[63:56] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[63:56]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[63:56]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[63:56]});
    row2_value[63:56] = row2_value[63:56] + (color_weights[15:8] + hdr.qlr_updates[1].value - row2_value[63:56]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[63:56]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[63:56]});
    row3_value[63:56] = row3_value[63:56] + (color_weights[23:16] + hdr.qlr_updates[2].value - row3_value[63:56]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[63:56]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[63:56]});
    row4_value[63:56] = row4_value[63:56] + (color_weights[31:24] + hdr.qlr_updates[3].value - row4_value[63:56]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[63:56]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r1_r2_r3_r4_r5_c1() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[7:0]});
    row1_value[7:0] = row1_value[7:0] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[7:0]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[7:0]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[7:0]});
    row2_value[7:0] = row2_value[7:0] + (color_weights[15:8] + hdr.qlr_updates[1].value - row2_value[7:0]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[7:0]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[7:0]});
    row3_value[7:0] = row3_value[7:0] + (color_weights[23:16] + hdr.qlr_updates[2].value - row3_value[7:0]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[7:0]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[7:0]});
    row4_value[7:0] = row4_value[7:0] + (color_weights[31:24] + hdr.qlr_updates[3].value - row4_value[7:0]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[7:0]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[7:0]});
    row5_value[7:0] = row5_value[7:0] + (color_weights[39:32] + hdr.qlr_updates[4].value - row5_value[7:0]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[7:0]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r1_r2_r3_r4_r5_c2() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[15:8]});
    row1_value[15:8] = row1_value[15:8] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[15:8]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[15:8]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[15:8]});
    row2_value[15:8] = row2_value[15:8] + (color_weights[15:8] + hdr.qlr_updates[1].value - row2_value[15:8]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[15:8]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[15:8]});
    row3_value[15:8] = row3_value[15:8] + (color_weights[23:16] + hdr.qlr_updates[2].value - row3_value[15:8]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[15:8]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[15:8]});
    row4_value[15:8] = row4_value[15:8] + (color_weights[31:24] + hdr.qlr_updates[3].value - row4_value[15:8]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[15:8]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[15:8]});
    row5_value[15:8] = row5_value[15:8] + (color_weights[39:32] + hdr.qlr_updates[4].value - row5_value[15:8]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[15:8]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r1_r2_r3_r4_r5_c3() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[23:16]});
    row1_value[23:16] = row1_value[23:16] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[23:16]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[23:16]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[23:16]});
    row2_value[23:16] = row2_value[23:16] + (color_weights[15:8] + hdr.qlr_updates[1].value - row2_value[23:16]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[23:16]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[23:16]});
    row3_value[23:16] = row3_value[23:16] + (color_weights[23:16] + hdr.qlr_updates[2].value - row3_value[23:16]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[23:16]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[23:16]});
    row4_value[23:16] = row4_value[23:16] + (color_weights[31:24] + hdr.qlr_updates[3].value - row4_value[23:16]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[23:16]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[23:16]});
    row5_value[23:16] = row5_value[23:16] + (color_weights[39:32] + hdr.qlr_updates[4].value - row5_value[23:16]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[23:16]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r1_r2_r3_r4_r5_c4() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[31:24]});
    row1_value[31:24] = row1_value[31:24] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[31:24]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[31:24]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[31:24]});
    row2_value[31:24] = row2_value[31:24] + (color_weights[15:8] + hdr.qlr_updates[1].value - row2_value[31:24]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[31:24]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[31:24]});
    row3_value[31:24] = row3_value[31:24] + (color_weights[23:16] + hdr.qlr_updates[2].value - row3_value[31:24]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[31:24]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[31:24]});
    row4_value[31:24] = row4_value[31:24] + (color_weights[31:24] + hdr.qlr_updates[3].value - row4_value[31:24]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[31:24]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[31:24]});
    row5_value[31:24] = row5_value[31:24] + (color_weights[39:32] + hdr.qlr_updates[4].value - row5_value[31:24]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[31:24]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r1_r2_r3_r4_r5_c5() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[39:32]});
    row1_value[39:32] = row1_value[39:32] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[39:32]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[39:32]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[39:32]});
    row2_value[39:32] = row2_value[39:32] + (color_weights[15:8] + hdr.qlr_updates[1].value - row2_value[39:32]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[39:32]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[39:32]});
    row3_value[39:32] = row3_value[39:32] + (color_weights[23:16] + hdr.qlr_updates[2].value - row3_value[39:32]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[39:32]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[39:32]});
    row4_value[39:32] = row4_value[39:32] + (color_weights[31:24] + hdr.qlr_updates[3].value - row4_value[39:32]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[39:32]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[39:32]});
    row5_value[39:32] = row5_value[39:32] + (color_weights[39:32] + hdr.qlr_updates[4].value - row5_value[39:32]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[39:32]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r1_r2_r3_r4_r5_c6() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[47:40]});
    row1_value[47:40] = row1_value[47:40] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[47:40]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[47:40]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[47:40]});
    row2_value[47:40] = row2_value[47:40] + (color_weights[15:8] + hdr.qlr_updates[1].value - row2_value[47:40]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[47:40]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[47:40]});
    row3_value[47:40] = row3_value[47:40] + (color_weights[23:16] + hdr.qlr_updates[2].value - row3_value[47:40]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[47:40]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[47:40]});
    row4_value[47:40] = row4_value[47:40] + (color_weights[31:24] + hdr.qlr_updates[3].value - row4_value[47:40]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[47:40]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[47:40]});
    row5_value[47:40] = row5_value[47:40] + (color_weights[39:32] + hdr.qlr_updates[4].value - row5_value[47:40]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[47:40]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r1_r2_r3_r4_r5_c7() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[55:48]});
    row1_value[55:48] = row1_value[55:48] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[55:48]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[55:48]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[55:48]});
    row2_value[55:48] = row2_value[55:48] + (color_weights[15:8] + hdr.qlr_updates[1].value - row2_value[55:48]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[55:48]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[55:48]});
    row3_value[55:48] = row3_value[55:48] + (color_weights[23:16] + hdr.qlr_updates[2].value - row3_value[55:48]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[55:48]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[55:48]});
    row4_value[55:48] = row4_value[55:48] + (color_weights[31:24] + hdr.qlr_updates[3].value - row4_value[55:48]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[55:48]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[55:48]});
    row5_value[55:48] = row5_value[55:48] + (color_weights[39:32] + hdr.qlr_updates[4].value - row5_value[55:48]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[55:48]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r1_r2_r3_r4_r5_c8() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[63:56]});
    row1_value[63:56] = row1_value[63:56] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[63:56]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[63:56]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[63:56]});
    row2_value[63:56] = row2_value[63:56] + (color_weights[15:8] + hdr.qlr_updates[1].value - row2_value[63:56]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[63:56]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[63:56]});
    row3_value[63:56] = row3_value[63:56] + (color_weights[23:16] + hdr.qlr_updates[2].value - row3_value[63:56]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[63:56]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[63:56]});
    row4_value[63:56] = row4_value[63:56] + (color_weights[31:24] + hdr.qlr_updates[3].value - row4_value[63:56]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[63:56]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[63:56]});
    row5_value[63:56] = row5_value[63:56] + (color_weights[39:32] + hdr.qlr_updates[4].value - row5_value[63:56]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[63:56]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r1_r2_r3_r5_c1() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[7:0]});
    row1_value[7:0] = row1_value[7:0] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[7:0]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[7:0]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[7:0]});
    row2_value[7:0] = row2_value[7:0] + (color_weights[15:8] + hdr.qlr_updates[1].value - row2_value[7:0]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[7:0]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[7:0]});
    row3_value[7:0] = row3_value[7:0] + (color_weights[23:16] + hdr.qlr_updates[2].value - row3_value[7:0]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[7:0]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[7:0]});
    row5_value[7:0] = row5_value[7:0] + (color_weights[39:32] + hdr.qlr_updates[3].value - row5_value[7:0]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[7:0]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r1_r2_r3_r5_c2() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[15:8]});
    row1_value[15:8] = row1_value[15:8] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[15:8]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[15:8]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[15:8]});
    row2_value[15:8] = row2_value[15:8] + (color_weights[15:8] + hdr.qlr_updates[1].value - row2_value[15:8]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[15:8]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[15:8]});
    row3_value[15:8] = row3_value[15:8] + (color_weights[23:16] + hdr.qlr_updates[2].value - row3_value[15:8]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[15:8]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[15:8]});
    row5_value[15:8] = row5_value[15:8] + (color_weights[39:32] + hdr.qlr_updates[3].value - row5_value[15:8]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[15:8]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r1_r2_r3_r5_c3() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[23:16]});
    row1_value[23:16] = row1_value[23:16] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[23:16]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[23:16]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[23:16]});
    row2_value[23:16] = row2_value[23:16] + (color_weights[15:8] + hdr.qlr_updates[1].value - row2_value[23:16]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[23:16]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[23:16]});
    row3_value[23:16] = row3_value[23:16] + (color_weights[23:16] + hdr.qlr_updates[2].value - row3_value[23:16]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[23:16]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[23:16]});
    row5_value[23:16] = row5_value[23:16] + (color_weights[39:32] + hdr.qlr_updates[3].value - row5_value[23:16]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[23:16]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r1_r2_r3_r5_c4() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[31:24]});
    row1_value[31:24] = row1_value[31:24] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[31:24]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[31:24]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[31:24]});
    row2_value[31:24] = row2_value[31:24] + (color_weights[15:8] + hdr.qlr_updates[1].value - row2_value[31:24]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[31:24]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[31:24]});
    row3_value[31:24] = row3_value[31:24] + (color_weights[23:16] + hdr.qlr_updates[2].value - row3_value[31:24]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[31:24]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[31:24]});
    row5_value[31:24] = row5_value[31:24] + (color_weights[39:32] + hdr.qlr_updates[3].value - row5_value[31:24]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[31:24]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r1_r2_r3_r5_c5() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[39:32]});
    row1_value[39:32] = row1_value[39:32] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[39:32]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[39:32]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[39:32]});
    row2_value[39:32] = row2_value[39:32] + (color_weights[15:8] + hdr.qlr_updates[1].value - row2_value[39:32]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[39:32]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[39:32]});
    row3_value[39:32] = row3_value[39:32] + (color_weights[23:16] + hdr.qlr_updates[2].value - row3_value[39:32]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[39:32]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[39:32]});
    row5_value[39:32] = row5_value[39:32] + (color_weights[39:32] + hdr.qlr_updates[3].value - row5_value[39:32]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[39:32]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r1_r2_r3_r5_c6() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[47:40]});
    row1_value[47:40] = row1_value[47:40] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[47:40]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[47:40]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[47:40]});
    row2_value[47:40] = row2_value[47:40] + (color_weights[15:8] + hdr.qlr_updates[1].value - row2_value[47:40]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[47:40]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[47:40]});
    row3_value[47:40] = row3_value[47:40] + (color_weights[23:16] + hdr.qlr_updates[2].value - row3_value[47:40]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[47:40]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[47:40]});
    row5_value[47:40] = row5_value[47:40] + (color_weights[39:32] + hdr.qlr_updates[3].value - row5_value[47:40]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[47:40]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r1_r2_r3_r5_c7() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[55:48]});
    row1_value[55:48] = row1_value[55:48] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[55:48]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[55:48]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[55:48]});
    row2_value[55:48] = row2_value[55:48] + (color_weights[15:8] + hdr.qlr_updates[1].value - row2_value[55:48]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[55:48]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[55:48]});
    row3_value[55:48] = row3_value[55:48] + (color_weights[23:16] + hdr.qlr_updates[2].value - row3_value[55:48]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[55:48]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[55:48]});
    row5_value[55:48] = row5_value[55:48] + (color_weights[39:32] + hdr.qlr_updates[3].value - row5_value[55:48]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[55:48]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r1_r2_r3_r5_c8() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[63:56]});
    row1_value[63:56] = row1_value[63:56] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[63:56]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[63:56]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[63:56]});
    row2_value[63:56] = row2_value[63:56] + (color_weights[15:8] + hdr.qlr_updates[1].value - row2_value[63:56]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[63:56]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[63:56]});
    row3_value[63:56] = row3_value[63:56] + (color_weights[23:16] + hdr.qlr_updates[2].value - row3_value[63:56]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[63:56]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[63:56]});
    row5_value[63:56] = row5_value[63:56] + (color_weights[39:32] + hdr.qlr_updates[3].value - row5_value[63:56]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[63:56]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r1_r2_r4_c1() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[7:0]});
    row1_value[7:0] = row1_value[7:0] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[7:0]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[7:0]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[7:0]});
    row2_value[7:0] = row2_value[7:0] + (color_weights[15:8] + hdr.qlr_updates[1].value - row2_value[7:0]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[7:0]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[7:0]});
    row4_value[7:0] = row4_value[7:0] + (color_weights[31:24] + hdr.qlr_updates[2].value - row4_value[7:0]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[7:0]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r1_r2_r4_c2() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[15:8]});
    row1_value[15:8] = row1_value[15:8] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[15:8]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[15:8]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[15:8]});
    row2_value[15:8] = row2_value[15:8] + (color_weights[15:8] + hdr.qlr_updates[1].value - row2_value[15:8]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[15:8]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[15:8]});
    row4_value[15:8] = row4_value[15:8] + (color_weights[31:24] + hdr.qlr_updates[2].value - row4_value[15:8]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[15:8]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r1_r2_r4_c3() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[23:16]});
    row1_value[23:16] = row1_value[23:16] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[23:16]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[23:16]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[23:16]});
    row2_value[23:16] = row2_value[23:16] + (color_weights[15:8] + hdr.qlr_updates[1].value - row2_value[23:16]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[23:16]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[23:16]});
    row4_value[23:16] = row4_value[23:16] + (color_weights[31:24] + hdr.qlr_updates[2].value - row4_value[23:16]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[23:16]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r1_r2_r4_c4() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[31:24]});
    row1_value[31:24] = row1_value[31:24] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[31:24]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[31:24]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[31:24]});
    row2_value[31:24] = row2_value[31:24] + (color_weights[15:8] + hdr.qlr_updates[1].value - row2_value[31:24]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[31:24]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[31:24]});
    row4_value[31:24] = row4_value[31:24] + (color_weights[31:24] + hdr.qlr_updates[2].value - row4_value[31:24]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[31:24]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r1_r2_r4_c5() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[39:32]});
    row1_value[39:32] = row1_value[39:32] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[39:32]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[39:32]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[39:32]});
    row2_value[39:32] = row2_value[39:32] + (color_weights[15:8] + hdr.qlr_updates[1].value - row2_value[39:32]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[39:32]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[39:32]});
    row4_value[39:32] = row4_value[39:32] + (color_weights[31:24] + hdr.qlr_updates[2].value - row4_value[39:32]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[39:32]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r1_r2_r4_c6() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[47:40]});
    row1_value[47:40] = row1_value[47:40] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[47:40]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[47:40]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[47:40]});
    row2_value[47:40] = row2_value[47:40] + (color_weights[15:8] + hdr.qlr_updates[1].value - row2_value[47:40]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[47:40]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[47:40]});
    row4_value[47:40] = row4_value[47:40] + (color_weights[31:24] + hdr.qlr_updates[2].value - row4_value[47:40]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[47:40]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r1_r2_r4_c7() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[55:48]});
    row1_value[55:48] = row1_value[55:48] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[55:48]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[55:48]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[55:48]});
    row2_value[55:48] = row2_value[55:48] + (color_weights[15:8] + hdr.qlr_updates[1].value - row2_value[55:48]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[55:48]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[55:48]});
    row4_value[55:48] = row4_value[55:48] + (color_weights[31:24] + hdr.qlr_updates[2].value - row4_value[55:48]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[55:48]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r1_r2_r4_c8() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[63:56]});
    row1_value[63:56] = row1_value[63:56] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[63:56]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[63:56]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[63:56]});
    row2_value[63:56] = row2_value[63:56] + (color_weights[15:8] + hdr.qlr_updates[1].value - row2_value[63:56]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[63:56]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[63:56]});
    row4_value[63:56] = row4_value[63:56] + (color_weights[31:24] + hdr.qlr_updates[2].value - row4_value[63:56]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[63:56]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r1_r2_r4_r5_c1() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[7:0]});
    row1_value[7:0] = row1_value[7:0] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[7:0]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[7:0]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[7:0]});
    row2_value[7:0] = row2_value[7:0] + (color_weights[15:8] + hdr.qlr_updates[1].value - row2_value[7:0]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[7:0]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[7:0]});
    row4_value[7:0] = row4_value[7:0] + (color_weights[31:24] + hdr.qlr_updates[2].value - row4_value[7:0]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[7:0]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[7:0]});
    row5_value[7:0] = row5_value[7:0] + (color_weights[39:32] + hdr.qlr_updates[3].value - row5_value[7:0]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[7:0]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r1_r2_r4_r5_c2() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[15:8]});
    row1_value[15:8] = row1_value[15:8] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[15:8]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[15:8]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[15:8]});
    row2_value[15:8] = row2_value[15:8] + (color_weights[15:8] + hdr.qlr_updates[1].value - row2_value[15:8]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[15:8]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[15:8]});
    row4_value[15:8] = row4_value[15:8] + (color_weights[31:24] + hdr.qlr_updates[2].value - row4_value[15:8]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[15:8]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[15:8]});
    row5_value[15:8] = row5_value[15:8] + (color_weights[39:32] + hdr.qlr_updates[3].value - row5_value[15:8]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[15:8]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r1_r2_r4_r5_c3() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[23:16]});
    row1_value[23:16] = row1_value[23:16] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[23:16]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[23:16]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[23:16]});
    row2_value[23:16] = row2_value[23:16] + (color_weights[15:8] + hdr.qlr_updates[1].value - row2_value[23:16]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[23:16]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[23:16]});
    row4_value[23:16] = row4_value[23:16] + (color_weights[31:24] + hdr.qlr_updates[2].value - row4_value[23:16]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[23:16]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[23:16]});
    row5_value[23:16] = row5_value[23:16] + (color_weights[39:32] + hdr.qlr_updates[3].value - row5_value[23:16]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[23:16]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r1_r2_r4_r5_c4() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[31:24]});
    row1_value[31:24] = row1_value[31:24] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[31:24]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[31:24]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[31:24]});
    row2_value[31:24] = row2_value[31:24] + (color_weights[15:8] + hdr.qlr_updates[1].value - row2_value[31:24]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[31:24]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[31:24]});
    row4_value[31:24] = row4_value[31:24] + (color_weights[31:24] + hdr.qlr_updates[2].value - row4_value[31:24]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[31:24]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[31:24]});
    row5_value[31:24] = row5_value[31:24] + (color_weights[39:32] + hdr.qlr_updates[3].value - row5_value[31:24]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[31:24]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r1_r2_r4_r5_c5() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[39:32]});
    row1_value[39:32] = row1_value[39:32] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[39:32]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[39:32]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[39:32]});
    row2_value[39:32] = row2_value[39:32] + (color_weights[15:8] + hdr.qlr_updates[1].value - row2_value[39:32]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[39:32]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[39:32]});
    row4_value[39:32] = row4_value[39:32] + (color_weights[31:24] + hdr.qlr_updates[2].value - row4_value[39:32]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[39:32]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[39:32]});
    row5_value[39:32] = row5_value[39:32] + (color_weights[39:32] + hdr.qlr_updates[3].value - row5_value[39:32]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[39:32]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r1_r2_r4_r5_c6() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[47:40]});
    row1_value[47:40] = row1_value[47:40] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[47:40]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[47:40]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[47:40]});
    row2_value[47:40] = row2_value[47:40] + (color_weights[15:8] + hdr.qlr_updates[1].value - row2_value[47:40]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[47:40]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[47:40]});
    row4_value[47:40] = row4_value[47:40] + (color_weights[31:24] + hdr.qlr_updates[2].value - row4_value[47:40]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[47:40]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[47:40]});
    row5_value[47:40] = row5_value[47:40] + (color_weights[39:32] + hdr.qlr_updates[3].value - row5_value[47:40]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[47:40]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r1_r2_r4_r5_c7() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[55:48]});
    row1_value[55:48] = row1_value[55:48] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[55:48]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[55:48]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[55:48]});
    row2_value[55:48] = row2_value[55:48] + (color_weights[15:8] + hdr.qlr_updates[1].value - row2_value[55:48]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[55:48]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[55:48]});
    row4_value[55:48] = row4_value[55:48] + (color_weights[31:24] + hdr.qlr_updates[2].value - row4_value[55:48]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[55:48]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[55:48]});
    row5_value[55:48] = row5_value[55:48] + (color_weights[39:32] + hdr.qlr_updates[3].value - row5_value[55:48]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[55:48]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r1_r2_r4_r5_c8() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[63:56]});
    row1_value[63:56] = row1_value[63:56] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[63:56]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[63:56]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[63:56]});
    row2_value[63:56] = row2_value[63:56] + (color_weights[15:8] + hdr.qlr_updates[1].value - row2_value[63:56]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[63:56]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[63:56]});
    row4_value[63:56] = row4_value[63:56] + (color_weights[31:24] + hdr.qlr_updates[2].value - row4_value[63:56]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[63:56]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[63:56]});
    row5_value[63:56] = row5_value[63:56] + (color_weights[39:32] + hdr.qlr_updates[3].value - row5_value[63:56]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[63:56]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r1_r2_r5_c1() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[7:0]});
    row1_value[7:0] = row1_value[7:0] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[7:0]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[7:0]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[7:0]});
    row2_value[7:0] = row2_value[7:0] + (color_weights[15:8] + hdr.qlr_updates[1].value - row2_value[7:0]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[7:0]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[7:0]});
    row5_value[7:0] = row5_value[7:0] + (color_weights[39:32] + hdr.qlr_updates[2].value - row5_value[7:0]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[7:0]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r1_r2_r5_c2() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[15:8]});
    row1_value[15:8] = row1_value[15:8] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[15:8]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[15:8]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[15:8]});
    row2_value[15:8] = row2_value[15:8] + (color_weights[15:8] + hdr.qlr_updates[1].value - row2_value[15:8]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[15:8]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[15:8]});
    row5_value[15:8] = row5_value[15:8] + (color_weights[39:32] + hdr.qlr_updates[2].value - row5_value[15:8]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[15:8]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r1_r2_r5_c3() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[23:16]});
    row1_value[23:16] = row1_value[23:16] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[23:16]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[23:16]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[23:16]});
    row2_value[23:16] = row2_value[23:16] + (color_weights[15:8] + hdr.qlr_updates[1].value - row2_value[23:16]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[23:16]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[23:16]});
    row5_value[23:16] = row5_value[23:16] + (color_weights[39:32] + hdr.qlr_updates[2].value - row5_value[23:16]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[23:16]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r1_r2_r5_c4() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[31:24]});
    row1_value[31:24] = row1_value[31:24] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[31:24]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[31:24]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[31:24]});
    row2_value[31:24] = row2_value[31:24] + (color_weights[15:8] + hdr.qlr_updates[1].value - row2_value[31:24]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[31:24]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[31:24]});
    row5_value[31:24] = row5_value[31:24] + (color_weights[39:32] + hdr.qlr_updates[2].value - row5_value[31:24]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[31:24]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r1_r2_r5_c5() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[39:32]});
    row1_value[39:32] = row1_value[39:32] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[39:32]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[39:32]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[39:32]});
    row2_value[39:32] = row2_value[39:32] + (color_weights[15:8] + hdr.qlr_updates[1].value - row2_value[39:32]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[39:32]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[39:32]});
    row5_value[39:32] = row5_value[39:32] + (color_weights[39:32] + hdr.qlr_updates[2].value - row5_value[39:32]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[39:32]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r1_r2_r5_c6() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[47:40]});
    row1_value[47:40] = row1_value[47:40] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[47:40]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[47:40]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[47:40]});
    row2_value[47:40] = row2_value[47:40] + (color_weights[15:8] + hdr.qlr_updates[1].value - row2_value[47:40]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[47:40]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[47:40]});
    row5_value[47:40] = row5_value[47:40] + (color_weights[39:32] + hdr.qlr_updates[2].value - row5_value[47:40]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[47:40]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r1_r2_r5_c7() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[55:48]});
    row1_value[55:48] = row1_value[55:48] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[55:48]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[55:48]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[55:48]});
    row2_value[55:48] = row2_value[55:48] + (color_weights[15:8] + hdr.qlr_updates[1].value - row2_value[55:48]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[55:48]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[55:48]});
    row5_value[55:48] = row5_value[55:48] + (color_weights[39:32] + hdr.qlr_updates[2].value - row5_value[55:48]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[55:48]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r1_r2_r5_c8() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[63:56]});
    row1_value[63:56] = row1_value[63:56] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[63:56]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[63:56]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[63:56]});
    row2_value[63:56] = row2_value[63:56] + (color_weights[15:8] + hdr.qlr_updates[1].value - row2_value[63:56]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[63:56]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[63:56]});
    row5_value[63:56] = row5_value[63:56] + (color_weights[39:32] + hdr.qlr_updates[2].value - row5_value[63:56]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[63:56]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r1_r3_c1() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[7:0]});
    row1_value[7:0] = row1_value[7:0] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[7:0]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[7:0]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[7:0]});
    row3_value[7:0] = row3_value[7:0] + (color_weights[23:16] + hdr.qlr_updates[1].value - row3_value[7:0]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[7:0]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r1_r3_c2() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[15:8]});
    row1_value[15:8] = row1_value[15:8] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[15:8]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[15:8]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[15:8]});
    row3_value[15:8] = row3_value[15:8] + (color_weights[23:16] + hdr.qlr_updates[1].value - row3_value[15:8]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[15:8]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r1_r3_c3() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[23:16]});
    row1_value[23:16] = row1_value[23:16] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[23:16]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[23:16]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[23:16]});
    row3_value[23:16] = row3_value[23:16] + (color_weights[23:16] + hdr.qlr_updates[1].value - row3_value[23:16]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[23:16]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r1_r3_c4() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[31:24]});
    row1_value[31:24] = row1_value[31:24] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[31:24]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[31:24]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[31:24]});
    row3_value[31:24] = row3_value[31:24] + (color_weights[23:16] + hdr.qlr_updates[1].value - row3_value[31:24]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[31:24]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r1_r3_c5() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[39:32]});
    row1_value[39:32] = row1_value[39:32] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[39:32]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[39:32]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[39:32]});
    row3_value[39:32] = row3_value[39:32] + (color_weights[23:16] + hdr.qlr_updates[1].value - row3_value[39:32]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[39:32]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r1_r3_c6() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[47:40]});
    row1_value[47:40] = row1_value[47:40] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[47:40]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[47:40]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[47:40]});
    row3_value[47:40] = row3_value[47:40] + (color_weights[23:16] + hdr.qlr_updates[1].value - row3_value[47:40]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[47:40]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r1_r3_c7() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[55:48]});
    row1_value[55:48] = row1_value[55:48] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[55:48]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[55:48]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[55:48]});
    row3_value[55:48] = row3_value[55:48] + (color_weights[23:16] + hdr.qlr_updates[1].value - row3_value[55:48]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[55:48]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r1_r3_c8() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[63:56]});
    row1_value[63:56] = row1_value[63:56] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[63:56]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[63:56]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[63:56]});
    row3_value[63:56] = row3_value[63:56] + (color_weights[23:16] + hdr.qlr_updates[1].value - row3_value[63:56]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[63:56]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r1_r3_r4_c1() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[7:0]});
    row1_value[7:0] = row1_value[7:0] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[7:0]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[7:0]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[7:0]});
    row3_value[7:0] = row3_value[7:0] + (color_weights[23:16] + hdr.qlr_updates[1].value - row3_value[7:0]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[7:0]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[7:0]});
    row4_value[7:0] = row4_value[7:0] + (color_weights[31:24] + hdr.qlr_updates[2].value - row4_value[7:0]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[7:0]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r1_r3_r4_c2() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[15:8]});
    row1_value[15:8] = row1_value[15:8] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[15:8]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[15:8]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[15:8]});
    row3_value[15:8] = row3_value[15:8] + (color_weights[23:16] + hdr.qlr_updates[1].value - row3_value[15:8]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[15:8]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[15:8]});
    row4_value[15:8] = row4_value[15:8] + (color_weights[31:24] + hdr.qlr_updates[2].value - row4_value[15:8]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[15:8]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r1_r3_r4_c3() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[23:16]});
    row1_value[23:16] = row1_value[23:16] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[23:16]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[23:16]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[23:16]});
    row3_value[23:16] = row3_value[23:16] + (color_weights[23:16] + hdr.qlr_updates[1].value - row3_value[23:16]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[23:16]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[23:16]});
    row4_value[23:16] = row4_value[23:16] + (color_weights[31:24] + hdr.qlr_updates[2].value - row4_value[23:16]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[23:16]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r1_r3_r4_c4() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[31:24]});
    row1_value[31:24] = row1_value[31:24] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[31:24]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[31:24]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[31:24]});
    row3_value[31:24] = row3_value[31:24] + (color_weights[23:16] + hdr.qlr_updates[1].value - row3_value[31:24]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[31:24]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[31:24]});
    row4_value[31:24] = row4_value[31:24] + (color_weights[31:24] + hdr.qlr_updates[2].value - row4_value[31:24]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[31:24]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r1_r3_r4_c5() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[39:32]});
    row1_value[39:32] = row1_value[39:32] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[39:32]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[39:32]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[39:32]});
    row3_value[39:32] = row3_value[39:32] + (color_weights[23:16] + hdr.qlr_updates[1].value - row3_value[39:32]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[39:32]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[39:32]});
    row4_value[39:32] = row4_value[39:32] + (color_weights[31:24] + hdr.qlr_updates[2].value - row4_value[39:32]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[39:32]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r1_r3_r4_c6() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[47:40]});
    row1_value[47:40] = row1_value[47:40] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[47:40]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[47:40]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[47:40]});
    row3_value[47:40] = row3_value[47:40] + (color_weights[23:16] + hdr.qlr_updates[1].value - row3_value[47:40]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[47:40]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[47:40]});
    row4_value[47:40] = row4_value[47:40] + (color_weights[31:24] + hdr.qlr_updates[2].value - row4_value[47:40]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[47:40]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r1_r3_r4_c7() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[55:48]});
    row1_value[55:48] = row1_value[55:48] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[55:48]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[55:48]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[55:48]});
    row3_value[55:48] = row3_value[55:48] + (color_weights[23:16] + hdr.qlr_updates[1].value - row3_value[55:48]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[55:48]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[55:48]});
    row4_value[55:48] = row4_value[55:48] + (color_weights[31:24] + hdr.qlr_updates[2].value - row4_value[55:48]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[55:48]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r1_r3_r4_c8() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[63:56]});
    row1_value[63:56] = row1_value[63:56] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[63:56]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[63:56]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[63:56]});
    row3_value[63:56] = row3_value[63:56] + (color_weights[23:16] + hdr.qlr_updates[1].value - row3_value[63:56]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[63:56]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[63:56]});
    row4_value[63:56] = row4_value[63:56] + (color_weights[31:24] + hdr.qlr_updates[2].value - row4_value[63:56]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[63:56]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r1_r3_r4_r5_c1() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[7:0]});
    row1_value[7:0] = row1_value[7:0] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[7:0]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[7:0]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[7:0]});
    row3_value[7:0] = row3_value[7:0] + (color_weights[23:16] + hdr.qlr_updates[1].value - row3_value[7:0]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[7:0]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[7:0]});
    row4_value[7:0] = row4_value[7:0] + (color_weights[31:24] + hdr.qlr_updates[2].value - row4_value[7:0]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[7:0]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[7:0]});
    row5_value[7:0] = row5_value[7:0] + (color_weights[39:32] + hdr.qlr_updates[3].value - row5_value[7:0]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[7:0]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r1_r3_r4_r5_c2() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[15:8]});
    row1_value[15:8] = row1_value[15:8] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[15:8]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[15:8]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[15:8]});
    row3_value[15:8] = row3_value[15:8] + (color_weights[23:16] + hdr.qlr_updates[1].value - row3_value[15:8]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[15:8]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[15:8]});
    row4_value[15:8] = row4_value[15:8] + (color_weights[31:24] + hdr.qlr_updates[2].value - row4_value[15:8]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[15:8]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[15:8]});
    row5_value[15:8] = row5_value[15:8] + (color_weights[39:32] + hdr.qlr_updates[3].value - row5_value[15:8]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[15:8]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r1_r3_r4_r5_c3() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[23:16]});
    row1_value[23:16] = row1_value[23:16] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[23:16]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[23:16]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[23:16]});
    row3_value[23:16] = row3_value[23:16] + (color_weights[23:16] + hdr.qlr_updates[1].value - row3_value[23:16]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[23:16]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[23:16]});
    row4_value[23:16] = row4_value[23:16] + (color_weights[31:24] + hdr.qlr_updates[2].value - row4_value[23:16]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[23:16]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[23:16]});
    row5_value[23:16] = row5_value[23:16] + (color_weights[39:32] + hdr.qlr_updates[3].value - row5_value[23:16]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[23:16]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r1_r3_r4_r5_c4() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[31:24]});
    row1_value[31:24] = row1_value[31:24] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[31:24]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[31:24]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[31:24]});
    row3_value[31:24] = row3_value[31:24] + (color_weights[23:16] + hdr.qlr_updates[1].value - row3_value[31:24]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[31:24]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[31:24]});
    row4_value[31:24] = row4_value[31:24] + (color_weights[31:24] + hdr.qlr_updates[2].value - row4_value[31:24]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[31:24]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[31:24]});
    row5_value[31:24] = row5_value[31:24] + (color_weights[39:32] + hdr.qlr_updates[3].value - row5_value[31:24]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[31:24]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r1_r3_r4_r5_c5() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[39:32]});
    row1_value[39:32] = row1_value[39:32] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[39:32]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[39:32]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[39:32]});
    row3_value[39:32] = row3_value[39:32] + (color_weights[23:16] + hdr.qlr_updates[1].value - row3_value[39:32]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[39:32]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[39:32]});
    row4_value[39:32] = row4_value[39:32] + (color_weights[31:24] + hdr.qlr_updates[2].value - row4_value[39:32]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[39:32]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[39:32]});
    row5_value[39:32] = row5_value[39:32] + (color_weights[39:32] + hdr.qlr_updates[3].value - row5_value[39:32]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[39:32]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r1_r3_r4_r5_c6() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[47:40]});
    row1_value[47:40] = row1_value[47:40] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[47:40]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[47:40]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[47:40]});
    row3_value[47:40] = row3_value[47:40] + (color_weights[23:16] + hdr.qlr_updates[1].value - row3_value[47:40]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[47:40]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[47:40]});
    row4_value[47:40] = row4_value[47:40] + (color_weights[31:24] + hdr.qlr_updates[2].value - row4_value[47:40]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[47:40]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[47:40]});
    row5_value[47:40] = row5_value[47:40] + (color_weights[39:32] + hdr.qlr_updates[3].value - row5_value[47:40]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[47:40]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r1_r3_r4_r5_c7() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[55:48]});
    row1_value[55:48] = row1_value[55:48] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[55:48]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[55:48]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[55:48]});
    row3_value[55:48] = row3_value[55:48] + (color_weights[23:16] + hdr.qlr_updates[1].value - row3_value[55:48]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[55:48]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[55:48]});
    row4_value[55:48] = row4_value[55:48] + (color_weights[31:24] + hdr.qlr_updates[2].value - row4_value[55:48]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[55:48]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[55:48]});
    row5_value[55:48] = row5_value[55:48] + (color_weights[39:32] + hdr.qlr_updates[3].value - row5_value[55:48]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[55:48]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r1_r3_r4_r5_c8() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[63:56]});
    row1_value[63:56] = row1_value[63:56] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[63:56]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[63:56]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[63:56]});
    row3_value[63:56] = row3_value[63:56] + (color_weights[23:16] + hdr.qlr_updates[1].value - row3_value[63:56]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[63:56]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[63:56]});
    row4_value[63:56] = row4_value[63:56] + (color_weights[31:24] + hdr.qlr_updates[2].value - row4_value[63:56]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[63:56]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[63:56]});
    row5_value[63:56] = row5_value[63:56] + (color_weights[39:32] + hdr.qlr_updates[3].value - row5_value[63:56]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[63:56]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r1_r3_r5_c1() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[7:0]});
    row1_value[7:0] = row1_value[7:0] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[7:0]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[7:0]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[7:0]});
    row3_value[7:0] = row3_value[7:0] + (color_weights[23:16] + hdr.qlr_updates[1].value - row3_value[7:0]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[7:0]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[7:0]});
    row5_value[7:0] = row5_value[7:0] + (color_weights[39:32] + hdr.qlr_updates[2].value - row5_value[7:0]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[7:0]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r1_r3_r5_c2() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[15:8]});
    row1_value[15:8] = row1_value[15:8] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[15:8]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[15:8]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[15:8]});
    row3_value[15:8] = row3_value[15:8] + (color_weights[23:16] + hdr.qlr_updates[1].value - row3_value[15:8]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[15:8]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[15:8]});
    row5_value[15:8] = row5_value[15:8] + (color_weights[39:32] + hdr.qlr_updates[2].value - row5_value[15:8]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[15:8]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r1_r3_r5_c3() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[23:16]});
    row1_value[23:16] = row1_value[23:16] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[23:16]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[23:16]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[23:16]});
    row3_value[23:16] = row3_value[23:16] + (color_weights[23:16] + hdr.qlr_updates[1].value - row3_value[23:16]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[23:16]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[23:16]});
    row5_value[23:16] = row5_value[23:16] + (color_weights[39:32] + hdr.qlr_updates[2].value - row5_value[23:16]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[23:16]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r1_r3_r5_c4() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[31:24]});
    row1_value[31:24] = row1_value[31:24] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[31:24]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[31:24]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[31:24]});
    row3_value[31:24] = row3_value[31:24] + (color_weights[23:16] + hdr.qlr_updates[1].value - row3_value[31:24]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[31:24]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[31:24]});
    row5_value[31:24] = row5_value[31:24] + (color_weights[39:32] + hdr.qlr_updates[2].value - row5_value[31:24]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[31:24]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r1_r3_r5_c5() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[39:32]});
    row1_value[39:32] = row1_value[39:32] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[39:32]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[39:32]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[39:32]});
    row3_value[39:32] = row3_value[39:32] + (color_weights[23:16] + hdr.qlr_updates[1].value - row3_value[39:32]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[39:32]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[39:32]});
    row5_value[39:32] = row5_value[39:32] + (color_weights[39:32] + hdr.qlr_updates[2].value - row5_value[39:32]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[39:32]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r1_r3_r5_c6() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[47:40]});
    row1_value[47:40] = row1_value[47:40] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[47:40]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[47:40]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[47:40]});
    row3_value[47:40] = row3_value[47:40] + (color_weights[23:16] + hdr.qlr_updates[1].value - row3_value[47:40]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[47:40]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[47:40]});
    row5_value[47:40] = row5_value[47:40] + (color_weights[39:32] + hdr.qlr_updates[2].value - row5_value[47:40]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[47:40]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r1_r3_r5_c7() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[55:48]});
    row1_value[55:48] = row1_value[55:48] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[55:48]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[55:48]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[55:48]});
    row3_value[55:48] = row3_value[55:48] + (color_weights[23:16] + hdr.qlr_updates[1].value - row3_value[55:48]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[55:48]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[55:48]});
    row5_value[55:48] = row5_value[55:48] + (color_weights[39:32] + hdr.qlr_updates[2].value - row5_value[55:48]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[55:48]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r1_r3_r5_c8() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[63:56]});
    row1_value[63:56] = row1_value[63:56] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[63:56]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[63:56]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[63:56]});
    row3_value[63:56] = row3_value[63:56] + (color_weights[23:16] + hdr.qlr_updates[1].value - row3_value[63:56]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[63:56]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[63:56]});
    row5_value[63:56] = row5_value[63:56] + (color_weights[39:32] + hdr.qlr_updates[2].value - row5_value[63:56]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[63:56]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r1_r4_c1() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[7:0]});
    row1_value[7:0] = row1_value[7:0] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[7:0]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[7:0]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[7:0]});
    row4_value[7:0] = row4_value[7:0] + (color_weights[31:24] + hdr.qlr_updates[1].value - row4_value[7:0]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[7:0]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r1_r4_c2() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[15:8]});
    row1_value[15:8] = row1_value[15:8] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[15:8]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[15:8]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[15:8]});
    row4_value[15:8] = row4_value[15:8] + (color_weights[31:24] + hdr.qlr_updates[1].value - row4_value[15:8]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[15:8]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r1_r4_c3() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[23:16]});
    row1_value[23:16] = row1_value[23:16] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[23:16]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[23:16]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[23:16]});
    row4_value[23:16] = row4_value[23:16] + (color_weights[31:24] + hdr.qlr_updates[1].value - row4_value[23:16]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[23:16]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r1_r4_c4() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[31:24]});
    row1_value[31:24] = row1_value[31:24] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[31:24]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[31:24]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[31:24]});
    row4_value[31:24] = row4_value[31:24] + (color_weights[31:24] + hdr.qlr_updates[1].value - row4_value[31:24]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[31:24]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r1_r4_c5() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[39:32]});
    row1_value[39:32] = row1_value[39:32] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[39:32]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[39:32]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[39:32]});
    row4_value[39:32] = row4_value[39:32] + (color_weights[31:24] + hdr.qlr_updates[1].value - row4_value[39:32]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[39:32]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r1_r4_c6() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[47:40]});
    row1_value[47:40] = row1_value[47:40] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[47:40]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[47:40]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[47:40]});
    row4_value[47:40] = row4_value[47:40] + (color_weights[31:24] + hdr.qlr_updates[1].value - row4_value[47:40]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[47:40]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r1_r4_c7() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[55:48]});
    row1_value[55:48] = row1_value[55:48] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[55:48]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[55:48]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[55:48]});
    row4_value[55:48] = row4_value[55:48] + (color_weights[31:24] + hdr.qlr_updates[1].value - row4_value[55:48]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[55:48]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r1_r4_c8() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[63:56]});
    row1_value[63:56] = row1_value[63:56] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[63:56]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[63:56]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[63:56]});
    row4_value[63:56] = row4_value[63:56] + (color_weights[31:24] + hdr.qlr_updates[1].value - row4_value[63:56]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[63:56]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r1_r4_r5_c1() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[7:0]});
    row1_value[7:0] = row1_value[7:0] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[7:0]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[7:0]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[7:0]});
    row4_value[7:0] = row4_value[7:0] + (color_weights[31:24] + hdr.qlr_updates[1].value - row4_value[7:0]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[7:0]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[7:0]});
    row5_value[7:0] = row5_value[7:0] + (color_weights[39:32] + hdr.qlr_updates[2].value - row5_value[7:0]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[7:0]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r1_r4_r5_c2() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[15:8]});
    row1_value[15:8] = row1_value[15:8] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[15:8]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[15:8]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[15:8]});
    row4_value[15:8] = row4_value[15:8] + (color_weights[31:24] + hdr.qlr_updates[1].value - row4_value[15:8]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[15:8]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[15:8]});
    row5_value[15:8] = row5_value[15:8] + (color_weights[39:32] + hdr.qlr_updates[2].value - row5_value[15:8]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[15:8]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r1_r4_r5_c3() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[23:16]});
    row1_value[23:16] = row1_value[23:16] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[23:16]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[23:16]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[23:16]});
    row4_value[23:16] = row4_value[23:16] + (color_weights[31:24] + hdr.qlr_updates[1].value - row4_value[23:16]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[23:16]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[23:16]});
    row5_value[23:16] = row5_value[23:16] + (color_weights[39:32] + hdr.qlr_updates[2].value - row5_value[23:16]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[23:16]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r1_r4_r5_c4() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[31:24]});
    row1_value[31:24] = row1_value[31:24] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[31:24]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[31:24]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[31:24]});
    row4_value[31:24] = row4_value[31:24] + (color_weights[31:24] + hdr.qlr_updates[1].value - row4_value[31:24]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[31:24]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[31:24]});
    row5_value[31:24] = row5_value[31:24] + (color_weights[39:32] + hdr.qlr_updates[2].value - row5_value[31:24]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[31:24]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r1_r4_r5_c5() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[39:32]});
    row1_value[39:32] = row1_value[39:32] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[39:32]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[39:32]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[39:32]});
    row4_value[39:32] = row4_value[39:32] + (color_weights[31:24] + hdr.qlr_updates[1].value - row4_value[39:32]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[39:32]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[39:32]});
    row5_value[39:32] = row5_value[39:32] + (color_weights[39:32] + hdr.qlr_updates[2].value - row5_value[39:32]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[39:32]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r1_r4_r5_c6() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[47:40]});
    row1_value[47:40] = row1_value[47:40] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[47:40]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[47:40]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[47:40]});
    row4_value[47:40] = row4_value[47:40] + (color_weights[31:24] + hdr.qlr_updates[1].value - row4_value[47:40]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[47:40]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[47:40]});
    row5_value[47:40] = row5_value[47:40] + (color_weights[39:32] + hdr.qlr_updates[2].value - row5_value[47:40]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[47:40]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r1_r4_r5_c7() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[55:48]});
    row1_value[55:48] = row1_value[55:48] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[55:48]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[55:48]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[55:48]});
    row4_value[55:48] = row4_value[55:48] + (color_weights[31:24] + hdr.qlr_updates[1].value - row4_value[55:48]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[55:48]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[55:48]});
    row5_value[55:48] = row5_value[55:48] + (color_weights[39:32] + hdr.qlr_updates[2].value - row5_value[55:48]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[55:48]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r1_r4_r5_c8() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[63:56]});
    row1_value[63:56] = row1_value[63:56] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[63:56]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[63:56]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[63:56]});
    row4_value[63:56] = row4_value[63:56] + (color_weights[31:24] + hdr.qlr_updates[1].value - row4_value[63:56]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[63:56]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[63:56]});
    row5_value[63:56] = row5_value[63:56] + (color_weights[39:32] + hdr.qlr_updates[2].value - row5_value[63:56]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[63:56]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r1_r5_c1() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[7:0]});
    row1_value[7:0] = row1_value[7:0] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[7:0]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[7:0]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[7:0]});
    row5_value[7:0] = row5_value[7:0] + (color_weights[39:32] + hdr.qlr_updates[1].value - row5_value[7:0]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[7:0]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r1_r5_c2() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[15:8]});
    row1_value[15:8] = row1_value[15:8] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[15:8]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[15:8]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[15:8]});
    row5_value[15:8] = row5_value[15:8] + (color_weights[39:32] + hdr.qlr_updates[1].value - row5_value[15:8]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[15:8]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r1_r5_c3() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[23:16]});
    row1_value[23:16] = row1_value[23:16] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[23:16]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[23:16]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[23:16]});
    row5_value[23:16] = row5_value[23:16] + (color_weights[39:32] + hdr.qlr_updates[1].value - row5_value[23:16]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[23:16]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r1_r5_c4() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[31:24]});
    row1_value[31:24] = row1_value[31:24] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[31:24]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[31:24]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[31:24]});
    row5_value[31:24] = row5_value[31:24] + (color_weights[39:32] + hdr.qlr_updates[1].value - row5_value[31:24]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[31:24]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r1_r5_c5() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[39:32]});
    row1_value[39:32] = row1_value[39:32] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[39:32]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[39:32]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[39:32]});
    row5_value[39:32] = row5_value[39:32] + (color_weights[39:32] + hdr.qlr_updates[1].value - row5_value[39:32]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[39:32]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r1_r5_c6() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[47:40]});
    row1_value[47:40] = row1_value[47:40] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[47:40]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[47:40]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[47:40]});
    row5_value[47:40] = row5_value[47:40] + (color_weights[39:32] + hdr.qlr_updates[1].value - row5_value[47:40]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[47:40]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r1_r5_c7() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[55:48]});
    row1_value[55:48] = row1_value[55:48] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[55:48]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[55:48]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[55:48]});
    row5_value[55:48] = row5_value[55:48] + (color_weights[39:32] + hdr.qlr_updates[1].value - row5_value[55:48]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[55:48]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r1_r5_c8() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    row1.read(row1_value, 0);
    log_msg("node {} updating row1_value - before: {}", {nid, row1_value[63:56]});
    row1_value[63:56] = row1_value[63:56] + (color_weights[7:0] + hdr.qlr_updates[0].value - row1_value[63:56]);
    log_msg("node {} updating row1_value - after: {}", {nid, row1_value[63:56]});
    row1.write(0, row1_value);
    log_msg("node {} new row1_value: {}", {nid, row1_value});
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[63:56]});
    row5_value[63:56] = row5_value[63:56] + (color_weights[39:32] + hdr.qlr_updates[1].value - row5_value[63:56]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[63:56]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r2_c1() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[7:0]});
    row2_value[7:0] = row2_value[7:0] + (color_weights[15:8] + hdr.qlr_updates[0].value - row2_value[7:0]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[7:0]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r2_c2() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[15:8]});
    row2_value[15:8] = row2_value[15:8] + (color_weights[15:8] + hdr.qlr_updates[0].value - row2_value[15:8]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[15:8]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r2_c3() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[23:16]});
    row2_value[23:16] = row2_value[23:16] + (color_weights[15:8] + hdr.qlr_updates[0].value - row2_value[23:16]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[23:16]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r2_c4() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[31:24]});
    row2_value[31:24] = row2_value[31:24] + (color_weights[15:8] + hdr.qlr_updates[0].value - row2_value[31:24]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[31:24]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r2_c5() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[39:32]});
    row2_value[39:32] = row2_value[39:32] + (color_weights[15:8] + hdr.qlr_updates[0].value - row2_value[39:32]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[39:32]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r2_c6() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[47:40]});
    row2_value[47:40] = row2_value[47:40] + (color_weights[15:8] + hdr.qlr_updates[0].value - row2_value[47:40]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[47:40]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r2_c7() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[55:48]});
    row2_value[55:48] = row2_value[55:48] + (color_weights[15:8] + hdr.qlr_updates[0].value - row2_value[55:48]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[55:48]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r2_c8() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[63:56]});
    row2_value[63:56] = row2_value[63:56] + (color_weights[15:8] + hdr.qlr_updates[0].value - row2_value[63:56]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[63:56]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r2_r3_c1() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[7:0]});
    row2_value[7:0] = row2_value[7:0] + (color_weights[15:8] + hdr.qlr_updates[0].value - row2_value[7:0]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[7:0]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[7:0]});
    row3_value[7:0] = row3_value[7:0] + (color_weights[23:16] + hdr.qlr_updates[1].value - row3_value[7:0]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[7:0]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r2_r3_c2() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[15:8]});
    row2_value[15:8] = row2_value[15:8] + (color_weights[15:8] + hdr.qlr_updates[0].value - row2_value[15:8]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[15:8]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[15:8]});
    row3_value[15:8] = row3_value[15:8] + (color_weights[23:16] + hdr.qlr_updates[1].value - row3_value[15:8]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[15:8]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r2_r3_c3() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[23:16]});
    row2_value[23:16] = row2_value[23:16] + (color_weights[15:8] + hdr.qlr_updates[0].value - row2_value[23:16]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[23:16]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[23:16]});
    row3_value[23:16] = row3_value[23:16] + (color_weights[23:16] + hdr.qlr_updates[1].value - row3_value[23:16]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[23:16]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r2_r3_c4() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[31:24]});
    row2_value[31:24] = row2_value[31:24] + (color_weights[15:8] + hdr.qlr_updates[0].value - row2_value[31:24]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[31:24]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[31:24]});
    row3_value[31:24] = row3_value[31:24] + (color_weights[23:16] + hdr.qlr_updates[1].value - row3_value[31:24]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[31:24]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r2_r3_c5() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[39:32]});
    row2_value[39:32] = row2_value[39:32] + (color_weights[15:8] + hdr.qlr_updates[0].value - row2_value[39:32]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[39:32]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[39:32]});
    row3_value[39:32] = row3_value[39:32] + (color_weights[23:16] + hdr.qlr_updates[1].value - row3_value[39:32]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[39:32]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r2_r3_c6() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[47:40]});
    row2_value[47:40] = row2_value[47:40] + (color_weights[15:8] + hdr.qlr_updates[0].value - row2_value[47:40]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[47:40]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[47:40]});
    row3_value[47:40] = row3_value[47:40] + (color_weights[23:16] + hdr.qlr_updates[1].value - row3_value[47:40]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[47:40]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r2_r3_c7() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[55:48]});
    row2_value[55:48] = row2_value[55:48] + (color_weights[15:8] + hdr.qlr_updates[0].value - row2_value[55:48]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[55:48]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[55:48]});
    row3_value[55:48] = row3_value[55:48] + (color_weights[23:16] + hdr.qlr_updates[1].value - row3_value[55:48]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[55:48]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r2_r3_c8() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[63:56]});
    row2_value[63:56] = row2_value[63:56] + (color_weights[15:8] + hdr.qlr_updates[0].value - row2_value[63:56]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[63:56]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[63:56]});
    row3_value[63:56] = row3_value[63:56] + (color_weights[23:16] + hdr.qlr_updates[1].value - row3_value[63:56]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[63:56]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r2_r3_r4_c1() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[7:0]});
    row2_value[7:0] = row2_value[7:0] + (color_weights[15:8] + hdr.qlr_updates[0].value - row2_value[7:0]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[7:0]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[7:0]});
    row3_value[7:0] = row3_value[7:0] + (color_weights[23:16] + hdr.qlr_updates[1].value - row3_value[7:0]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[7:0]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[7:0]});
    row4_value[7:0] = row4_value[7:0] + (color_weights[31:24] + hdr.qlr_updates[2].value - row4_value[7:0]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[7:0]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r2_r3_r4_c2() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[15:8]});
    row2_value[15:8] = row2_value[15:8] + (color_weights[15:8] + hdr.qlr_updates[0].value - row2_value[15:8]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[15:8]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[15:8]});
    row3_value[15:8] = row3_value[15:8] + (color_weights[23:16] + hdr.qlr_updates[1].value - row3_value[15:8]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[15:8]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[15:8]});
    row4_value[15:8] = row4_value[15:8] + (color_weights[31:24] + hdr.qlr_updates[2].value - row4_value[15:8]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[15:8]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r2_r3_r4_c3() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[23:16]});
    row2_value[23:16] = row2_value[23:16] + (color_weights[15:8] + hdr.qlr_updates[0].value - row2_value[23:16]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[23:16]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[23:16]});
    row3_value[23:16] = row3_value[23:16] + (color_weights[23:16] + hdr.qlr_updates[1].value - row3_value[23:16]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[23:16]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[23:16]});
    row4_value[23:16] = row4_value[23:16] + (color_weights[31:24] + hdr.qlr_updates[2].value - row4_value[23:16]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[23:16]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r2_r3_r4_c4() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[31:24]});
    row2_value[31:24] = row2_value[31:24] + (color_weights[15:8] + hdr.qlr_updates[0].value - row2_value[31:24]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[31:24]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[31:24]});
    row3_value[31:24] = row3_value[31:24] + (color_weights[23:16] + hdr.qlr_updates[1].value - row3_value[31:24]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[31:24]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[31:24]});
    row4_value[31:24] = row4_value[31:24] + (color_weights[31:24] + hdr.qlr_updates[2].value - row4_value[31:24]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[31:24]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r2_r3_r4_c5() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[39:32]});
    row2_value[39:32] = row2_value[39:32] + (color_weights[15:8] + hdr.qlr_updates[0].value - row2_value[39:32]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[39:32]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[39:32]});
    row3_value[39:32] = row3_value[39:32] + (color_weights[23:16] + hdr.qlr_updates[1].value - row3_value[39:32]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[39:32]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[39:32]});
    row4_value[39:32] = row4_value[39:32] + (color_weights[31:24] + hdr.qlr_updates[2].value - row4_value[39:32]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[39:32]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r2_r3_r4_c6() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[47:40]});
    row2_value[47:40] = row2_value[47:40] + (color_weights[15:8] + hdr.qlr_updates[0].value - row2_value[47:40]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[47:40]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[47:40]});
    row3_value[47:40] = row3_value[47:40] + (color_weights[23:16] + hdr.qlr_updates[1].value - row3_value[47:40]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[47:40]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[47:40]});
    row4_value[47:40] = row4_value[47:40] + (color_weights[31:24] + hdr.qlr_updates[2].value - row4_value[47:40]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[47:40]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r2_r3_r4_c7() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[55:48]});
    row2_value[55:48] = row2_value[55:48] + (color_weights[15:8] + hdr.qlr_updates[0].value - row2_value[55:48]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[55:48]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[55:48]});
    row3_value[55:48] = row3_value[55:48] + (color_weights[23:16] + hdr.qlr_updates[1].value - row3_value[55:48]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[55:48]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[55:48]});
    row4_value[55:48] = row4_value[55:48] + (color_weights[31:24] + hdr.qlr_updates[2].value - row4_value[55:48]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[55:48]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r2_r3_r4_c8() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[63:56]});
    row2_value[63:56] = row2_value[63:56] + (color_weights[15:8] + hdr.qlr_updates[0].value - row2_value[63:56]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[63:56]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[63:56]});
    row3_value[63:56] = row3_value[63:56] + (color_weights[23:16] + hdr.qlr_updates[1].value - row3_value[63:56]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[63:56]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[63:56]});
    row4_value[63:56] = row4_value[63:56] + (color_weights[31:24] + hdr.qlr_updates[2].value - row4_value[63:56]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[63:56]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r2_r3_r4_r5_c1() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[7:0]});
    row2_value[7:0] = row2_value[7:0] + (color_weights[15:8] + hdr.qlr_updates[0].value - row2_value[7:0]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[7:0]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[7:0]});
    row3_value[7:0] = row3_value[7:0] + (color_weights[23:16] + hdr.qlr_updates[1].value - row3_value[7:0]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[7:0]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[7:0]});
    row4_value[7:0] = row4_value[7:0] + (color_weights[31:24] + hdr.qlr_updates[2].value - row4_value[7:0]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[7:0]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[7:0]});
    row5_value[7:0] = row5_value[7:0] + (color_weights[39:32] + hdr.qlr_updates[3].value - row5_value[7:0]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[7:0]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r2_r3_r4_r5_c2() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[15:8]});
    row2_value[15:8] = row2_value[15:8] + (color_weights[15:8] + hdr.qlr_updates[0].value - row2_value[15:8]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[15:8]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[15:8]});
    row3_value[15:8] = row3_value[15:8] + (color_weights[23:16] + hdr.qlr_updates[1].value - row3_value[15:8]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[15:8]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[15:8]});
    row4_value[15:8] = row4_value[15:8] + (color_weights[31:24] + hdr.qlr_updates[2].value - row4_value[15:8]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[15:8]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[15:8]});
    row5_value[15:8] = row5_value[15:8] + (color_weights[39:32] + hdr.qlr_updates[3].value - row5_value[15:8]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[15:8]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r2_r3_r4_r5_c3() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[23:16]});
    row2_value[23:16] = row2_value[23:16] + (color_weights[15:8] + hdr.qlr_updates[0].value - row2_value[23:16]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[23:16]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[23:16]});
    row3_value[23:16] = row3_value[23:16] + (color_weights[23:16] + hdr.qlr_updates[1].value - row3_value[23:16]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[23:16]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[23:16]});
    row4_value[23:16] = row4_value[23:16] + (color_weights[31:24] + hdr.qlr_updates[2].value - row4_value[23:16]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[23:16]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[23:16]});
    row5_value[23:16] = row5_value[23:16] + (color_weights[39:32] + hdr.qlr_updates[3].value - row5_value[23:16]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[23:16]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r2_r3_r4_r5_c4() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[31:24]});
    row2_value[31:24] = row2_value[31:24] + (color_weights[15:8] + hdr.qlr_updates[0].value - row2_value[31:24]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[31:24]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[31:24]});
    row3_value[31:24] = row3_value[31:24] + (color_weights[23:16] + hdr.qlr_updates[1].value - row3_value[31:24]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[31:24]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[31:24]});
    row4_value[31:24] = row4_value[31:24] + (color_weights[31:24] + hdr.qlr_updates[2].value - row4_value[31:24]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[31:24]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[31:24]});
    row5_value[31:24] = row5_value[31:24] + (color_weights[39:32] + hdr.qlr_updates[3].value - row5_value[31:24]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[31:24]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r2_r3_r4_r5_c5() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[39:32]});
    row2_value[39:32] = row2_value[39:32] + (color_weights[15:8] + hdr.qlr_updates[0].value - row2_value[39:32]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[39:32]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[39:32]});
    row3_value[39:32] = row3_value[39:32] + (color_weights[23:16] + hdr.qlr_updates[1].value - row3_value[39:32]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[39:32]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[39:32]});
    row4_value[39:32] = row4_value[39:32] + (color_weights[31:24] + hdr.qlr_updates[2].value - row4_value[39:32]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[39:32]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[39:32]});
    row5_value[39:32] = row5_value[39:32] + (color_weights[39:32] + hdr.qlr_updates[3].value - row5_value[39:32]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[39:32]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r2_r3_r4_r5_c6() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[47:40]});
    row2_value[47:40] = row2_value[47:40] + (color_weights[15:8] + hdr.qlr_updates[0].value - row2_value[47:40]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[47:40]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[47:40]});
    row3_value[47:40] = row3_value[47:40] + (color_weights[23:16] + hdr.qlr_updates[1].value - row3_value[47:40]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[47:40]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[47:40]});
    row4_value[47:40] = row4_value[47:40] + (color_weights[31:24] + hdr.qlr_updates[2].value - row4_value[47:40]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[47:40]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[47:40]});
    row5_value[47:40] = row5_value[47:40] + (color_weights[39:32] + hdr.qlr_updates[3].value - row5_value[47:40]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[47:40]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r2_r3_r4_r5_c7() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[55:48]});
    row2_value[55:48] = row2_value[55:48] + (color_weights[15:8] + hdr.qlr_updates[0].value - row2_value[55:48]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[55:48]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[55:48]});
    row3_value[55:48] = row3_value[55:48] + (color_weights[23:16] + hdr.qlr_updates[1].value - row3_value[55:48]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[55:48]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[55:48]});
    row4_value[55:48] = row4_value[55:48] + (color_weights[31:24] + hdr.qlr_updates[2].value - row4_value[55:48]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[55:48]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[55:48]});
    row5_value[55:48] = row5_value[55:48] + (color_weights[39:32] + hdr.qlr_updates[3].value - row5_value[55:48]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[55:48]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r2_r3_r4_r5_c8() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[63:56]});
    row2_value[63:56] = row2_value[63:56] + (color_weights[15:8] + hdr.qlr_updates[0].value - row2_value[63:56]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[63:56]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[63:56]});
    row3_value[63:56] = row3_value[63:56] + (color_weights[23:16] + hdr.qlr_updates[1].value - row3_value[63:56]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[63:56]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[63:56]});
    row4_value[63:56] = row4_value[63:56] + (color_weights[31:24] + hdr.qlr_updates[2].value - row4_value[63:56]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[63:56]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[63:56]});
    row5_value[63:56] = row5_value[63:56] + (color_weights[39:32] + hdr.qlr_updates[3].value - row5_value[63:56]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[63:56]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r2_r3_r5_c1() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[7:0]});
    row2_value[7:0] = row2_value[7:0] + (color_weights[15:8] + hdr.qlr_updates[0].value - row2_value[7:0]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[7:0]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[7:0]});
    row3_value[7:0] = row3_value[7:0] + (color_weights[23:16] + hdr.qlr_updates[1].value - row3_value[7:0]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[7:0]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[7:0]});
    row5_value[7:0] = row5_value[7:0] + (color_weights[39:32] + hdr.qlr_updates[2].value - row5_value[7:0]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[7:0]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r2_r3_r5_c2() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[15:8]});
    row2_value[15:8] = row2_value[15:8] + (color_weights[15:8] + hdr.qlr_updates[0].value - row2_value[15:8]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[15:8]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[15:8]});
    row3_value[15:8] = row3_value[15:8] + (color_weights[23:16] + hdr.qlr_updates[1].value - row3_value[15:8]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[15:8]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[15:8]});
    row5_value[15:8] = row5_value[15:8] + (color_weights[39:32] + hdr.qlr_updates[2].value - row5_value[15:8]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[15:8]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r2_r3_r5_c3() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[23:16]});
    row2_value[23:16] = row2_value[23:16] + (color_weights[15:8] + hdr.qlr_updates[0].value - row2_value[23:16]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[23:16]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[23:16]});
    row3_value[23:16] = row3_value[23:16] + (color_weights[23:16] + hdr.qlr_updates[1].value - row3_value[23:16]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[23:16]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[23:16]});
    row5_value[23:16] = row5_value[23:16] + (color_weights[39:32] + hdr.qlr_updates[2].value - row5_value[23:16]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[23:16]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r2_r3_r5_c4() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[31:24]});
    row2_value[31:24] = row2_value[31:24] + (color_weights[15:8] + hdr.qlr_updates[0].value - row2_value[31:24]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[31:24]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[31:24]});
    row3_value[31:24] = row3_value[31:24] + (color_weights[23:16] + hdr.qlr_updates[1].value - row3_value[31:24]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[31:24]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[31:24]});
    row5_value[31:24] = row5_value[31:24] + (color_weights[39:32] + hdr.qlr_updates[2].value - row5_value[31:24]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[31:24]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r2_r3_r5_c5() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[39:32]});
    row2_value[39:32] = row2_value[39:32] + (color_weights[15:8] + hdr.qlr_updates[0].value - row2_value[39:32]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[39:32]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[39:32]});
    row3_value[39:32] = row3_value[39:32] + (color_weights[23:16] + hdr.qlr_updates[1].value - row3_value[39:32]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[39:32]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[39:32]});
    row5_value[39:32] = row5_value[39:32] + (color_weights[39:32] + hdr.qlr_updates[2].value - row5_value[39:32]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[39:32]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r2_r3_r5_c6() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[47:40]});
    row2_value[47:40] = row2_value[47:40] + (color_weights[15:8] + hdr.qlr_updates[0].value - row2_value[47:40]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[47:40]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[47:40]});
    row3_value[47:40] = row3_value[47:40] + (color_weights[23:16] + hdr.qlr_updates[1].value - row3_value[47:40]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[47:40]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[47:40]});
    row5_value[47:40] = row5_value[47:40] + (color_weights[39:32] + hdr.qlr_updates[2].value - row5_value[47:40]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[47:40]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r2_r3_r5_c7() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[55:48]});
    row2_value[55:48] = row2_value[55:48] + (color_weights[15:8] + hdr.qlr_updates[0].value - row2_value[55:48]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[55:48]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[55:48]});
    row3_value[55:48] = row3_value[55:48] + (color_weights[23:16] + hdr.qlr_updates[1].value - row3_value[55:48]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[55:48]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[55:48]});
    row5_value[55:48] = row5_value[55:48] + (color_weights[39:32] + hdr.qlr_updates[2].value - row5_value[55:48]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[55:48]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r2_r3_r5_c8() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[63:56]});
    row2_value[63:56] = row2_value[63:56] + (color_weights[15:8] + hdr.qlr_updates[0].value - row2_value[63:56]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[63:56]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[63:56]});
    row3_value[63:56] = row3_value[63:56] + (color_weights[23:16] + hdr.qlr_updates[1].value - row3_value[63:56]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[63:56]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[63:56]});
    row5_value[63:56] = row5_value[63:56] + (color_weights[39:32] + hdr.qlr_updates[2].value - row5_value[63:56]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[63:56]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r2_r4_c1() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[7:0]});
    row2_value[7:0] = row2_value[7:0] + (color_weights[15:8] + hdr.qlr_updates[0].value - row2_value[7:0]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[7:0]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[7:0]});
    row4_value[7:0] = row4_value[7:0] + (color_weights[31:24] + hdr.qlr_updates[1].value - row4_value[7:0]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[7:0]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r2_r4_c2() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[15:8]});
    row2_value[15:8] = row2_value[15:8] + (color_weights[15:8] + hdr.qlr_updates[0].value - row2_value[15:8]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[15:8]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[15:8]});
    row4_value[15:8] = row4_value[15:8] + (color_weights[31:24] + hdr.qlr_updates[1].value - row4_value[15:8]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[15:8]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r2_r4_c3() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[23:16]});
    row2_value[23:16] = row2_value[23:16] + (color_weights[15:8] + hdr.qlr_updates[0].value - row2_value[23:16]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[23:16]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[23:16]});
    row4_value[23:16] = row4_value[23:16] + (color_weights[31:24] + hdr.qlr_updates[1].value - row4_value[23:16]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[23:16]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r2_r4_c4() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[31:24]});
    row2_value[31:24] = row2_value[31:24] + (color_weights[15:8] + hdr.qlr_updates[0].value - row2_value[31:24]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[31:24]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[31:24]});
    row4_value[31:24] = row4_value[31:24] + (color_weights[31:24] + hdr.qlr_updates[1].value - row4_value[31:24]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[31:24]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r2_r4_c5() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[39:32]});
    row2_value[39:32] = row2_value[39:32] + (color_weights[15:8] + hdr.qlr_updates[0].value - row2_value[39:32]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[39:32]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[39:32]});
    row4_value[39:32] = row4_value[39:32] + (color_weights[31:24] + hdr.qlr_updates[1].value - row4_value[39:32]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[39:32]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r2_r4_c6() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[47:40]});
    row2_value[47:40] = row2_value[47:40] + (color_weights[15:8] + hdr.qlr_updates[0].value - row2_value[47:40]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[47:40]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[47:40]});
    row4_value[47:40] = row4_value[47:40] + (color_weights[31:24] + hdr.qlr_updates[1].value - row4_value[47:40]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[47:40]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r2_r4_c7() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[55:48]});
    row2_value[55:48] = row2_value[55:48] + (color_weights[15:8] + hdr.qlr_updates[0].value - row2_value[55:48]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[55:48]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[55:48]});
    row4_value[55:48] = row4_value[55:48] + (color_weights[31:24] + hdr.qlr_updates[1].value - row4_value[55:48]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[55:48]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r2_r4_c8() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[63:56]});
    row2_value[63:56] = row2_value[63:56] + (color_weights[15:8] + hdr.qlr_updates[0].value - row2_value[63:56]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[63:56]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[63:56]});
    row4_value[63:56] = row4_value[63:56] + (color_weights[31:24] + hdr.qlr_updates[1].value - row4_value[63:56]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[63:56]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r2_r4_r5_c1() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[7:0]});
    row2_value[7:0] = row2_value[7:0] + (color_weights[15:8] + hdr.qlr_updates[0].value - row2_value[7:0]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[7:0]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[7:0]});
    row4_value[7:0] = row4_value[7:0] + (color_weights[31:24] + hdr.qlr_updates[1].value - row4_value[7:0]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[7:0]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[7:0]});
    row5_value[7:0] = row5_value[7:0] + (color_weights[39:32] + hdr.qlr_updates[2].value - row5_value[7:0]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[7:0]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r2_r4_r5_c2() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[15:8]});
    row2_value[15:8] = row2_value[15:8] + (color_weights[15:8] + hdr.qlr_updates[0].value - row2_value[15:8]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[15:8]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[15:8]});
    row4_value[15:8] = row4_value[15:8] + (color_weights[31:24] + hdr.qlr_updates[1].value - row4_value[15:8]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[15:8]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[15:8]});
    row5_value[15:8] = row5_value[15:8] + (color_weights[39:32] + hdr.qlr_updates[2].value - row5_value[15:8]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[15:8]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r2_r4_r5_c3() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[23:16]});
    row2_value[23:16] = row2_value[23:16] + (color_weights[15:8] + hdr.qlr_updates[0].value - row2_value[23:16]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[23:16]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[23:16]});
    row4_value[23:16] = row4_value[23:16] + (color_weights[31:24] + hdr.qlr_updates[1].value - row4_value[23:16]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[23:16]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[23:16]});
    row5_value[23:16] = row5_value[23:16] + (color_weights[39:32] + hdr.qlr_updates[2].value - row5_value[23:16]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[23:16]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r2_r4_r5_c4() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[31:24]});
    row2_value[31:24] = row2_value[31:24] + (color_weights[15:8] + hdr.qlr_updates[0].value - row2_value[31:24]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[31:24]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[31:24]});
    row4_value[31:24] = row4_value[31:24] + (color_weights[31:24] + hdr.qlr_updates[1].value - row4_value[31:24]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[31:24]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[31:24]});
    row5_value[31:24] = row5_value[31:24] + (color_weights[39:32] + hdr.qlr_updates[2].value - row5_value[31:24]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[31:24]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r2_r4_r5_c5() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[39:32]});
    row2_value[39:32] = row2_value[39:32] + (color_weights[15:8] + hdr.qlr_updates[0].value - row2_value[39:32]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[39:32]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[39:32]});
    row4_value[39:32] = row4_value[39:32] + (color_weights[31:24] + hdr.qlr_updates[1].value - row4_value[39:32]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[39:32]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[39:32]});
    row5_value[39:32] = row5_value[39:32] + (color_weights[39:32] + hdr.qlr_updates[2].value - row5_value[39:32]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[39:32]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r2_r4_r5_c6() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[47:40]});
    row2_value[47:40] = row2_value[47:40] + (color_weights[15:8] + hdr.qlr_updates[0].value - row2_value[47:40]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[47:40]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[47:40]});
    row4_value[47:40] = row4_value[47:40] + (color_weights[31:24] + hdr.qlr_updates[1].value - row4_value[47:40]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[47:40]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[47:40]});
    row5_value[47:40] = row5_value[47:40] + (color_weights[39:32] + hdr.qlr_updates[2].value - row5_value[47:40]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[47:40]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r2_r4_r5_c7() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[55:48]});
    row2_value[55:48] = row2_value[55:48] + (color_weights[15:8] + hdr.qlr_updates[0].value - row2_value[55:48]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[55:48]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[55:48]});
    row4_value[55:48] = row4_value[55:48] + (color_weights[31:24] + hdr.qlr_updates[1].value - row4_value[55:48]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[55:48]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[55:48]});
    row5_value[55:48] = row5_value[55:48] + (color_weights[39:32] + hdr.qlr_updates[2].value - row5_value[55:48]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[55:48]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r2_r4_r5_c8() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[63:56]});
    row2_value[63:56] = row2_value[63:56] + (color_weights[15:8] + hdr.qlr_updates[0].value - row2_value[63:56]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[63:56]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[63:56]});
    row4_value[63:56] = row4_value[63:56] + (color_weights[31:24] + hdr.qlr_updates[1].value - row4_value[63:56]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[63:56]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[63:56]});
    row5_value[63:56] = row5_value[63:56] + (color_weights[39:32] + hdr.qlr_updates[2].value - row5_value[63:56]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[63:56]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r2_r5_c1() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[7:0]});
    row2_value[7:0] = row2_value[7:0] + (color_weights[15:8] + hdr.qlr_updates[0].value - row2_value[7:0]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[7:0]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[7:0]});
    row5_value[7:0] = row5_value[7:0] + (color_weights[39:32] + hdr.qlr_updates[1].value - row5_value[7:0]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[7:0]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r2_r5_c2() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[15:8]});
    row2_value[15:8] = row2_value[15:8] + (color_weights[15:8] + hdr.qlr_updates[0].value - row2_value[15:8]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[15:8]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[15:8]});
    row5_value[15:8] = row5_value[15:8] + (color_weights[39:32] + hdr.qlr_updates[1].value - row5_value[15:8]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[15:8]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r2_r5_c3() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[23:16]});
    row2_value[23:16] = row2_value[23:16] + (color_weights[15:8] + hdr.qlr_updates[0].value - row2_value[23:16]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[23:16]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[23:16]});
    row5_value[23:16] = row5_value[23:16] + (color_weights[39:32] + hdr.qlr_updates[1].value - row5_value[23:16]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[23:16]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r2_r5_c4() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[31:24]});
    row2_value[31:24] = row2_value[31:24] + (color_weights[15:8] + hdr.qlr_updates[0].value - row2_value[31:24]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[31:24]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[31:24]});
    row5_value[31:24] = row5_value[31:24] + (color_weights[39:32] + hdr.qlr_updates[1].value - row5_value[31:24]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[31:24]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r2_r5_c5() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[39:32]});
    row2_value[39:32] = row2_value[39:32] + (color_weights[15:8] + hdr.qlr_updates[0].value - row2_value[39:32]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[39:32]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[39:32]});
    row5_value[39:32] = row5_value[39:32] + (color_weights[39:32] + hdr.qlr_updates[1].value - row5_value[39:32]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[39:32]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r2_r5_c6() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[47:40]});
    row2_value[47:40] = row2_value[47:40] + (color_weights[15:8] + hdr.qlr_updates[0].value - row2_value[47:40]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[47:40]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[47:40]});
    row5_value[47:40] = row5_value[47:40] + (color_weights[39:32] + hdr.qlr_updates[1].value - row5_value[47:40]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[47:40]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r2_r5_c7() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[55:48]});
    row2_value[55:48] = row2_value[55:48] + (color_weights[15:8] + hdr.qlr_updates[0].value - row2_value[55:48]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[55:48]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[55:48]});
    row5_value[55:48] = row5_value[55:48] + (color_weights[39:32] + hdr.qlr_updates[1].value - row5_value[55:48]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[55:48]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r2_r5_c8() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    row2.read(row2_value, 0);
    log_msg("node {} updating row2_value - before: {}", {nid, row2_value[63:56]});
    row2_value[63:56] = row2_value[63:56] + (color_weights[15:8] + hdr.qlr_updates[0].value - row2_value[63:56]);
    log_msg("node {} updating row2_value - after: {}", {nid, row2_value[63:56]});
    row2.write(0, row2_value);
    log_msg("node {} new row2_value: {}", {nid, row2_value});
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[63:56]});
    row5_value[63:56] = row5_value[63:56] + (color_weights[39:32] + hdr.qlr_updates[1].value - row5_value[63:56]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[63:56]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r3_c1() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[7:0]});
    row3_value[7:0] = row3_value[7:0] + (color_weights[23:16] + hdr.qlr_updates[0].value - row3_value[7:0]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[7:0]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r3_c2() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[15:8]});
    row3_value[15:8] = row3_value[15:8] + (color_weights[23:16] + hdr.qlr_updates[0].value - row3_value[15:8]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[15:8]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r3_c3() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[23:16]});
    row3_value[23:16] = row3_value[23:16] + (color_weights[23:16] + hdr.qlr_updates[0].value - row3_value[23:16]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[23:16]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r3_c4() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[31:24]});
    row3_value[31:24] = row3_value[31:24] + (color_weights[23:16] + hdr.qlr_updates[0].value - row3_value[31:24]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[31:24]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r3_c5() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[39:32]});
    row3_value[39:32] = row3_value[39:32] + (color_weights[23:16] + hdr.qlr_updates[0].value - row3_value[39:32]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[39:32]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r3_c6() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[47:40]});
    row3_value[47:40] = row3_value[47:40] + (color_weights[23:16] + hdr.qlr_updates[0].value - row3_value[47:40]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[47:40]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r3_c7() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[55:48]});
    row3_value[55:48] = row3_value[55:48] + (color_weights[23:16] + hdr.qlr_updates[0].value - row3_value[55:48]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[55:48]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r3_c8() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[63:56]});
    row3_value[63:56] = row3_value[63:56] + (color_weights[23:16] + hdr.qlr_updates[0].value - row3_value[63:56]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[63:56]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r3_r4_c1() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[7:0]});
    row3_value[7:0] = row3_value[7:0] + (color_weights[23:16] + hdr.qlr_updates[0].value - row3_value[7:0]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[7:0]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[7:0]});
    row4_value[7:0] = row4_value[7:0] + (color_weights[31:24] + hdr.qlr_updates[1].value - row4_value[7:0]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[7:0]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r3_r4_c2() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[15:8]});
    row3_value[15:8] = row3_value[15:8] + (color_weights[23:16] + hdr.qlr_updates[0].value - row3_value[15:8]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[15:8]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[15:8]});
    row4_value[15:8] = row4_value[15:8] + (color_weights[31:24] + hdr.qlr_updates[1].value - row4_value[15:8]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[15:8]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r3_r4_c3() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[23:16]});
    row3_value[23:16] = row3_value[23:16] + (color_weights[23:16] + hdr.qlr_updates[0].value - row3_value[23:16]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[23:16]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[23:16]});
    row4_value[23:16] = row4_value[23:16] + (color_weights[31:24] + hdr.qlr_updates[1].value - row4_value[23:16]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[23:16]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r3_r4_c4() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[31:24]});
    row3_value[31:24] = row3_value[31:24] + (color_weights[23:16] + hdr.qlr_updates[0].value - row3_value[31:24]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[31:24]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[31:24]});
    row4_value[31:24] = row4_value[31:24] + (color_weights[31:24] + hdr.qlr_updates[1].value - row4_value[31:24]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[31:24]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r3_r4_c5() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[39:32]});
    row3_value[39:32] = row3_value[39:32] + (color_weights[23:16] + hdr.qlr_updates[0].value - row3_value[39:32]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[39:32]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[39:32]});
    row4_value[39:32] = row4_value[39:32] + (color_weights[31:24] + hdr.qlr_updates[1].value - row4_value[39:32]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[39:32]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r3_r4_c6() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[47:40]});
    row3_value[47:40] = row3_value[47:40] + (color_weights[23:16] + hdr.qlr_updates[0].value - row3_value[47:40]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[47:40]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[47:40]});
    row4_value[47:40] = row4_value[47:40] + (color_weights[31:24] + hdr.qlr_updates[1].value - row4_value[47:40]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[47:40]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r3_r4_c7() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[55:48]});
    row3_value[55:48] = row3_value[55:48] + (color_weights[23:16] + hdr.qlr_updates[0].value - row3_value[55:48]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[55:48]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[55:48]});
    row4_value[55:48] = row4_value[55:48] + (color_weights[31:24] + hdr.qlr_updates[1].value - row4_value[55:48]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[55:48]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r3_r4_c8() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[63:56]});
    row3_value[63:56] = row3_value[63:56] + (color_weights[23:16] + hdr.qlr_updates[0].value - row3_value[63:56]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[63:56]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[63:56]});
    row4_value[63:56] = row4_value[63:56] + (color_weights[31:24] + hdr.qlr_updates[1].value - row4_value[63:56]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[63:56]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r3_r4_r5_c1() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[7:0]});
    row3_value[7:0] = row3_value[7:0] + (color_weights[23:16] + hdr.qlr_updates[0].value - row3_value[7:0]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[7:0]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[7:0]});
    row4_value[7:0] = row4_value[7:0] + (color_weights[31:24] + hdr.qlr_updates[1].value - row4_value[7:0]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[7:0]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[7:0]});
    row5_value[7:0] = row5_value[7:0] + (color_weights[39:32] + hdr.qlr_updates[2].value - row5_value[7:0]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[7:0]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r3_r4_r5_c2() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[15:8]});
    row3_value[15:8] = row3_value[15:8] + (color_weights[23:16] + hdr.qlr_updates[0].value - row3_value[15:8]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[15:8]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[15:8]});
    row4_value[15:8] = row4_value[15:8] + (color_weights[31:24] + hdr.qlr_updates[1].value - row4_value[15:8]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[15:8]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[15:8]});
    row5_value[15:8] = row5_value[15:8] + (color_weights[39:32] + hdr.qlr_updates[2].value - row5_value[15:8]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[15:8]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r3_r4_r5_c3() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[23:16]});
    row3_value[23:16] = row3_value[23:16] + (color_weights[23:16] + hdr.qlr_updates[0].value - row3_value[23:16]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[23:16]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[23:16]});
    row4_value[23:16] = row4_value[23:16] + (color_weights[31:24] + hdr.qlr_updates[1].value - row4_value[23:16]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[23:16]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[23:16]});
    row5_value[23:16] = row5_value[23:16] + (color_weights[39:32] + hdr.qlr_updates[2].value - row5_value[23:16]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[23:16]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r3_r4_r5_c4() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[31:24]});
    row3_value[31:24] = row3_value[31:24] + (color_weights[23:16] + hdr.qlr_updates[0].value - row3_value[31:24]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[31:24]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[31:24]});
    row4_value[31:24] = row4_value[31:24] + (color_weights[31:24] + hdr.qlr_updates[1].value - row4_value[31:24]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[31:24]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[31:24]});
    row5_value[31:24] = row5_value[31:24] + (color_weights[39:32] + hdr.qlr_updates[2].value - row5_value[31:24]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[31:24]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r3_r4_r5_c5() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[39:32]});
    row3_value[39:32] = row3_value[39:32] + (color_weights[23:16] + hdr.qlr_updates[0].value - row3_value[39:32]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[39:32]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[39:32]});
    row4_value[39:32] = row4_value[39:32] + (color_weights[31:24] + hdr.qlr_updates[1].value - row4_value[39:32]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[39:32]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[39:32]});
    row5_value[39:32] = row5_value[39:32] + (color_weights[39:32] + hdr.qlr_updates[2].value - row5_value[39:32]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[39:32]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r3_r4_r5_c6() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[47:40]});
    row3_value[47:40] = row3_value[47:40] + (color_weights[23:16] + hdr.qlr_updates[0].value - row3_value[47:40]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[47:40]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[47:40]});
    row4_value[47:40] = row4_value[47:40] + (color_weights[31:24] + hdr.qlr_updates[1].value - row4_value[47:40]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[47:40]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[47:40]});
    row5_value[47:40] = row5_value[47:40] + (color_weights[39:32] + hdr.qlr_updates[2].value - row5_value[47:40]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[47:40]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r3_r4_r5_c7() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[55:48]});
    row3_value[55:48] = row3_value[55:48] + (color_weights[23:16] + hdr.qlr_updates[0].value - row3_value[55:48]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[55:48]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[55:48]});
    row4_value[55:48] = row4_value[55:48] + (color_weights[31:24] + hdr.qlr_updates[1].value - row4_value[55:48]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[55:48]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[55:48]});
    row5_value[55:48] = row5_value[55:48] + (color_weights[39:32] + hdr.qlr_updates[2].value - row5_value[55:48]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[55:48]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r3_r4_r5_c8() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[63:56]});
    row3_value[63:56] = row3_value[63:56] + (color_weights[23:16] + hdr.qlr_updates[0].value - row3_value[63:56]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[63:56]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[63:56]});
    row4_value[63:56] = row4_value[63:56] + (color_weights[31:24] + hdr.qlr_updates[1].value - row4_value[63:56]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[63:56]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[63:56]});
    row5_value[63:56] = row5_value[63:56] + (color_weights[39:32] + hdr.qlr_updates[2].value - row5_value[63:56]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[63:56]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r3_r5_c1() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[7:0]});
    row3_value[7:0] = row3_value[7:0] + (color_weights[23:16] + hdr.qlr_updates[0].value - row3_value[7:0]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[7:0]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[7:0]});
    row5_value[7:0] = row5_value[7:0] + (color_weights[39:32] + hdr.qlr_updates[1].value - row5_value[7:0]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[7:0]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r3_r5_c2() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[15:8]});
    row3_value[15:8] = row3_value[15:8] + (color_weights[23:16] + hdr.qlr_updates[0].value - row3_value[15:8]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[15:8]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[15:8]});
    row5_value[15:8] = row5_value[15:8] + (color_weights[39:32] + hdr.qlr_updates[1].value - row5_value[15:8]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[15:8]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r3_r5_c3() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[23:16]});
    row3_value[23:16] = row3_value[23:16] + (color_weights[23:16] + hdr.qlr_updates[0].value - row3_value[23:16]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[23:16]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[23:16]});
    row5_value[23:16] = row5_value[23:16] + (color_weights[39:32] + hdr.qlr_updates[1].value - row5_value[23:16]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[23:16]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r3_r5_c4() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[31:24]});
    row3_value[31:24] = row3_value[31:24] + (color_weights[23:16] + hdr.qlr_updates[0].value - row3_value[31:24]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[31:24]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[31:24]});
    row5_value[31:24] = row5_value[31:24] + (color_weights[39:32] + hdr.qlr_updates[1].value - row5_value[31:24]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[31:24]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r3_r5_c5() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[39:32]});
    row3_value[39:32] = row3_value[39:32] + (color_weights[23:16] + hdr.qlr_updates[0].value - row3_value[39:32]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[39:32]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[39:32]});
    row5_value[39:32] = row5_value[39:32] + (color_weights[39:32] + hdr.qlr_updates[1].value - row5_value[39:32]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[39:32]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r3_r5_c6() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[47:40]});
    row3_value[47:40] = row3_value[47:40] + (color_weights[23:16] + hdr.qlr_updates[0].value - row3_value[47:40]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[47:40]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[47:40]});
    row5_value[47:40] = row5_value[47:40] + (color_weights[39:32] + hdr.qlr_updates[1].value - row5_value[47:40]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[47:40]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r3_r5_c7() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[55:48]});
    row3_value[55:48] = row3_value[55:48] + (color_weights[23:16] + hdr.qlr_updates[0].value - row3_value[55:48]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[55:48]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[55:48]});
    row5_value[55:48] = row5_value[55:48] + (color_weights[39:32] + hdr.qlr_updates[1].value - row5_value[55:48]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[55:48]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r3_r5_c8() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    row3.read(row3_value, 0);
    log_msg("node {} updating row3_value - before: {}", {nid, row3_value[63:56]});
    row3_value[63:56] = row3_value[63:56] + (color_weights[23:16] + hdr.qlr_updates[0].value - row3_value[63:56]);
    log_msg("node {} updating row3_value - after: {}", {nid, row3_value[63:56]});
    row3.write(0, row3_value);
    log_msg("node {} new row3_value: {}", {nid, row3_value});
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[63:56]});
    row5_value[63:56] = row5_value[63:56] + (color_weights[39:32] + hdr.qlr_updates[1].value - row5_value[63:56]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[63:56]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r4_c1() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[7:0]});
    row4_value[7:0] = row4_value[7:0] + (color_weights[31:24] + hdr.qlr_updates[0].value - row4_value[7:0]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[7:0]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r4_c2() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[15:8]});
    row4_value[15:8] = row4_value[15:8] + (color_weights[31:24] + hdr.qlr_updates[0].value - row4_value[15:8]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[15:8]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r4_c3() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[23:16]});
    row4_value[23:16] = row4_value[23:16] + (color_weights[31:24] + hdr.qlr_updates[0].value - row4_value[23:16]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[23:16]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r4_c4() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[31:24]});
    row4_value[31:24] = row4_value[31:24] + (color_weights[31:24] + hdr.qlr_updates[0].value - row4_value[31:24]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[31:24]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r4_c5() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[39:32]});
    row4_value[39:32] = row4_value[39:32] + (color_weights[31:24] + hdr.qlr_updates[0].value - row4_value[39:32]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[39:32]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r4_c6() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[47:40]});
    row4_value[47:40] = row4_value[47:40] + (color_weights[31:24] + hdr.qlr_updates[0].value - row4_value[47:40]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[47:40]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r4_c7() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[55:48]});
    row4_value[55:48] = row4_value[55:48] + (color_weights[31:24] + hdr.qlr_updates[0].value - row4_value[55:48]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[55:48]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r4_c8() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[63:56]});
    row4_value[63:56] = row4_value[63:56] + (color_weights[31:24] + hdr.qlr_updates[0].value - row4_value[63:56]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[63:56]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_r4_r5_c1() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[7:0]});
    row4_value[7:0] = row4_value[7:0] + (color_weights[31:24] + hdr.qlr_updates[0].value - row4_value[7:0]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[7:0]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[7:0]});
    row5_value[7:0] = row5_value[7:0] + (color_weights[39:32] + hdr.qlr_updates[1].value - row5_value[7:0]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[7:0]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r4_r5_c2() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[15:8]});
    row4_value[15:8] = row4_value[15:8] + (color_weights[31:24] + hdr.qlr_updates[0].value - row4_value[15:8]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[15:8]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[15:8]});
    row5_value[15:8] = row5_value[15:8] + (color_weights[39:32] + hdr.qlr_updates[1].value - row5_value[15:8]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[15:8]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r4_r5_c3() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[23:16]});
    row4_value[23:16] = row4_value[23:16] + (color_weights[31:24] + hdr.qlr_updates[0].value - row4_value[23:16]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[23:16]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[23:16]});
    row5_value[23:16] = row5_value[23:16] + (color_weights[39:32] + hdr.qlr_updates[1].value - row5_value[23:16]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[23:16]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r4_r5_c4() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[31:24]});
    row4_value[31:24] = row4_value[31:24] + (color_weights[31:24] + hdr.qlr_updates[0].value - row4_value[31:24]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[31:24]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[31:24]});
    row5_value[31:24] = row5_value[31:24] + (color_weights[39:32] + hdr.qlr_updates[1].value - row5_value[31:24]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[31:24]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r4_r5_c5() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[39:32]});
    row4_value[39:32] = row4_value[39:32] + (color_weights[31:24] + hdr.qlr_updates[0].value - row4_value[39:32]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[39:32]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[39:32]});
    row5_value[39:32] = row5_value[39:32] + (color_weights[39:32] + hdr.qlr_updates[1].value - row5_value[39:32]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[39:32]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r4_r5_c6() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[47:40]});
    row4_value[47:40] = row4_value[47:40] + (color_weights[31:24] + hdr.qlr_updates[0].value - row4_value[47:40]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[47:40]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[47:40]});
    row5_value[47:40] = row5_value[47:40] + (color_weights[39:32] + hdr.qlr_updates[1].value - row5_value[47:40]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[47:40]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r4_r5_c7() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[55:48]});
    row4_value[55:48] = row4_value[55:48] + (color_weights[31:24] + hdr.qlr_updates[0].value - row4_value[55:48]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[55:48]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[55:48]});
    row5_value[55:48] = row5_value[55:48] + (color_weights[39:32] + hdr.qlr_updates[1].value - row5_value[55:48]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[55:48]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r4_r5_c8() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    row4.read(row4_value, 0);
    log_msg("node {} updating row4_value - before: {}", {nid, row4_value[63:56]});
    row4_value[63:56] = row4_value[63:56] + (color_weights[31:24] + hdr.qlr_updates[0].value - row4_value[63:56]);
    log_msg("node {} updating row4_value - after: {}", {nid, row4_value[63:56]});
    row4.write(0, row4_value);
    log_msg("node {} new row4_value: {}", {nid, row4_value});
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[63:56]});
    row5_value[63:56] = row5_value[63:56] + (color_weights[39:32] + hdr.qlr_updates[1].value - row5_value[63:56]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[63:56]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r5_c1() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[7:0]});
    row5_value[7:0] = row5_value[7:0] + (color_weights[39:32] + hdr.qlr_updates[0].value - row5_value[7:0]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[7:0]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r5_c2() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[15:8]});
    row5_value[15:8] = row5_value[15:8] + (color_weights[39:32] + hdr.qlr_updates[0].value - row5_value[15:8]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[15:8]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r5_c3() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[23:16]});
    row5_value[23:16] = row5_value[23:16] + (color_weights[39:32] + hdr.qlr_updates[0].value - row5_value[23:16]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[23:16]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r5_c4() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[31:24]});
    row5_value[31:24] = row5_value[31:24] + (color_weights[39:32] + hdr.qlr_updates[0].value - row5_value[31:24]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[31:24]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r5_c5() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[39:32]});
    row5_value[39:32] = row5_value[39:32] + (color_weights[39:32] + hdr.qlr_updates[0].value - row5_value[39:32]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[39:32]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r5_c6() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[47:40]});
    row5_value[47:40] = row5_value[47:40] + (color_weights[39:32] + hdr.qlr_updates[0].value - row5_value[47:40]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[47:40]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r5_c7() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[55:48]});
    row5_value[55:48] = row5_value[55:48] + (color_weights[39:32] + hdr.qlr_updates[0].value - row5_value[55:48]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[55:48]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action qmatrix_update_r5_c8() {
    bit<8> nid;
    node_id_reg.read(nid, 0);
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    row5.read(row5_value, 0);
    log_msg("node {} updating row5_value - before: {}", {nid, row5_value[63:56]});
    row5_value[63:56] = row5_value[63:56] + (color_weights[39:32] + hdr.qlr_updates[0].value - row5_value[63:56]);
    log_msg("node {} updating row5_value - after: {}", {nid, row5_value[63:56]});
    row5.write(0, row5_value);
    log_msg("node {} new row5_value: {}", {nid, row5_value});
}

action read_all() {
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

table qmatrix_update {
    key = {
        hdr.qlr_updates[0].isValid(): exact;
        hdr.qlr_updates[0].dst_id: exact;
        hdr.qlr_updates[1].isValid(): exact;
        hdr.qlr_updates[1].dst_id: exact;
        hdr.qlr_updates[2].isValid(): exact;
        hdr.qlr_updates[2].dst_id: exact;
        hdr.qlr_updates[3].isValid(): exact;
        hdr.qlr_updates[3].dst_id: exact;
        hdr.qlr_updates[4].isValid(): exact;
        hdr.qlr_updates[4].dst_id: exact;
        ig_idx: exact;
    }
    actions = {
        qmatrix_update_r1_c1;
        qmatrix_update_r1_c2;
        qmatrix_update_r1_c3;
        qmatrix_update_r1_c4;
        qmatrix_update_r1_c5;
        qmatrix_update_r1_c6;
        qmatrix_update_r1_c7;
        qmatrix_update_r1_c8;
        qmatrix_update_r1_r2_c1;
        qmatrix_update_r1_r2_c2;
        qmatrix_update_r1_r2_c3;
        qmatrix_update_r1_r2_c4;
        qmatrix_update_r1_r2_c5;
        qmatrix_update_r1_r2_c6;
        qmatrix_update_r1_r2_c7;
        qmatrix_update_r1_r2_c8;
        qmatrix_update_r1_r2_r3_c1;
        qmatrix_update_r1_r2_r3_c2;
        qmatrix_update_r1_r2_r3_c3;
        qmatrix_update_r1_r2_r3_c4;
        qmatrix_update_r1_r2_r3_c5;
        qmatrix_update_r1_r2_r3_c6;
        qmatrix_update_r1_r2_r3_c7;
        qmatrix_update_r1_r2_r3_c8;
        qmatrix_update_r1_r2_r3_r4_c1;
        qmatrix_update_r1_r2_r3_r4_c2;
        qmatrix_update_r1_r2_r3_r4_c3;
        qmatrix_update_r1_r2_r3_r4_c4;
        qmatrix_update_r1_r2_r3_r4_c5;
        qmatrix_update_r1_r2_r3_r4_c6;
        qmatrix_update_r1_r2_r3_r4_c7;
        qmatrix_update_r1_r2_r3_r4_c8;
        qmatrix_update_r1_r2_r3_r4_r5_c1;
        qmatrix_update_r1_r2_r3_r4_r5_c2;
        qmatrix_update_r1_r2_r3_r4_r5_c3;
        qmatrix_update_r1_r2_r3_r4_r5_c4;
        qmatrix_update_r1_r2_r3_r4_r5_c5;
        qmatrix_update_r1_r2_r3_r4_r5_c6;
        qmatrix_update_r1_r2_r3_r4_r5_c7;
        qmatrix_update_r1_r2_r3_r4_r5_c8;
        qmatrix_update_r1_r2_r3_r5_c1;
        qmatrix_update_r1_r2_r3_r5_c2;
        qmatrix_update_r1_r2_r3_r5_c3;
        qmatrix_update_r1_r2_r3_r5_c4;
        qmatrix_update_r1_r2_r3_r5_c5;
        qmatrix_update_r1_r2_r3_r5_c6;
        qmatrix_update_r1_r2_r3_r5_c7;
        qmatrix_update_r1_r2_r3_r5_c8;
        qmatrix_update_r1_r2_r4_c1;
        qmatrix_update_r1_r2_r4_c2;
        qmatrix_update_r1_r2_r4_c3;
        qmatrix_update_r1_r2_r4_c4;
        qmatrix_update_r1_r2_r4_c5;
        qmatrix_update_r1_r2_r4_c6;
        qmatrix_update_r1_r2_r4_c7;
        qmatrix_update_r1_r2_r4_c8;
        qmatrix_update_r1_r2_r4_r5_c1;
        qmatrix_update_r1_r2_r4_r5_c2;
        qmatrix_update_r1_r2_r4_r5_c3;
        qmatrix_update_r1_r2_r4_r5_c4;
        qmatrix_update_r1_r2_r4_r5_c5;
        qmatrix_update_r1_r2_r4_r5_c6;
        qmatrix_update_r1_r2_r4_r5_c7;
        qmatrix_update_r1_r2_r4_r5_c8;
        qmatrix_update_r1_r2_r5_c1;
        qmatrix_update_r1_r2_r5_c2;
        qmatrix_update_r1_r2_r5_c3;
        qmatrix_update_r1_r2_r5_c4;
        qmatrix_update_r1_r2_r5_c5;
        qmatrix_update_r1_r2_r5_c6;
        qmatrix_update_r1_r2_r5_c7;
        qmatrix_update_r1_r2_r5_c8;
        qmatrix_update_r1_r3_c1;
        qmatrix_update_r1_r3_c2;
        qmatrix_update_r1_r3_c3;
        qmatrix_update_r1_r3_c4;
        qmatrix_update_r1_r3_c5;
        qmatrix_update_r1_r3_c6;
        qmatrix_update_r1_r3_c7;
        qmatrix_update_r1_r3_c8;
        qmatrix_update_r1_r3_r4_c1;
        qmatrix_update_r1_r3_r4_c2;
        qmatrix_update_r1_r3_r4_c3;
        qmatrix_update_r1_r3_r4_c4;
        qmatrix_update_r1_r3_r4_c5;
        qmatrix_update_r1_r3_r4_c6;
        qmatrix_update_r1_r3_r4_c7;
        qmatrix_update_r1_r3_r4_c8;
        qmatrix_update_r1_r3_r4_r5_c1;
        qmatrix_update_r1_r3_r4_r5_c2;
        qmatrix_update_r1_r3_r4_r5_c3;
        qmatrix_update_r1_r3_r4_r5_c4;
        qmatrix_update_r1_r3_r4_r5_c5;
        qmatrix_update_r1_r3_r4_r5_c6;
        qmatrix_update_r1_r3_r4_r5_c7;
        qmatrix_update_r1_r3_r4_r5_c8;
        qmatrix_update_r1_r3_r5_c1;
        qmatrix_update_r1_r3_r5_c2;
        qmatrix_update_r1_r3_r5_c3;
        qmatrix_update_r1_r3_r5_c4;
        qmatrix_update_r1_r3_r5_c5;
        qmatrix_update_r1_r3_r5_c6;
        qmatrix_update_r1_r3_r5_c7;
        qmatrix_update_r1_r3_r5_c8;
        qmatrix_update_r1_r4_c1;
        qmatrix_update_r1_r4_c2;
        qmatrix_update_r1_r4_c3;
        qmatrix_update_r1_r4_c4;
        qmatrix_update_r1_r4_c5;
        qmatrix_update_r1_r4_c6;
        qmatrix_update_r1_r4_c7;
        qmatrix_update_r1_r4_c8;
        qmatrix_update_r1_r4_r5_c1;
        qmatrix_update_r1_r4_r5_c2;
        qmatrix_update_r1_r4_r5_c3;
        qmatrix_update_r1_r4_r5_c4;
        qmatrix_update_r1_r4_r5_c5;
        qmatrix_update_r1_r4_r5_c6;
        qmatrix_update_r1_r4_r5_c7;
        qmatrix_update_r1_r4_r5_c8;
        qmatrix_update_r1_r5_c1;
        qmatrix_update_r1_r5_c2;
        qmatrix_update_r1_r5_c3;
        qmatrix_update_r1_r5_c4;
        qmatrix_update_r1_r5_c5;
        qmatrix_update_r1_r5_c6;
        qmatrix_update_r1_r5_c7;
        qmatrix_update_r1_r5_c8;
        qmatrix_update_r2_c1;
        qmatrix_update_r2_c2;
        qmatrix_update_r2_c3;
        qmatrix_update_r2_c4;
        qmatrix_update_r2_c5;
        qmatrix_update_r2_c6;
        qmatrix_update_r2_c7;
        qmatrix_update_r2_c8;
        qmatrix_update_r2_r3_c1;
        qmatrix_update_r2_r3_c2;
        qmatrix_update_r2_r3_c3;
        qmatrix_update_r2_r3_c4;
        qmatrix_update_r2_r3_c5;
        qmatrix_update_r2_r3_c6;
        qmatrix_update_r2_r3_c7;
        qmatrix_update_r2_r3_c8;
        qmatrix_update_r2_r3_r4_c1;
        qmatrix_update_r2_r3_r4_c2;
        qmatrix_update_r2_r3_r4_c3;
        qmatrix_update_r2_r3_r4_c4;
        qmatrix_update_r2_r3_r4_c5;
        qmatrix_update_r2_r3_r4_c6;
        qmatrix_update_r2_r3_r4_c7;
        qmatrix_update_r2_r3_r4_c8;
        qmatrix_update_r2_r3_r4_r5_c1;
        qmatrix_update_r2_r3_r4_r5_c2;
        qmatrix_update_r2_r3_r4_r5_c3;
        qmatrix_update_r2_r3_r4_r5_c4;
        qmatrix_update_r2_r3_r4_r5_c5;
        qmatrix_update_r2_r3_r4_r5_c6;
        qmatrix_update_r2_r3_r4_r5_c7;
        qmatrix_update_r2_r3_r4_r5_c8;
        qmatrix_update_r2_r3_r5_c1;
        qmatrix_update_r2_r3_r5_c2;
        qmatrix_update_r2_r3_r5_c3;
        qmatrix_update_r2_r3_r5_c4;
        qmatrix_update_r2_r3_r5_c5;
        qmatrix_update_r2_r3_r5_c6;
        qmatrix_update_r2_r3_r5_c7;
        qmatrix_update_r2_r3_r5_c8;
        qmatrix_update_r2_r4_c1;
        qmatrix_update_r2_r4_c2;
        qmatrix_update_r2_r4_c3;
        qmatrix_update_r2_r4_c4;
        qmatrix_update_r2_r4_c5;
        qmatrix_update_r2_r4_c6;
        qmatrix_update_r2_r4_c7;
        qmatrix_update_r2_r4_c8;
        qmatrix_update_r2_r4_r5_c1;
        qmatrix_update_r2_r4_r5_c2;
        qmatrix_update_r2_r4_r5_c3;
        qmatrix_update_r2_r4_r5_c4;
        qmatrix_update_r2_r4_r5_c5;
        qmatrix_update_r2_r4_r5_c6;
        qmatrix_update_r2_r4_r5_c7;
        qmatrix_update_r2_r4_r5_c8;
        qmatrix_update_r2_r5_c1;
        qmatrix_update_r2_r5_c2;
        qmatrix_update_r2_r5_c3;
        qmatrix_update_r2_r5_c4;
        qmatrix_update_r2_r5_c5;
        qmatrix_update_r2_r5_c6;
        qmatrix_update_r2_r5_c7;
        qmatrix_update_r2_r5_c8;
        qmatrix_update_r3_c1;
        qmatrix_update_r3_c2;
        qmatrix_update_r3_c3;
        qmatrix_update_r3_c4;
        qmatrix_update_r3_c5;
        qmatrix_update_r3_c6;
        qmatrix_update_r3_c7;
        qmatrix_update_r3_c8;
        qmatrix_update_r3_r4_c1;
        qmatrix_update_r3_r4_c2;
        qmatrix_update_r3_r4_c3;
        qmatrix_update_r3_r4_c4;
        qmatrix_update_r3_r4_c5;
        qmatrix_update_r3_r4_c6;
        qmatrix_update_r3_r4_c7;
        qmatrix_update_r3_r4_c8;
        qmatrix_update_r3_r4_r5_c1;
        qmatrix_update_r3_r4_r5_c2;
        qmatrix_update_r3_r4_r5_c3;
        qmatrix_update_r3_r4_r5_c4;
        qmatrix_update_r3_r4_r5_c5;
        qmatrix_update_r3_r4_r5_c6;
        qmatrix_update_r3_r4_r5_c7;
        qmatrix_update_r3_r4_r5_c8;
        qmatrix_update_r3_r5_c1;
        qmatrix_update_r3_r5_c2;
        qmatrix_update_r3_r5_c3;
        qmatrix_update_r3_r5_c4;
        qmatrix_update_r3_r5_c5;
        qmatrix_update_r3_r5_c6;
        qmatrix_update_r3_r5_c7;
        qmatrix_update_r3_r5_c8;
        qmatrix_update_r4_c1;
        qmatrix_update_r4_c2;
        qmatrix_update_r4_c3;
        qmatrix_update_r4_c4;
        qmatrix_update_r4_c5;
        qmatrix_update_r4_c6;
        qmatrix_update_r4_c7;
        qmatrix_update_r4_c8;
        qmatrix_update_r4_r5_c1;
        qmatrix_update_r4_r5_c2;
        qmatrix_update_r4_r5_c3;
        qmatrix_update_r4_r5_c4;
        qmatrix_update_r4_r5_c5;
        qmatrix_update_r4_r5_c6;
        qmatrix_update_r4_r5_c7;
        qmatrix_update_r4_r5_c8;
        qmatrix_update_r5_c1;
        qmatrix_update_r5_c2;
        qmatrix_update_r5_c3;
        qmatrix_update_r5_c4;
        qmatrix_update_r5_c5;
        qmatrix_update_r5_c6;
        qmatrix_update_r5_c7;
        qmatrix_update_r5_c8;
        read_all;
    }
    const default_action = read_all;
    const entries = {
        (true, 1, false, 0, false, 0, false, 0, false, 0, 1): qmatrix_update_r1_c1();
        (true, 1, false, 0, false, 0, false, 0, false, 0, 2): qmatrix_update_r1_c2();
        (true, 1, false, 0, false, 0, false, 0, false, 0, 3): qmatrix_update_r1_c3();
        (true, 1, false, 0, false, 0, false, 0, false, 0, 4): qmatrix_update_r1_c4();
        (true, 1, false, 0, false, 0, false, 0, false, 0, 5): qmatrix_update_r1_c5();
        (true, 1, false, 0, false, 0, false, 0, false, 0, 6): qmatrix_update_r1_c6();
        (true, 1, false, 0, false, 0, false, 0, false, 0, 7): qmatrix_update_r1_c7();
        (true, 1, false, 0, false, 0, false, 0, false, 0, 8): qmatrix_update_r1_c8();
        (true, 1, true, 2, false, 0, false, 0, false, 0, 1): qmatrix_update_r1_r2_c1();
        (true, 1, true, 2, false, 0, false, 0, false, 0, 2): qmatrix_update_r1_r2_c2();
        (true, 1, true, 2, false, 0, false, 0, false, 0, 3): qmatrix_update_r1_r2_c3();
        (true, 1, true, 2, false, 0, false, 0, false, 0, 4): qmatrix_update_r1_r2_c4();
        (true, 1, true, 2, false, 0, false, 0, false, 0, 5): qmatrix_update_r1_r2_c5();
        (true, 1, true, 2, false, 0, false, 0, false, 0, 6): qmatrix_update_r1_r2_c6();
        (true, 1, true, 2, false, 0, false, 0, false, 0, 7): qmatrix_update_r1_r2_c7();
        (true, 1, true, 2, false, 0, false, 0, false, 0, 8): qmatrix_update_r1_r2_c8();
        (true, 1, true, 2, true, 3, false, 0, false, 0, 1): qmatrix_update_r1_r2_r3_c1();
        (true, 1, true, 2, true, 3, false, 0, false, 0, 2): qmatrix_update_r1_r2_r3_c2();
        (true, 1, true, 2, true, 3, false, 0, false, 0, 3): qmatrix_update_r1_r2_r3_c3();
        (true, 1, true, 2, true, 3, false, 0, false, 0, 4): qmatrix_update_r1_r2_r3_c4();
        (true, 1, true, 2, true, 3, false, 0, false, 0, 5): qmatrix_update_r1_r2_r3_c5();
        (true, 1, true, 2, true, 3, false, 0, false, 0, 6): qmatrix_update_r1_r2_r3_c6();
        (true, 1, true, 2, true, 3, false, 0, false, 0, 7): qmatrix_update_r1_r2_r3_c7();
        (true, 1, true, 2, true, 3, false, 0, false, 0, 8): qmatrix_update_r1_r2_r3_c8();
        (true, 1, true, 2, true, 3, true, 4, false, 0, 1): qmatrix_update_r1_r2_r3_r4_c1();
        (true, 1, true, 2, true, 3, true, 4, false, 0, 2): qmatrix_update_r1_r2_r3_r4_c2();
        (true, 1, true, 2, true, 3, true, 4, false, 0, 3): qmatrix_update_r1_r2_r3_r4_c3();
        (true, 1, true, 2, true, 3, true, 4, false, 0, 4): qmatrix_update_r1_r2_r3_r4_c4();
        (true, 1, true, 2, true, 3, true, 4, false, 0, 5): qmatrix_update_r1_r2_r3_r4_c5();
        (true, 1, true, 2, true, 3, true, 4, false, 0, 6): qmatrix_update_r1_r2_r3_r4_c6();
        (true, 1, true, 2, true, 3, true, 4, false, 0, 7): qmatrix_update_r1_r2_r3_r4_c7();
        (true, 1, true, 2, true, 3, true, 4, false, 0, 8): qmatrix_update_r1_r2_r3_r4_c8();
        (true, 1, true, 2, true, 3, true, 4, true, 5, 1): qmatrix_update_r1_r2_r3_r4_r5_c1();
        (true, 1, true, 2, true, 3, true, 4, true, 5, 2): qmatrix_update_r1_r2_r3_r4_r5_c2();
        (true, 1, true, 2, true, 3, true, 4, true, 5, 3): qmatrix_update_r1_r2_r3_r4_r5_c3();
        (true, 1, true, 2, true, 3, true, 4, true, 5, 4): qmatrix_update_r1_r2_r3_r4_r5_c4();
        (true, 1, true, 2, true, 3, true, 4, true, 5, 5): qmatrix_update_r1_r2_r3_r4_r5_c5();
        (true, 1, true, 2, true, 3, true, 4, true, 5, 6): qmatrix_update_r1_r2_r3_r4_r5_c6();
        (true, 1, true, 2, true, 3, true, 4, true, 5, 7): qmatrix_update_r1_r2_r3_r4_r5_c7();
        (true, 1, true, 2, true, 3, true, 4, true, 5, 8): qmatrix_update_r1_r2_r3_r4_r5_c8();
        (true, 1, true, 2, true, 3, true, 5, false, 0, 1): qmatrix_update_r1_r2_r3_r5_c1();
        (true, 1, true, 2, true, 3, true, 5, false, 0, 2): qmatrix_update_r1_r2_r3_r5_c2();
        (true, 1, true, 2, true, 3, true, 5, false, 0, 3): qmatrix_update_r1_r2_r3_r5_c3();
        (true, 1, true, 2, true, 3, true, 5, false, 0, 4): qmatrix_update_r1_r2_r3_r5_c4();
        (true, 1, true, 2, true, 3, true, 5, false, 0, 5): qmatrix_update_r1_r2_r3_r5_c5();
        (true, 1, true, 2, true, 3, true, 5, false, 0, 6): qmatrix_update_r1_r2_r3_r5_c6();
        (true, 1, true, 2, true, 3, true, 5, false, 0, 7): qmatrix_update_r1_r2_r3_r5_c7();
        (true, 1, true, 2, true, 3, true, 5, false, 0, 8): qmatrix_update_r1_r2_r3_r5_c8();
        (true, 1, true, 2, true, 4, false, 0, false, 0, 1): qmatrix_update_r1_r2_r4_c1();
        (true, 1, true, 2, true, 4, false, 0, false, 0, 2): qmatrix_update_r1_r2_r4_c2();
        (true, 1, true, 2, true, 4, false, 0, false, 0, 3): qmatrix_update_r1_r2_r4_c3();
        (true, 1, true, 2, true, 4, false, 0, false, 0, 4): qmatrix_update_r1_r2_r4_c4();
        (true, 1, true, 2, true, 4, false, 0, false, 0, 5): qmatrix_update_r1_r2_r4_c5();
        (true, 1, true, 2, true, 4, false, 0, false, 0, 6): qmatrix_update_r1_r2_r4_c6();
        (true, 1, true, 2, true, 4, false, 0, false, 0, 7): qmatrix_update_r1_r2_r4_c7();
        (true, 1, true, 2, true, 4, false, 0, false, 0, 8): qmatrix_update_r1_r2_r4_c8();
        (true, 1, true, 2, true, 4, true, 5, false, 0, 1): qmatrix_update_r1_r2_r4_r5_c1();
        (true, 1, true, 2, true, 4, true, 5, false, 0, 2): qmatrix_update_r1_r2_r4_r5_c2();
        (true, 1, true, 2, true, 4, true, 5, false, 0, 3): qmatrix_update_r1_r2_r4_r5_c3();
        (true, 1, true, 2, true, 4, true, 5, false, 0, 4): qmatrix_update_r1_r2_r4_r5_c4();
        (true, 1, true, 2, true, 4, true, 5, false, 0, 5): qmatrix_update_r1_r2_r4_r5_c5();
        (true, 1, true, 2, true, 4, true, 5, false, 0, 6): qmatrix_update_r1_r2_r4_r5_c6();
        (true, 1, true, 2, true, 4, true, 5, false, 0, 7): qmatrix_update_r1_r2_r4_r5_c7();
        (true, 1, true, 2, true, 4, true, 5, false, 0, 8): qmatrix_update_r1_r2_r4_r5_c8();
        (true, 1, true, 2, true, 5, false, 0, false, 0, 1): qmatrix_update_r1_r2_r5_c1();
        (true, 1, true, 2, true, 5, false, 0, false, 0, 2): qmatrix_update_r1_r2_r5_c2();
        (true, 1, true, 2, true, 5, false, 0, false, 0, 3): qmatrix_update_r1_r2_r5_c3();
        (true, 1, true, 2, true, 5, false, 0, false, 0, 4): qmatrix_update_r1_r2_r5_c4();
        (true, 1, true, 2, true, 5, false, 0, false, 0, 5): qmatrix_update_r1_r2_r5_c5();
        (true, 1, true, 2, true, 5, false, 0, false, 0, 6): qmatrix_update_r1_r2_r5_c6();
        (true, 1, true, 2, true, 5, false, 0, false, 0, 7): qmatrix_update_r1_r2_r5_c7();
        (true, 1, true, 2, true, 5, false, 0, false, 0, 8): qmatrix_update_r1_r2_r5_c8();
        (true, 1, true, 3, false, 0, false, 0, false, 0, 1): qmatrix_update_r1_r3_c1();
        (true, 1, true, 3, false, 0, false, 0, false, 0, 2): qmatrix_update_r1_r3_c2();
        (true, 1, true, 3, false, 0, false, 0, false, 0, 3): qmatrix_update_r1_r3_c3();
        (true, 1, true, 3, false, 0, false, 0, false, 0, 4): qmatrix_update_r1_r3_c4();
        (true, 1, true, 3, false, 0, false, 0, false, 0, 5): qmatrix_update_r1_r3_c5();
        (true, 1, true, 3, false, 0, false, 0, false, 0, 6): qmatrix_update_r1_r3_c6();
        (true, 1, true, 3, false, 0, false, 0, false, 0, 7): qmatrix_update_r1_r3_c7();
        (true, 1, true, 3, false, 0, false, 0, false, 0, 8): qmatrix_update_r1_r3_c8();
        (true, 1, true, 3, true, 4, false, 0, false, 0, 1): qmatrix_update_r1_r3_r4_c1();
        (true, 1, true, 3, true, 4, false, 0, false, 0, 2): qmatrix_update_r1_r3_r4_c2();
        (true, 1, true, 3, true, 4, false, 0, false, 0, 3): qmatrix_update_r1_r3_r4_c3();
        (true, 1, true, 3, true, 4, false, 0, false, 0, 4): qmatrix_update_r1_r3_r4_c4();
        (true, 1, true, 3, true, 4, false, 0, false, 0, 5): qmatrix_update_r1_r3_r4_c5();
        (true, 1, true, 3, true, 4, false, 0, false, 0, 6): qmatrix_update_r1_r3_r4_c6();
        (true, 1, true, 3, true, 4, false, 0, false, 0, 7): qmatrix_update_r1_r3_r4_c7();
        (true, 1, true, 3, true, 4, false, 0, false, 0, 8): qmatrix_update_r1_r3_r4_c8();
        (true, 1, true, 3, true, 4, true, 5, false, 0, 1): qmatrix_update_r1_r3_r4_r5_c1();
        (true, 1, true, 3, true, 4, true, 5, false, 0, 2): qmatrix_update_r1_r3_r4_r5_c2();
        (true, 1, true, 3, true, 4, true, 5, false, 0, 3): qmatrix_update_r1_r3_r4_r5_c3();
        (true, 1, true, 3, true, 4, true, 5, false, 0, 4): qmatrix_update_r1_r3_r4_r5_c4();
        (true, 1, true, 3, true, 4, true, 5, false, 0, 5): qmatrix_update_r1_r3_r4_r5_c5();
        (true, 1, true, 3, true, 4, true, 5, false, 0, 6): qmatrix_update_r1_r3_r4_r5_c6();
        (true, 1, true, 3, true, 4, true, 5, false, 0, 7): qmatrix_update_r1_r3_r4_r5_c7();
        (true, 1, true, 3, true, 4, true, 5, false, 0, 8): qmatrix_update_r1_r3_r4_r5_c8();
        (true, 1, true, 3, true, 5, false, 0, false, 0, 1): qmatrix_update_r1_r3_r5_c1();
        (true, 1, true, 3, true, 5, false, 0, false, 0, 2): qmatrix_update_r1_r3_r5_c2();
        (true, 1, true, 3, true, 5, false, 0, false, 0, 3): qmatrix_update_r1_r3_r5_c3();
        (true, 1, true, 3, true, 5, false, 0, false, 0, 4): qmatrix_update_r1_r3_r5_c4();
        (true, 1, true, 3, true, 5, false, 0, false, 0, 5): qmatrix_update_r1_r3_r5_c5();
        (true, 1, true, 3, true, 5, false, 0, false, 0, 6): qmatrix_update_r1_r3_r5_c6();
        (true, 1, true, 3, true, 5, false, 0, false, 0, 7): qmatrix_update_r1_r3_r5_c7();
        (true, 1, true, 3, true, 5, false, 0, false, 0, 8): qmatrix_update_r1_r3_r5_c8();
        (true, 1, true, 4, false, 0, false, 0, false, 0, 1): qmatrix_update_r1_r4_c1();
        (true, 1, true, 4, false, 0, false, 0, false, 0, 2): qmatrix_update_r1_r4_c2();
        (true, 1, true, 4, false, 0, false, 0, false, 0, 3): qmatrix_update_r1_r4_c3();
        (true, 1, true, 4, false, 0, false, 0, false, 0, 4): qmatrix_update_r1_r4_c4();
        (true, 1, true, 4, false, 0, false, 0, false, 0, 5): qmatrix_update_r1_r4_c5();
        (true, 1, true, 4, false, 0, false, 0, false, 0, 6): qmatrix_update_r1_r4_c6();
        (true, 1, true, 4, false, 0, false, 0, false, 0, 7): qmatrix_update_r1_r4_c7();
        (true, 1, true, 4, false, 0, false, 0, false, 0, 8): qmatrix_update_r1_r4_c8();
        (true, 1, true, 4, true, 5, false, 0, false, 0, 1): qmatrix_update_r1_r4_r5_c1();
        (true, 1, true, 4, true, 5, false, 0, false, 0, 2): qmatrix_update_r1_r4_r5_c2();
        (true, 1, true, 4, true, 5, false, 0, false, 0, 3): qmatrix_update_r1_r4_r5_c3();
        (true, 1, true, 4, true, 5, false, 0, false, 0, 4): qmatrix_update_r1_r4_r5_c4();
        (true, 1, true, 4, true, 5, false, 0, false, 0, 5): qmatrix_update_r1_r4_r5_c5();
        (true, 1, true, 4, true, 5, false, 0, false, 0, 6): qmatrix_update_r1_r4_r5_c6();
        (true, 1, true, 4, true, 5, false, 0, false, 0, 7): qmatrix_update_r1_r4_r5_c7();
        (true, 1, true, 4, true, 5, false, 0, false, 0, 8): qmatrix_update_r1_r4_r5_c8();
        (true, 1, true, 5, false, 0, false, 0, false, 0, 1): qmatrix_update_r1_r5_c1();
        (true, 1, true, 5, false, 0, false, 0, false, 0, 2): qmatrix_update_r1_r5_c2();
        (true, 1, true, 5, false, 0, false, 0, false, 0, 3): qmatrix_update_r1_r5_c3();
        (true, 1, true, 5, false, 0, false, 0, false, 0, 4): qmatrix_update_r1_r5_c4();
        (true, 1, true, 5, false, 0, false, 0, false, 0, 5): qmatrix_update_r1_r5_c5();
        (true, 1, true, 5, false, 0, false, 0, false, 0, 6): qmatrix_update_r1_r5_c6();
        (true, 1, true, 5, false, 0, false, 0, false, 0, 7): qmatrix_update_r1_r5_c7();
        (true, 1, true, 5, false, 0, false, 0, false, 0, 8): qmatrix_update_r1_r5_c8();
        (true, 2, false, 0, false, 0, false, 0, false, 0, 1): qmatrix_update_r2_c1();
        (true, 2, false, 0, false, 0, false, 0, false, 0, 2): qmatrix_update_r2_c2();
        (true, 2, false, 0, false, 0, false, 0, false, 0, 3): qmatrix_update_r2_c3();
        (true, 2, false, 0, false, 0, false, 0, false, 0, 4): qmatrix_update_r2_c4();
        (true, 2, false, 0, false, 0, false, 0, false, 0, 5): qmatrix_update_r2_c5();
        (true, 2, false, 0, false, 0, false, 0, false, 0, 6): qmatrix_update_r2_c6();
        (true, 2, false, 0, false, 0, false, 0, false, 0, 7): qmatrix_update_r2_c7();
        (true, 2, false, 0, false, 0, false, 0, false, 0, 8): qmatrix_update_r2_c8();
        (true, 2, true, 3, false, 0, false, 0, false, 0, 1): qmatrix_update_r2_r3_c1();
        (true, 2, true, 3, false, 0, false, 0, false, 0, 2): qmatrix_update_r2_r3_c2();
        (true, 2, true, 3, false, 0, false, 0, false, 0, 3): qmatrix_update_r2_r3_c3();
        (true, 2, true, 3, false, 0, false, 0, false, 0, 4): qmatrix_update_r2_r3_c4();
        (true, 2, true, 3, false, 0, false, 0, false, 0, 5): qmatrix_update_r2_r3_c5();
        (true, 2, true, 3, false, 0, false, 0, false, 0, 6): qmatrix_update_r2_r3_c6();
        (true, 2, true, 3, false, 0, false, 0, false, 0, 7): qmatrix_update_r2_r3_c7();
        (true, 2, true, 3, false, 0, false, 0, false, 0, 8): qmatrix_update_r2_r3_c8();
        (true, 2, true, 3, true, 4, false, 0, false, 0, 1): qmatrix_update_r2_r3_r4_c1();
        (true, 2, true, 3, true, 4, false, 0, false, 0, 2): qmatrix_update_r2_r3_r4_c2();
        (true, 2, true, 3, true, 4, false, 0, false, 0, 3): qmatrix_update_r2_r3_r4_c3();
        (true, 2, true, 3, true, 4, false, 0, false, 0, 4): qmatrix_update_r2_r3_r4_c4();
        (true, 2, true, 3, true, 4, false, 0, false, 0, 5): qmatrix_update_r2_r3_r4_c5();
        (true, 2, true, 3, true, 4, false, 0, false, 0, 6): qmatrix_update_r2_r3_r4_c6();
        (true, 2, true, 3, true, 4, false, 0, false, 0, 7): qmatrix_update_r2_r3_r4_c7();
        (true, 2, true, 3, true, 4, false, 0, false, 0, 8): qmatrix_update_r2_r3_r4_c8();
        (true, 2, true, 3, true, 4, true, 5, false, 0, 1): qmatrix_update_r2_r3_r4_r5_c1();
        (true, 2, true, 3, true, 4, true, 5, false, 0, 2): qmatrix_update_r2_r3_r4_r5_c2();
        (true, 2, true, 3, true, 4, true, 5, false, 0, 3): qmatrix_update_r2_r3_r4_r5_c3();
        (true, 2, true, 3, true, 4, true, 5, false, 0, 4): qmatrix_update_r2_r3_r4_r5_c4();
        (true, 2, true, 3, true, 4, true, 5, false, 0, 5): qmatrix_update_r2_r3_r4_r5_c5();
        (true, 2, true, 3, true, 4, true, 5, false, 0, 6): qmatrix_update_r2_r3_r4_r5_c6();
        (true, 2, true, 3, true, 4, true, 5, false, 0, 7): qmatrix_update_r2_r3_r4_r5_c7();
        (true, 2, true, 3, true, 4, true, 5, false, 0, 8): qmatrix_update_r2_r3_r4_r5_c8();
        (true, 2, true, 3, true, 5, false, 0, false, 0, 1): qmatrix_update_r2_r3_r5_c1();
        (true, 2, true, 3, true, 5, false, 0, false, 0, 2): qmatrix_update_r2_r3_r5_c2();
        (true, 2, true, 3, true, 5, false, 0, false, 0, 3): qmatrix_update_r2_r3_r5_c3();
        (true, 2, true, 3, true, 5, false, 0, false, 0, 4): qmatrix_update_r2_r3_r5_c4();
        (true, 2, true, 3, true, 5, false, 0, false, 0, 5): qmatrix_update_r2_r3_r5_c5();
        (true, 2, true, 3, true, 5, false, 0, false, 0, 6): qmatrix_update_r2_r3_r5_c6();
        (true, 2, true, 3, true, 5, false, 0, false, 0, 7): qmatrix_update_r2_r3_r5_c7();
        (true, 2, true, 3, true, 5, false, 0, false, 0, 8): qmatrix_update_r2_r3_r5_c8();
        (true, 2, true, 4, false, 0, false, 0, false, 0, 1): qmatrix_update_r2_r4_c1();
        (true, 2, true, 4, false, 0, false, 0, false, 0, 2): qmatrix_update_r2_r4_c2();
        (true, 2, true, 4, false, 0, false, 0, false, 0, 3): qmatrix_update_r2_r4_c3();
        (true, 2, true, 4, false, 0, false, 0, false, 0, 4): qmatrix_update_r2_r4_c4();
        (true, 2, true, 4, false, 0, false, 0, false, 0, 5): qmatrix_update_r2_r4_c5();
        (true, 2, true, 4, false, 0, false, 0, false, 0, 6): qmatrix_update_r2_r4_c6();
        (true, 2, true, 4, false, 0, false, 0, false, 0, 7): qmatrix_update_r2_r4_c7();
        (true, 2, true, 4, false, 0, false, 0, false, 0, 8): qmatrix_update_r2_r4_c8();
        (true, 2, true, 4, true, 5, false, 0, false, 0, 1): qmatrix_update_r2_r4_r5_c1();
        (true, 2, true, 4, true, 5, false, 0, false, 0, 2): qmatrix_update_r2_r4_r5_c2();
        (true, 2, true, 4, true, 5, false, 0, false, 0, 3): qmatrix_update_r2_r4_r5_c3();
        (true, 2, true, 4, true, 5, false, 0, false, 0, 4): qmatrix_update_r2_r4_r5_c4();
        (true, 2, true, 4, true, 5, false, 0, false, 0, 5): qmatrix_update_r2_r4_r5_c5();
        (true, 2, true, 4, true, 5, false, 0, false, 0, 6): qmatrix_update_r2_r4_r5_c6();
        (true, 2, true, 4, true, 5, false, 0, false, 0, 7): qmatrix_update_r2_r4_r5_c7();
        (true, 2, true, 4, true, 5, false, 0, false, 0, 8): qmatrix_update_r2_r4_r5_c8();
        (true, 2, true, 5, false, 0, false, 0, false, 0, 1): qmatrix_update_r2_r5_c1();
        (true, 2, true, 5, false, 0, false, 0, false, 0, 2): qmatrix_update_r2_r5_c2();
        (true, 2, true, 5, false, 0, false, 0, false, 0, 3): qmatrix_update_r2_r5_c3();
        (true, 2, true, 5, false, 0, false, 0, false, 0, 4): qmatrix_update_r2_r5_c4();
        (true, 2, true, 5, false, 0, false, 0, false, 0, 5): qmatrix_update_r2_r5_c5();
        (true, 2, true, 5, false, 0, false, 0, false, 0, 6): qmatrix_update_r2_r5_c6();
        (true, 2, true, 5, false, 0, false, 0, false, 0, 7): qmatrix_update_r2_r5_c7();
        (true, 2, true, 5, false, 0, false, 0, false, 0, 8): qmatrix_update_r2_r5_c8();
        (true, 3, false, 0, false, 0, false, 0, false, 0, 1): qmatrix_update_r3_c1();
        (true, 3, false, 0, false, 0, false, 0, false, 0, 2): qmatrix_update_r3_c2();
        (true, 3, false, 0, false, 0, false, 0, false, 0, 3): qmatrix_update_r3_c3();
        (true, 3, false, 0, false, 0, false, 0, false, 0, 4): qmatrix_update_r3_c4();
        (true, 3, false, 0, false, 0, false, 0, false, 0, 5): qmatrix_update_r3_c5();
        (true, 3, false, 0, false, 0, false, 0, false, 0, 6): qmatrix_update_r3_c6();
        (true, 3, false, 0, false, 0, false, 0, false, 0, 7): qmatrix_update_r3_c7();
        (true, 3, false, 0, false, 0, false, 0, false, 0, 8): qmatrix_update_r3_c8();
        (true, 3, true, 4, false, 0, false, 0, false, 0, 1): qmatrix_update_r3_r4_c1();
        (true, 3, true, 4, false, 0, false, 0, false, 0, 2): qmatrix_update_r3_r4_c2();
        (true, 3, true, 4, false, 0, false, 0, false, 0, 3): qmatrix_update_r3_r4_c3();
        (true, 3, true, 4, false, 0, false, 0, false, 0, 4): qmatrix_update_r3_r4_c4();
        (true, 3, true, 4, false, 0, false, 0, false, 0, 5): qmatrix_update_r3_r4_c5();
        (true, 3, true, 4, false, 0, false, 0, false, 0, 6): qmatrix_update_r3_r4_c6();
        (true, 3, true, 4, false, 0, false, 0, false, 0, 7): qmatrix_update_r3_r4_c7();
        (true, 3, true, 4, false, 0, false, 0, false, 0, 8): qmatrix_update_r3_r4_c8();
        (true, 3, true, 4, true, 5, false, 0, false, 0, 1): qmatrix_update_r3_r4_r5_c1();
        (true, 3, true, 4, true, 5, false, 0, false, 0, 2): qmatrix_update_r3_r4_r5_c2();
        (true, 3, true, 4, true, 5, false, 0, false, 0, 3): qmatrix_update_r3_r4_r5_c3();
        (true, 3, true, 4, true, 5, false, 0, false, 0, 4): qmatrix_update_r3_r4_r5_c4();
        (true, 3, true, 4, true, 5, false, 0, false, 0, 5): qmatrix_update_r3_r4_r5_c5();
        (true, 3, true, 4, true, 5, false, 0, false, 0, 6): qmatrix_update_r3_r4_r5_c6();
        (true, 3, true, 4, true, 5, false, 0, false, 0, 7): qmatrix_update_r3_r4_r5_c7();
        (true, 3, true, 4, true, 5, false, 0, false, 0, 8): qmatrix_update_r3_r4_r5_c8();
        (true, 3, true, 5, false, 0, false, 0, false, 0, 1): qmatrix_update_r3_r5_c1();
        (true, 3, true, 5, false, 0, false, 0, false, 0, 2): qmatrix_update_r3_r5_c2();
        (true, 3, true, 5, false, 0, false, 0, false, 0, 3): qmatrix_update_r3_r5_c3();
        (true, 3, true, 5, false, 0, false, 0, false, 0, 4): qmatrix_update_r3_r5_c4();
        (true, 3, true, 5, false, 0, false, 0, false, 0, 5): qmatrix_update_r3_r5_c5();
        (true, 3, true, 5, false, 0, false, 0, false, 0, 6): qmatrix_update_r3_r5_c6();
        (true, 3, true, 5, false, 0, false, 0, false, 0, 7): qmatrix_update_r3_r5_c7();
        (true, 3, true, 5, false, 0, false, 0, false, 0, 8): qmatrix_update_r3_r5_c8();
        (true, 4, false, 0, false, 0, false, 0, false, 0, 1): qmatrix_update_r4_c1();
        (true, 4, false, 0, false, 0, false, 0, false, 0, 2): qmatrix_update_r4_c2();
        (true, 4, false, 0, false, 0, false, 0, false, 0, 3): qmatrix_update_r4_c3();
        (true, 4, false, 0, false, 0, false, 0, false, 0, 4): qmatrix_update_r4_c4();
        (true, 4, false, 0, false, 0, false, 0, false, 0, 5): qmatrix_update_r4_c5();
        (true, 4, false, 0, false, 0, false, 0, false, 0, 6): qmatrix_update_r4_c6();
        (true, 4, false, 0, false, 0, false, 0, false, 0, 7): qmatrix_update_r4_c7();
        (true, 4, false, 0, false, 0, false, 0, false, 0, 8): qmatrix_update_r4_c8();
        (true, 4, true, 5, false, 0, false, 0, false, 0, 1): qmatrix_update_r4_r5_c1();
        (true, 4, true, 5, false, 0, false, 0, false, 0, 2): qmatrix_update_r4_r5_c2();
        (true, 4, true, 5, false, 0, false, 0, false, 0, 3): qmatrix_update_r4_r5_c3();
        (true, 4, true, 5, false, 0, false, 0, false, 0, 4): qmatrix_update_r4_r5_c4();
        (true, 4, true, 5, false, 0, false, 0, false, 0, 5): qmatrix_update_r4_r5_c5();
        (true, 4, true, 5, false, 0, false, 0, false, 0, 6): qmatrix_update_r4_r5_c6();
        (true, 4, true, 5, false, 0, false, 0, false, 0, 7): qmatrix_update_r4_r5_c7();
        (true, 4, true, 5, false, 0, false, 0, false, 0, 8): qmatrix_update_r4_r5_c8();
        (true, 5, false, 0, false, 0, false, 0, false, 0, 1): qmatrix_update_r5_c1();
        (true, 5, false, 0, false, 0, false, 0, false, 0, 2): qmatrix_update_r5_c2();
        (true, 5, false, 0, false, 0, false, 0, false, 0, 3): qmatrix_update_r5_c3();
        (true, 5, false, 0, false, 0, false, 0, false, 0, 4): qmatrix_update_r5_c4();
        (true, 5, false, 0, false, 0, false, 0, false, 0, 5): qmatrix_update_r5_c5();
        (true, 5, false, 0, false, 0, false, 0, false, 0, 6): qmatrix_update_r5_c6();
        (true, 5, false, 0, false, 0, false, 0, false, 0, 7): qmatrix_update_r5_c7();
        (true, 5, false, 0, false, 0, false, 0, false, 0, 8): qmatrix_update_r5_c8();
    }
}

#endif