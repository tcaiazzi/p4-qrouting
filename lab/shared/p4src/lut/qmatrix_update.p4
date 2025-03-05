#ifndef __QMATRIX_UPDATE__
#define __QMATRIX_UPDATE__

action qmatrix_update_1() {
    row1.read(row1_value, 0);
    log_msg("updating row1_value - before: {}", {row1_value[7:0]});
    row1_value[7:0] = row1_value[7:0] + (ig_qdepth + hdr.qlr_updates[0].value - row1_value[7:0]);
    log_msg("updating row1_value - after: {}", {row1_value[7:0]});
    row1.write(0, row1_value);
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_1_2() {
    row1.read(row1_value, 0);
    log_msg("updating row1_value - before: {}", {row1_value[7:0]});
    row1_value[7:0] = row1_value[7:0] + (ig_qdepth + hdr.qlr_updates[0].value - row1_value[7:0]);
    log_msg("updating row1_value - after: {}", {row1_value[7:0]});
    row1.write(0, row1_value);
    row2.read(row2_value, 0);
    log_msg("updating row2_value - before: {}", {row2_value[15:8]});
    row2_value[15:8] = row2_value[15:8] + (ig_qdepth + hdr.qlr_updates[1].value - row2_value[15:8]);
    log_msg("updating row2_value - after: {}", {row2_value[15:8]});
    row2.write(0, row2_value);
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_1_2_3() {
    row1.read(row1_value, 0);
    log_msg("updating row1_value - before: {}", {row1_value[7:0]});
    row1_value[7:0] = row1_value[7:0] + (ig_qdepth + hdr.qlr_updates[0].value - row1_value[7:0]);
    log_msg("updating row1_value - after: {}", {row1_value[7:0]});
    row1.write(0, row1_value);
    row2.read(row2_value, 0);
    log_msg("updating row2_value - before: {}", {row2_value[15:8]});
    row2_value[15:8] = row2_value[15:8] + (ig_qdepth + hdr.qlr_updates[1].value - row2_value[15:8]);
    log_msg("updating row2_value - after: {}", {row2_value[15:8]});
    row2.write(0, row2_value);
    row3.read(row3_value, 0);
    log_msg("updating row3_value - before: {}", {row3_value[23:16]});
    row3_value[23:16] = row3_value[23:16] + (ig_qdepth + hdr.qlr_updates[2].value - row3_value[23:16]);
    log_msg("updating row3_value - after: {}", {row3_value[23:16]});
    row3.write(0, row3_value);
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_1_2_3_4() {
    row1.read(row1_value, 0);
    log_msg("updating row1_value - before: {}", {row1_value[7:0]});
    row1_value[7:0] = row1_value[7:0] + (ig_qdepth + hdr.qlr_updates[0].value - row1_value[7:0]);
    log_msg("updating row1_value - after: {}", {row1_value[7:0]});
    row1.write(0, row1_value);
    row2.read(row2_value, 0);
    log_msg("updating row2_value - before: {}", {row2_value[15:8]});
    row2_value[15:8] = row2_value[15:8] + (ig_qdepth + hdr.qlr_updates[1].value - row2_value[15:8]);
    log_msg("updating row2_value - after: {}", {row2_value[15:8]});
    row2.write(0, row2_value);
    row3.read(row3_value, 0);
    log_msg("updating row3_value - before: {}", {row3_value[23:16]});
    row3_value[23:16] = row3_value[23:16] + (ig_qdepth + hdr.qlr_updates[2].value - row3_value[23:16]);
    log_msg("updating row3_value - after: {}", {row3_value[23:16]});
    row3.write(0, row3_value);
    row4.read(row4_value, 0);
    log_msg("updating row4_value - before: {}", {row4_value[31:24]});
    row4_value[31:24] = row4_value[31:24] + (ig_qdepth + hdr.qlr_updates[3].value - row4_value[31:24]);
    log_msg("updating row4_value - after: {}", {row4_value[31:24]});
    row4.write(0, row4_value);
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_1_2_3_4_5() {
    row1.read(row1_value, 0);
    log_msg("updating row1_value - before: {}", {row1_value[7:0]});
    row1_value[7:0] = row1_value[7:0] + (ig_qdepth + hdr.qlr_updates[0].value - row1_value[7:0]);
    log_msg("updating row1_value - after: {}", {row1_value[7:0]});
    row1.write(0, row1_value);
    row2.read(row2_value, 0);
    log_msg("updating row2_value - before: {}", {row2_value[15:8]});
    row2_value[15:8] = row2_value[15:8] + (ig_qdepth + hdr.qlr_updates[1].value - row2_value[15:8]);
    log_msg("updating row2_value - after: {}", {row2_value[15:8]});
    row2.write(0, row2_value);
    row3.read(row3_value, 0);
    log_msg("updating row3_value - before: {}", {row3_value[23:16]});
    row3_value[23:16] = row3_value[23:16] + (ig_qdepth + hdr.qlr_updates[2].value - row3_value[23:16]);
    log_msg("updating row3_value - after: {}", {row3_value[23:16]});
    row3.write(0, row3_value);
    row4.read(row4_value, 0);
    log_msg("updating row4_value - before: {}", {row4_value[31:24]});
    row4_value[31:24] = row4_value[31:24] + (ig_qdepth + hdr.qlr_updates[3].value - row4_value[31:24]);
    log_msg("updating row4_value - after: {}", {row4_value[31:24]});
    row4.write(0, row4_value);
    row5.read(row5_value, 0);
    log_msg("updating row5_value - before: {}", {row5_value[39:32]});
    row5_value[39:32] = row5_value[39:32] + (ig_qdepth + hdr.qlr_updates[4].value - row5_value[39:32]);
    log_msg("updating row5_value - after: {}", {row5_value[39:32]});
    row5.write(0, row5_value);
}

action qmatrix_update_1_2_3_5() {
    row1.read(row1_value, 0);
    log_msg("updating row1_value - before: {}", {row1_value[7:0]});
    row1_value[7:0] = row1_value[7:0] + (ig_qdepth + hdr.qlr_updates[0].value - row1_value[7:0]);
    log_msg("updating row1_value - after: {}", {row1_value[7:0]});
    row1.write(0, row1_value);
    row2.read(row2_value, 0);
    log_msg("updating row2_value - before: {}", {row2_value[15:8]});
    row2_value[15:8] = row2_value[15:8] + (ig_qdepth + hdr.qlr_updates[1].value - row2_value[15:8]);
    log_msg("updating row2_value - after: {}", {row2_value[15:8]});
    row2.write(0, row2_value);
    row3.read(row3_value, 0);
    log_msg("updating row3_value - before: {}", {row3_value[23:16]});
    row3_value[23:16] = row3_value[23:16] + (ig_qdepth + hdr.qlr_updates[2].value - row3_value[23:16]);
    log_msg("updating row3_value - after: {}", {row3_value[23:16]});
    row3.write(0, row3_value);
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    row5.read(row5_value, 0);
    log_msg("updating row5_value - before: {}", {row5_value[39:32]});
    row5_value[39:32] = row5_value[39:32] + (ig_qdepth + hdr.qlr_updates[3].value - row5_value[39:32]);
    log_msg("updating row5_value - after: {}", {row5_value[39:32]});
    row5.write(0, row5_value);
}

action qmatrix_update_1_2_4() {
    row1.read(row1_value, 0);
    log_msg("updating row1_value - before: {}", {row1_value[7:0]});
    row1_value[7:0] = row1_value[7:0] + (ig_qdepth + hdr.qlr_updates[0].value - row1_value[7:0]);
    log_msg("updating row1_value - after: {}", {row1_value[7:0]});
    row1.write(0, row1_value);
    row2.read(row2_value, 0);
    log_msg("updating row2_value - before: {}", {row2_value[15:8]});
    row2_value[15:8] = row2_value[15:8] + (ig_qdepth + hdr.qlr_updates[1].value - row2_value[15:8]);
    log_msg("updating row2_value - after: {}", {row2_value[15:8]});
    row2.write(0, row2_value);
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    row4.read(row4_value, 0);
    log_msg("updating row4_value - before: {}", {row4_value[31:24]});
    row4_value[31:24] = row4_value[31:24] + (ig_qdepth + hdr.qlr_updates[2].value - row4_value[31:24]);
    log_msg("updating row4_value - after: {}", {row4_value[31:24]});
    row4.write(0, row4_value);
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_1_2_4_5() {
    row1.read(row1_value, 0);
    log_msg("updating row1_value - before: {}", {row1_value[7:0]});
    row1_value[7:0] = row1_value[7:0] + (ig_qdepth + hdr.qlr_updates[0].value - row1_value[7:0]);
    log_msg("updating row1_value - after: {}", {row1_value[7:0]});
    row1.write(0, row1_value);
    row2.read(row2_value, 0);
    log_msg("updating row2_value - before: {}", {row2_value[15:8]});
    row2_value[15:8] = row2_value[15:8] + (ig_qdepth + hdr.qlr_updates[1].value - row2_value[15:8]);
    log_msg("updating row2_value - after: {}", {row2_value[15:8]});
    row2.write(0, row2_value);
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    row4.read(row4_value, 0);
    log_msg("updating row4_value - before: {}", {row4_value[31:24]});
    row4_value[31:24] = row4_value[31:24] + (ig_qdepth + hdr.qlr_updates[2].value - row4_value[31:24]);
    log_msg("updating row4_value - after: {}", {row4_value[31:24]});
    row4.write(0, row4_value);
    row5.read(row5_value, 0);
    log_msg("updating row5_value - before: {}", {row5_value[39:32]});
    row5_value[39:32] = row5_value[39:32] + (ig_qdepth + hdr.qlr_updates[3].value - row5_value[39:32]);
    log_msg("updating row5_value - after: {}", {row5_value[39:32]});
    row5.write(0, row5_value);
}

action qmatrix_update_1_2_5() {
    row1.read(row1_value, 0);
    log_msg("updating row1_value - before: {}", {row1_value[7:0]});
    row1_value[7:0] = row1_value[7:0] + (ig_qdepth + hdr.qlr_updates[0].value - row1_value[7:0]);
    log_msg("updating row1_value - after: {}", {row1_value[7:0]});
    row1.write(0, row1_value);
    row2.read(row2_value, 0);
    log_msg("updating row2_value - before: {}", {row2_value[15:8]});
    row2_value[15:8] = row2_value[15:8] + (ig_qdepth + hdr.qlr_updates[1].value - row2_value[15:8]);
    log_msg("updating row2_value - after: {}", {row2_value[15:8]});
    row2.write(0, row2_value);
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    row5.read(row5_value, 0);
    log_msg("updating row5_value - before: {}", {row5_value[39:32]});
    row5_value[39:32] = row5_value[39:32] + (ig_qdepth + hdr.qlr_updates[2].value - row5_value[39:32]);
    log_msg("updating row5_value - after: {}", {row5_value[39:32]});
    row5.write(0, row5_value);
}

action qmatrix_update_1_3() {
    row1.read(row1_value, 0);
    log_msg("updating row1_value - before: {}", {row1_value[7:0]});
    row1_value[7:0] = row1_value[7:0] + (ig_qdepth + hdr.qlr_updates[0].value - row1_value[7:0]);
    log_msg("updating row1_value - after: {}", {row1_value[7:0]});
    row1.write(0, row1_value);
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    row3.read(row3_value, 0);
    log_msg("updating row3_value - before: {}", {row3_value[23:16]});
    row3_value[23:16] = row3_value[23:16] + (ig_qdepth + hdr.qlr_updates[1].value - row3_value[23:16]);
    log_msg("updating row3_value - after: {}", {row3_value[23:16]});
    row3.write(0, row3_value);
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_1_3_4() {
    row1.read(row1_value, 0);
    log_msg("updating row1_value - before: {}", {row1_value[7:0]});
    row1_value[7:0] = row1_value[7:0] + (ig_qdepth + hdr.qlr_updates[0].value - row1_value[7:0]);
    log_msg("updating row1_value - after: {}", {row1_value[7:0]});
    row1.write(0, row1_value);
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    row3.read(row3_value, 0);
    log_msg("updating row3_value - before: {}", {row3_value[23:16]});
    row3_value[23:16] = row3_value[23:16] + (ig_qdepth + hdr.qlr_updates[1].value - row3_value[23:16]);
    log_msg("updating row3_value - after: {}", {row3_value[23:16]});
    row3.write(0, row3_value);
    row4.read(row4_value, 0);
    log_msg("updating row4_value - before: {}", {row4_value[31:24]});
    row4_value[31:24] = row4_value[31:24] + (ig_qdepth + hdr.qlr_updates[2].value - row4_value[31:24]);
    log_msg("updating row4_value - after: {}", {row4_value[31:24]});
    row4.write(0, row4_value);
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_1_3_4_5() {
    row1.read(row1_value, 0);
    log_msg("updating row1_value - before: {}", {row1_value[7:0]});
    row1_value[7:0] = row1_value[7:0] + (ig_qdepth + hdr.qlr_updates[0].value - row1_value[7:0]);
    log_msg("updating row1_value - after: {}", {row1_value[7:0]});
    row1.write(0, row1_value);
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    row3.read(row3_value, 0);
    log_msg("updating row3_value - before: {}", {row3_value[23:16]});
    row3_value[23:16] = row3_value[23:16] + (ig_qdepth + hdr.qlr_updates[1].value - row3_value[23:16]);
    log_msg("updating row3_value - after: {}", {row3_value[23:16]});
    row3.write(0, row3_value);
    row4.read(row4_value, 0);
    log_msg("updating row4_value - before: {}", {row4_value[31:24]});
    row4_value[31:24] = row4_value[31:24] + (ig_qdepth + hdr.qlr_updates[2].value - row4_value[31:24]);
    log_msg("updating row4_value - after: {}", {row4_value[31:24]});
    row4.write(0, row4_value);
    row5.read(row5_value, 0);
    log_msg("updating row5_value - before: {}", {row5_value[39:32]});
    row5_value[39:32] = row5_value[39:32] + (ig_qdepth + hdr.qlr_updates[3].value - row5_value[39:32]);
    log_msg("updating row5_value - after: {}", {row5_value[39:32]});
    row5.write(0, row5_value);
}

action qmatrix_update_1_3_5() {
    row1.read(row1_value, 0);
    log_msg("updating row1_value - before: {}", {row1_value[7:0]});
    row1_value[7:0] = row1_value[7:0] + (ig_qdepth + hdr.qlr_updates[0].value - row1_value[7:0]);
    log_msg("updating row1_value - after: {}", {row1_value[7:0]});
    row1.write(0, row1_value);
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    row3.read(row3_value, 0);
    log_msg("updating row3_value - before: {}", {row3_value[23:16]});
    row3_value[23:16] = row3_value[23:16] + (ig_qdepth + hdr.qlr_updates[1].value - row3_value[23:16]);
    log_msg("updating row3_value - after: {}", {row3_value[23:16]});
    row3.write(0, row3_value);
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    row5.read(row5_value, 0);
    log_msg("updating row5_value - before: {}", {row5_value[39:32]});
    row5_value[39:32] = row5_value[39:32] + (ig_qdepth + hdr.qlr_updates[2].value - row5_value[39:32]);
    log_msg("updating row5_value - after: {}", {row5_value[39:32]});
    row5.write(0, row5_value);
}

action qmatrix_update_1_4() {
    row1.read(row1_value, 0);
    log_msg("updating row1_value - before: {}", {row1_value[7:0]});
    row1_value[7:0] = row1_value[7:0] + (ig_qdepth + hdr.qlr_updates[0].value - row1_value[7:0]);
    log_msg("updating row1_value - after: {}", {row1_value[7:0]});
    row1.write(0, row1_value);
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    row4.read(row4_value, 0);
    log_msg("updating row4_value - before: {}", {row4_value[31:24]});
    row4_value[31:24] = row4_value[31:24] + (ig_qdepth + hdr.qlr_updates[1].value - row4_value[31:24]);
    log_msg("updating row4_value - after: {}", {row4_value[31:24]});
    row4.write(0, row4_value);
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_1_4_5() {
    row1.read(row1_value, 0);
    log_msg("updating row1_value - before: {}", {row1_value[7:0]});
    row1_value[7:0] = row1_value[7:0] + (ig_qdepth + hdr.qlr_updates[0].value - row1_value[7:0]);
    log_msg("updating row1_value - after: {}", {row1_value[7:0]});
    row1.write(0, row1_value);
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    row4.read(row4_value, 0);
    log_msg("updating row4_value - before: {}", {row4_value[31:24]});
    row4_value[31:24] = row4_value[31:24] + (ig_qdepth + hdr.qlr_updates[1].value - row4_value[31:24]);
    log_msg("updating row4_value - after: {}", {row4_value[31:24]});
    row4.write(0, row4_value);
    row5.read(row5_value, 0);
    log_msg("updating row5_value - before: {}", {row5_value[39:32]});
    row5_value[39:32] = row5_value[39:32] + (ig_qdepth + hdr.qlr_updates[2].value - row5_value[39:32]);
    log_msg("updating row5_value - after: {}", {row5_value[39:32]});
    row5.write(0, row5_value);
}

action qmatrix_update_1_5() {
    row1.read(row1_value, 0);
    log_msg("updating row1_value - before: {}", {row1_value[7:0]});
    row1_value[7:0] = row1_value[7:0] + (ig_qdepth + hdr.qlr_updates[0].value - row1_value[7:0]);
    log_msg("updating row1_value - after: {}", {row1_value[7:0]});
    row1.write(0, row1_value);
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    row5.read(row5_value, 0);
    log_msg("updating row5_value - before: {}", {row5_value[39:32]});
    row5_value[39:32] = row5_value[39:32] + (ig_qdepth + hdr.qlr_updates[1].value - row5_value[39:32]);
    log_msg("updating row5_value - after: {}", {row5_value[39:32]});
    row5.write(0, row5_value);
}

action qmatrix_update_2() {
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    row2.read(row2_value, 0);
    log_msg("updating row2_value - before: {}", {row2_value[15:8]});
    row2_value[15:8] = row2_value[15:8] + (ig_qdepth + hdr.qlr_updates[0].value - row2_value[15:8]);
    log_msg("updating row2_value - after: {}", {row2_value[15:8]});
    row2.write(0, row2_value);
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_2_3() {
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    row2.read(row2_value, 0);
    log_msg("updating row2_value - before: {}", {row2_value[15:8]});
    row2_value[15:8] = row2_value[15:8] + (ig_qdepth + hdr.qlr_updates[0].value - row2_value[15:8]);
    log_msg("updating row2_value - after: {}", {row2_value[15:8]});
    row2.write(0, row2_value);
    row3.read(row3_value, 0);
    log_msg("updating row3_value - before: {}", {row3_value[23:16]});
    row3_value[23:16] = row3_value[23:16] + (ig_qdepth + hdr.qlr_updates[1].value - row3_value[23:16]);
    log_msg("updating row3_value - after: {}", {row3_value[23:16]});
    row3.write(0, row3_value);
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_2_3_4() {
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    row2.read(row2_value, 0);
    log_msg("updating row2_value - before: {}", {row2_value[15:8]});
    row2_value[15:8] = row2_value[15:8] + (ig_qdepth + hdr.qlr_updates[0].value - row2_value[15:8]);
    log_msg("updating row2_value - after: {}", {row2_value[15:8]});
    row2.write(0, row2_value);
    row3.read(row3_value, 0);
    log_msg("updating row3_value - before: {}", {row3_value[23:16]});
    row3_value[23:16] = row3_value[23:16] + (ig_qdepth + hdr.qlr_updates[1].value - row3_value[23:16]);
    log_msg("updating row3_value - after: {}", {row3_value[23:16]});
    row3.write(0, row3_value);
    row4.read(row4_value, 0);
    log_msg("updating row4_value - before: {}", {row4_value[31:24]});
    row4_value[31:24] = row4_value[31:24] + (ig_qdepth + hdr.qlr_updates[2].value - row4_value[31:24]);
    log_msg("updating row4_value - after: {}", {row4_value[31:24]});
    row4.write(0, row4_value);
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_2_3_4_5() {
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    row2.read(row2_value, 0);
    log_msg("updating row2_value - before: {}", {row2_value[15:8]});
    row2_value[15:8] = row2_value[15:8] + (ig_qdepth + hdr.qlr_updates[0].value - row2_value[15:8]);
    log_msg("updating row2_value - after: {}", {row2_value[15:8]});
    row2.write(0, row2_value);
    row3.read(row3_value, 0);
    log_msg("updating row3_value - before: {}", {row3_value[23:16]});
    row3_value[23:16] = row3_value[23:16] + (ig_qdepth + hdr.qlr_updates[1].value - row3_value[23:16]);
    log_msg("updating row3_value - after: {}", {row3_value[23:16]});
    row3.write(0, row3_value);
    row4.read(row4_value, 0);
    log_msg("updating row4_value - before: {}", {row4_value[31:24]});
    row4_value[31:24] = row4_value[31:24] + (ig_qdepth + hdr.qlr_updates[2].value - row4_value[31:24]);
    log_msg("updating row4_value - after: {}", {row4_value[31:24]});
    row4.write(0, row4_value);
    row5.read(row5_value, 0);
    log_msg("updating row5_value - before: {}", {row5_value[39:32]});
    row5_value[39:32] = row5_value[39:32] + (ig_qdepth + hdr.qlr_updates[3].value - row5_value[39:32]);
    log_msg("updating row5_value - after: {}", {row5_value[39:32]});
    row5.write(0, row5_value);
}

action qmatrix_update_2_3_5() {
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    row2.read(row2_value, 0);
    log_msg("updating row2_value - before: {}", {row2_value[15:8]});
    row2_value[15:8] = row2_value[15:8] + (ig_qdepth + hdr.qlr_updates[0].value - row2_value[15:8]);
    log_msg("updating row2_value - after: {}", {row2_value[15:8]});
    row2.write(0, row2_value);
    row3.read(row3_value, 0);
    log_msg("updating row3_value - before: {}", {row3_value[23:16]});
    row3_value[23:16] = row3_value[23:16] + (ig_qdepth + hdr.qlr_updates[1].value - row3_value[23:16]);
    log_msg("updating row3_value - after: {}", {row3_value[23:16]});
    row3.write(0, row3_value);
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    row5.read(row5_value, 0);
    log_msg("updating row5_value - before: {}", {row5_value[39:32]});
    row5_value[39:32] = row5_value[39:32] + (ig_qdepth + hdr.qlr_updates[2].value - row5_value[39:32]);
    log_msg("updating row5_value - after: {}", {row5_value[39:32]});
    row5.write(0, row5_value);
}

action qmatrix_update_2_4() {
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    row2.read(row2_value, 0);
    log_msg("updating row2_value - before: {}", {row2_value[15:8]});
    row2_value[15:8] = row2_value[15:8] + (ig_qdepth + hdr.qlr_updates[0].value - row2_value[15:8]);
    log_msg("updating row2_value - after: {}", {row2_value[15:8]});
    row2.write(0, row2_value);
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    row4.read(row4_value, 0);
    log_msg("updating row4_value - before: {}", {row4_value[31:24]});
    row4_value[31:24] = row4_value[31:24] + (ig_qdepth + hdr.qlr_updates[1].value - row4_value[31:24]);
    log_msg("updating row4_value - after: {}", {row4_value[31:24]});
    row4.write(0, row4_value);
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_2_4_5() {
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    row2.read(row2_value, 0);
    log_msg("updating row2_value - before: {}", {row2_value[15:8]});
    row2_value[15:8] = row2_value[15:8] + (ig_qdepth + hdr.qlr_updates[0].value - row2_value[15:8]);
    log_msg("updating row2_value - after: {}", {row2_value[15:8]});
    row2.write(0, row2_value);
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    row4.read(row4_value, 0);
    log_msg("updating row4_value - before: {}", {row4_value[31:24]});
    row4_value[31:24] = row4_value[31:24] + (ig_qdepth + hdr.qlr_updates[1].value - row4_value[31:24]);
    log_msg("updating row4_value - after: {}", {row4_value[31:24]});
    row4.write(0, row4_value);
    row5.read(row5_value, 0);
    log_msg("updating row5_value - before: {}", {row5_value[39:32]});
    row5_value[39:32] = row5_value[39:32] + (ig_qdepth + hdr.qlr_updates[2].value - row5_value[39:32]);
    log_msg("updating row5_value - after: {}", {row5_value[39:32]});
    row5.write(0, row5_value);
}

action qmatrix_update_2_5() {
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    row2.read(row2_value, 0);
    log_msg("updating row2_value - before: {}", {row2_value[15:8]});
    row2_value[15:8] = row2_value[15:8] + (ig_qdepth + hdr.qlr_updates[0].value - row2_value[15:8]);
    log_msg("updating row2_value - after: {}", {row2_value[15:8]});
    row2.write(0, row2_value);
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    row5.read(row5_value, 0);
    log_msg("updating row5_value - before: {}", {row5_value[39:32]});
    row5_value[39:32] = row5_value[39:32] + (ig_qdepth + hdr.qlr_updates[1].value - row5_value[39:32]);
    log_msg("updating row5_value - after: {}", {row5_value[39:32]});
    row5.write(0, row5_value);
}

action qmatrix_update_3() {
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    row3.read(row3_value, 0);
    log_msg("updating row3_value - before: {}", {row3_value[23:16]});
    row3_value[23:16] = row3_value[23:16] + (ig_qdepth + hdr.qlr_updates[0].value - row3_value[23:16]);
    log_msg("updating row3_value - after: {}", {row3_value[23:16]});
    row3.write(0, row3_value);
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_3_4() {
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    row3.read(row3_value, 0);
    log_msg("updating row3_value - before: {}", {row3_value[23:16]});
    row3_value[23:16] = row3_value[23:16] + (ig_qdepth + hdr.qlr_updates[0].value - row3_value[23:16]);
    log_msg("updating row3_value - after: {}", {row3_value[23:16]});
    row3.write(0, row3_value);
    row4.read(row4_value, 0);
    log_msg("updating row4_value - before: {}", {row4_value[31:24]});
    row4_value[31:24] = row4_value[31:24] + (ig_qdepth + hdr.qlr_updates[1].value - row4_value[31:24]);
    log_msg("updating row4_value - after: {}", {row4_value[31:24]});
    row4.write(0, row4_value);
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_3_4_5() {
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    row3.read(row3_value, 0);
    log_msg("updating row3_value - before: {}", {row3_value[23:16]});
    row3_value[23:16] = row3_value[23:16] + (ig_qdepth + hdr.qlr_updates[0].value - row3_value[23:16]);
    log_msg("updating row3_value - after: {}", {row3_value[23:16]});
    row3.write(0, row3_value);
    row4.read(row4_value, 0);
    log_msg("updating row4_value - before: {}", {row4_value[31:24]});
    row4_value[31:24] = row4_value[31:24] + (ig_qdepth + hdr.qlr_updates[1].value - row4_value[31:24]);
    log_msg("updating row4_value - after: {}", {row4_value[31:24]});
    row4.write(0, row4_value);
    row5.read(row5_value, 0);
    log_msg("updating row5_value - before: {}", {row5_value[39:32]});
    row5_value[39:32] = row5_value[39:32] + (ig_qdepth + hdr.qlr_updates[2].value - row5_value[39:32]);
    log_msg("updating row5_value - after: {}", {row5_value[39:32]});
    row5.write(0, row5_value);
}

action qmatrix_update_3_5() {
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    row3.read(row3_value, 0);
    log_msg("updating row3_value - before: {}", {row3_value[23:16]});
    row3_value[23:16] = row3_value[23:16] + (ig_qdepth + hdr.qlr_updates[0].value - row3_value[23:16]);
    log_msg("updating row3_value - after: {}", {row3_value[23:16]});
    row3.write(0, row3_value);
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    row5.read(row5_value, 0);
    log_msg("updating row5_value - before: {}", {row5_value[39:32]});
    row5_value[39:32] = row5_value[39:32] + (ig_qdepth + hdr.qlr_updates[1].value - row5_value[39:32]);
    log_msg("updating row5_value - after: {}", {row5_value[39:32]});
    row5.write(0, row5_value);
}

action qmatrix_update_4() {
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    row4.read(row4_value, 0);
    log_msg("updating row4_value - before: {}", {row4_value[31:24]});
    row4_value[31:24] = row4_value[31:24] + (ig_qdepth + hdr.qlr_updates[0].value - row4_value[31:24]);
    log_msg("updating row4_value - after: {}", {row4_value[31:24]});
    row4.write(0, row4_value);
    log_msg("reading row5_value");
    row5.read(row5_value, 0);
}

action qmatrix_update_4_5() {
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    row4.read(row4_value, 0);
    log_msg("updating row4_value - before: {}", {row4_value[31:24]});
    row4_value[31:24] = row4_value[31:24] + (ig_qdepth + hdr.qlr_updates[0].value - row4_value[31:24]);
    log_msg("updating row4_value - after: {}", {row4_value[31:24]});
    row4.write(0, row4_value);
    row5.read(row5_value, 0);
    log_msg("updating row5_value - before: {}", {row5_value[39:32]});
    row5_value[39:32] = row5_value[39:32] + (ig_qdepth + hdr.qlr_updates[1].value - row5_value[39:32]);
    log_msg("updating row5_value - after: {}", {row5_value[39:32]});
    row5.write(0, row5_value);
}

action qmatrix_update_5() {
    log_msg("reading row1_value");
    row1.read(row1_value, 0);
    log_msg("reading row2_value");
    row2.read(row2_value, 0);
    log_msg("reading row3_value");
    row3.read(row3_value, 0);
    log_msg("reading row4_value");
    row4.read(row4_value, 0);
    row5.read(row5_value, 0);
    log_msg("updating row5_value - before: {}", {row5_value[39:32]});
    row5_value[39:32] = row5_value[39:32] + (ig_qdepth + hdr.qlr_updates[0].value - row5_value[39:32]);
    log_msg("updating row5_value - after: {}", {row5_value[39:32]});
    row5.write(0, row5_value);
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
    }
    actions = {
        qmatrix_update_1;
        qmatrix_update_1_2;
        qmatrix_update_1_2_3;
        qmatrix_update_1_2_3_4;
        qmatrix_update_1_2_3_4_5;
        qmatrix_update_1_2_3_5;
        qmatrix_update_1_2_4;
        qmatrix_update_1_2_4_5;
        qmatrix_update_1_2_5;
        qmatrix_update_1_3;
        qmatrix_update_1_3_4;
        qmatrix_update_1_3_4_5;
        qmatrix_update_1_3_5;
        qmatrix_update_1_4;
        qmatrix_update_1_4_5;
        qmatrix_update_1_5;
        qmatrix_update_2;
        qmatrix_update_2_3;
        qmatrix_update_2_3_4;
        qmatrix_update_2_3_4_5;
        qmatrix_update_2_3_5;
        qmatrix_update_2_4;
        qmatrix_update_2_4_5;
        qmatrix_update_2_5;
        qmatrix_update_3;
        qmatrix_update_3_4;
        qmatrix_update_3_4_5;
        qmatrix_update_3_5;
        qmatrix_update_4;
        qmatrix_update_4_5;
        qmatrix_update_5;
        read_all;
    }
    size = 32;
    default_action = read_all;
}

#endif