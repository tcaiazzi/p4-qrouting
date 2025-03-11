#ifndef __QLR_PKT_UPDATES__
#define __QLR_PKT_UPDATES__

action qlr_pkt_set_1() {
    hdr.ethernet.dst_addr[47:40] = 0x1;
    hdr.qlr_updates[0].has_next = 0;
    log_msg("set valid: hdr.qlr_updates[0]");
    hdr.qlr_updates[1].setInvalid();
    hdr.qlr_updates[1].dst_id = 0;
    log_msg("set invalid: hdr.qlr_updates[1]");
    hdr.qlr_updates[2].setInvalid();
    hdr.qlr_updates[2].dst_id = 0;
    log_msg("set invalid: hdr.qlr_updates[2]");
    hdr.qlr_updates[3].setInvalid();
    hdr.qlr_updates[3].dst_id = 0;
    log_msg("set invalid: hdr.qlr_updates[3]");
    hdr.qlr_updates[4].setInvalid();
    hdr.qlr_updates[4].dst_id = 0;
    log_msg("set invalid: hdr.qlr_updates[4]");
}

action qlr_pkt_set_1_2() {
    hdr.ethernet.dst_addr[47:40] = 0x1;
    hdr.qlr_updates[0].has_next = 1;
    log_msg("set valid: hdr.qlr_updates[0]");
    hdr.qlr_updates[1].has_next = 0;
    log_msg("set valid: hdr.qlr_updates[1]");
    hdr.qlr_updates[2].setInvalid();
    hdr.qlr_updates[2].dst_id = 0;
    log_msg("set invalid: hdr.qlr_updates[2]");
    hdr.qlr_updates[3].setInvalid();
    hdr.qlr_updates[3].dst_id = 0;
    log_msg("set invalid: hdr.qlr_updates[3]");
    hdr.qlr_updates[4].setInvalid();
    hdr.qlr_updates[4].dst_id = 0;
    log_msg("set invalid: hdr.qlr_updates[4]");
}

action qlr_pkt_set_1_2_3() {
    hdr.ethernet.dst_addr[47:40] = 0x1;
    hdr.qlr_updates[0].has_next = 1;
    log_msg("set valid: hdr.qlr_updates[0]");
    hdr.qlr_updates[1].has_next = 1;
    log_msg("set valid: hdr.qlr_updates[1]");
    hdr.qlr_updates[2].has_next = 0;
    log_msg("set valid: hdr.qlr_updates[2]");
    hdr.qlr_updates[3].setInvalid();
    hdr.qlr_updates[3].dst_id = 0;
    log_msg("set invalid: hdr.qlr_updates[3]");
    hdr.qlr_updates[4].setInvalid();
    hdr.qlr_updates[4].dst_id = 0;
    log_msg("set invalid: hdr.qlr_updates[4]");
}

action qlr_pkt_set_1_2_3_4() {
    hdr.ethernet.dst_addr[47:40] = 0x1;
    hdr.qlr_updates[0].has_next = 1;
    log_msg("set valid: hdr.qlr_updates[0]");
    hdr.qlr_updates[1].has_next = 1;
    log_msg("set valid: hdr.qlr_updates[1]");
    hdr.qlr_updates[2].has_next = 1;
    log_msg("set valid: hdr.qlr_updates[2]");
    hdr.qlr_updates[3].has_next = 0;
    log_msg("set valid: hdr.qlr_updates[3]");
    hdr.qlr_updates[4].setInvalid();
    hdr.qlr_updates[4].dst_id = 0;
    log_msg("set invalid: hdr.qlr_updates[4]");
}

action qlr_pkt_set_1_2_3_4_5() {
    hdr.ethernet.dst_addr[47:40] = 0x1;
    hdr.qlr_updates[0].has_next = 1;
    log_msg("set valid: hdr.qlr_updates[0]");
    hdr.qlr_updates[1].has_next = 1;
    log_msg("set valid: hdr.qlr_updates[1]");
    hdr.qlr_updates[2].has_next = 1;
    log_msg("set valid: hdr.qlr_updates[2]");
    hdr.qlr_updates[3].has_next = 1;
    log_msg("set valid: hdr.qlr_updates[3]");
    hdr.qlr_updates[4].has_next = 0;
    log_msg("set valid: hdr.qlr_updates[4]");
}

action qlr_pkt_set_1_2_3_5() {
    hdr.ethernet.dst_addr[47:40] = 0x1;
    hdr.qlr_updates[0].has_next = 1;
    log_msg("set valid: hdr.qlr_updates[0]");
    hdr.qlr_updates[1].has_next = 1;
    log_msg("set valid: hdr.qlr_updates[1]");
    hdr.qlr_updates[2].has_next = 1;
    log_msg("set valid: hdr.qlr_updates[2]");
    hdr.qlr_updates[3].setInvalid();
    hdr.qlr_updates[3].dst_id = 0;
    log_msg("set invalid: hdr.qlr_updates[3]");
    hdr.qlr_updates[4].has_next = 0;
    log_msg("set valid: hdr.qlr_updates[4]");
}

action qlr_pkt_set_1_2_4() {
    hdr.ethernet.dst_addr[47:40] = 0x1;
    hdr.qlr_updates[0].has_next = 1;
    log_msg("set valid: hdr.qlr_updates[0]");
    hdr.qlr_updates[1].has_next = 1;
    log_msg("set valid: hdr.qlr_updates[1]");
    hdr.qlr_updates[2].setInvalid();
    hdr.qlr_updates[2].dst_id = 0;
    log_msg("set invalid: hdr.qlr_updates[2]");
    hdr.qlr_updates[3].has_next = 0;
    log_msg("set valid: hdr.qlr_updates[3]");
    hdr.qlr_updates[4].setInvalid();
    hdr.qlr_updates[4].dst_id = 0;
    log_msg("set invalid: hdr.qlr_updates[4]");
}

action qlr_pkt_set_1_2_4_5() {
    hdr.ethernet.dst_addr[47:40] = 0x1;
    hdr.qlr_updates[0].has_next = 1;
    log_msg("set valid: hdr.qlr_updates[0]");
    hdr.qlr_updates[1].has_next = 1;
    log_msg("set valid: hdr.qlr_updates[1]");
    hdr.qlr_updates[2].setInvalid();
    hdr.qlr_updates[2].dst_id = 0;
    log_msg("set invalid: hdr.qlr_updates[2]");
    hdr.qlr_updates[3].has_next = 1;
    log_msg("set valid: hdr.qlr_updates[3]");
    hdr.qlr_updates[4].has_next = 0;
    log_msg("set valid: hdr.qlr_updates[4]");
}

action qlr_pkt_set_1_2_5() {
    hdr.ethernet.dst_addr[47:40] = 0x1;
    hdr.qlr_updates[0].has_next = 1;
    log_msg("set valid: hdr.qlr_updates[0]");
    hdr.qlr_updates[1].has_next = 1;
    log_msg("set valid: hdr.qlr_updates[1]");
    hdr.qlr_updates[2].setInvalid();
    hdr.qlr_updates[2].dst_id = 0;
    log_msg("set invalid: hdr.qlr_updates[2]");
    hdr.qlr_updates[3].setInvalid();
    hdr.qlr_updates[3].dst_id = 0;
    log_msg("set invalid: hdr.qlr_updates[3]");
    hdr.qlr_updates[4].has_next = 0;
    log_msg("set valid: hdr.qlr_updates[4]");
}

action qlr_pkt_set_1_3() {
    hdr.ethernet.dst_addr[47:40] = 0x1;
    hdr.qlr_updates[0].has_next = 1;
    log_msg("set valid: hdr.qlr_updates[0]");
    hdr.qlr_updates[1].setInvalid();
    hdr.qlr_updates[1].dst_id = 0;
    log_msg("set invalid: hdr.qlr_updates[1]");
    hdr.qlr_updates[2].has_next = 0;
    log_msg("set valid: hdr.qlr_updates[2]");
    hdr.qlr_updates[3].setInvalid();
    hdr.qlr_updates[3].dst_id = 0;
    log_msg("set invalid: hdr.qlr_updates[3]");
    hdr.qlr_updates[4].setInvalid();
    hdr.qlr_updates[4].dst_id = 0;
    log_msg("set invalid: hdr.qlr_updates[4]");
}

action qlr_pkt_set_1_3_4() {
    hdr.ethernet.dst_addr[47:40] = 0x1;
    hdr.qlr_updates[0].has_next = 1;
    log_msg("set valid: hdr.qlr_updates[0]");
    hdr.qlr_updates[1].setInvalid();
    hdr.qlr_updates[1].dst_id = 0;
    log_msg("set invalid: hdr.qlr_updates[1]");
    hdr.qlr_updates[2].has_next = 1;
    log_msg("set valid: hdr.qlr_updates[2]");
    hdr.qlr_updates[3].has_next = 0;
    log_msg("set valid: hdr.qlr_updates[3]");
    hdr.qlr_updates[4].setInvalid();
    hdr.qlr_updates[4].dst_id = 0;
    log_msg("set invalid: hdr.qlr_updates[4]");
}

action qlr_pkt_set_1_3_4_5() {
    hdr.ethernet.dst_addr[47:40] = 0x1;
    hdr.qlr_updates[0].has_next = 1;
    log_msg("set valid: hdr.qlr_updates[0]");
    hdr.qlr_updates[1].setInvalid();
    hdr.qlr_updates[1].dst_id = 0;
    log_msg("set invalid: hdr.qlr_updates[1]");
    hdr.qlr_updates[2].has_next = 1;
    log_msg("set valid: hdr.qlr_updates[2]");
    hdr.qlr_updates[3].has_next = 1;
    log_msg("set valid: hdr.qlr_updates[3]");
    hdr.qlr_updates[4].has_next = 0;
    log_msg("set valid: hdr.qlr_updates[4]");
}

action qlr_pkt_set_1_3_5() {
    hdr.ethernet.dst_addr[47:40] = 0x1;
    hdr.qlr_updates[0].has_next = 1;
    log_msg("set valid: hdr.qlr_updates[0]");
    hdr.qlr_updates[1].setInvalid();
    hdr.qlr_updates[1].dst_id = 0;
    log_msg("set invalid: hdr.qlr_updates[1]");
    hdr.qlr_updates[2].has_next = 1;
    log_msg("set valid: hdr.qlr_updates[2]");
    hdr.qlr_updates[3].setInvalid();
    hdr.qlr_updates[3].dst_id = 0;
    log_msg("set invalid: hdr.qlr_updates[3]");
    hdr.qlr_updates[4].has_next = 0;
    log_msg("set valid: hdr.qlr_updates[4]");
}

action qlr_pkt_set_1_4() {
    hdr.ethernet.dst_addr[47:40] = 0x1;
    hdr.qlr_updates[0].has_next = 1;
    log_msg("set valid: hdr.qlr_updates[0]");
    hdr.qlr_updates[1].setInvalid();
    hdr.qlr_updates[1].dst_id = 0;
    log_msg("set invalid: hdr.qlr_updates[1]");
    hdr.qlr_updates[2].setInvalid();
    hdr.qlr_updates[2].dst_id = 0;
    log_msg("set invalid: hdr.qlr_updates[2]");
    hdr.qlr_updates[3].has_next = 0;
    log_msg("set valid: hdr.qlr_updates[3]");
    hdr.qlr_updates[4].setInvalid();
    hdr.qlr_updates[4].dst_id = 0;
    log_msg("set invalid: hdr.qlr_updates[4]");
}

action qlr_pkt_set_1_4_5() {
    hdr.ethernet.dst_addr[47:40] = 0x1;
    hdr.qlr_updates[0].has_next = 1;
    log_msg("set valid: hdr.qlr_updates[0]");
    hdr.qlr_updates[1].setInvalid();
    hdr.qlr_updates[1].dst_id = 0;
    log_msg("set invalid: hdr.qlr_updates[1]");
    hdr.qlr_updates[2].setInvalid();
    hdr.qlr_updates[2].dst_id = 0;
    log_msg("set invalid: hdr.qlr_updates[2]");
    hdr.qlr_updates[3].has_next = 1;
    log_msg("set valid: hdr.qlr_updates[3]");
    hdr.qlr_updates[4].has_next = 0;
    log_msg("set valid: hdr.qlr_updates[4]");
}

action qlr_pkt_set_1_5() {
    hdr.ethernet.dst_addr[47:40] = 0x1;
    hdr.qlr_updates[0].has_next = 1;
    log_msg("set valid: hdr.qlr_updates[0]");
    hdr.qlr_updates[1].setInvalid();
    hdr.qlr_updates[1].dst_id = 0;
    log_msg("set invalid: hdr.qlr_updates[1]");
    hdr.qlr_updates[2].setInvalid();
    hdr.qlr_updates[2].dst_id = 0;
    log_msg("set invalid: hdr.qlr_updates[2]");
    hdr.qlr_updates[3].setInvalid();
    hdr.qlr_updates[3].dst_id = 0;
    log_msg("set invalid: hdr.qlr_updates[3]");
    hdr.qlr_updates[4].has_next = 0;
    log_msg("set valid: hdr.qlr_updates[4]");
}

action qlr_pkt_set_2() {
    hdr.ethernet.dst_addr[47:40] = 0x1;
    hdr.qlr_updates[0].setInvalid();
    hdr.qlr_updates[0].dst_id = 0;
    log_msg("set invalid: hdr.qlr_updates[0]");
    hdr.qlr_updates[1].has_next = 0;
    log_msg("set valid: hdr.qlr_updates[1]");
    hdr.qlr_updates[2].setInvalid();
    hdr.qlr_updates[2].dst_id = 0;
    log_msg("set invalid: hdr.qlr_updates[2]");
    hdr.qlr_updates[3].setInvalid();
    hdr.qlr_updates[3].dst_id = 0;
    log_msg("set invalid: hdr.qlr_updates[3]");
    hdr.qlr_updates[4].setInvalid();
    hdr.qlr_updates[4].dst_id = 0;
    log_msg("set invalid: hdr.qlr_updates[4]");
}

action qlr_pkt_set_2_3() {
    hdr.ethernet.dst_addr[47:40] = 0x1;
    hdr.qlr_updates[0].setInvalid();
    hdr.qlr_updates[0].dst_id = 0;
    log_msg("set invalid: hdr.qlr_updates[0]");
    hdr.qlr_updates[1].has_next = 1;
    log_msg("set valid: hdr.qlr_updates[1]");
    hdr.qlr_updates[2].has_next = 0;
    log_msg("set valid: hdr.qlr_updates[2]");
    hdr.qlr_updates[3].setInvalid();
    hdr.qlr_updates[3].dst_id = 0;
    log_msg("set invalid: hdr.qlr_updates[3]");
    hdr.qlr_updates[4].setInvalid();
    hdr.qlr_updates[4].dst_id = 0;
    log_msg("set invalid: hdr.qlr_updates[4]");
}

action qlr_pkt_set_2_3_4() {
    hdr.ethernet.dst_addr[47:40] = 0x1;
    hdr.qlr_updates[0].setInvalid();
    hdr.qlr_updates[0].dst_id = 0;
    log_msg("set invalid: hdr.qlr_updates[0]");
    hdr.qlr_updates[1].has_next = 1;
    log_msg("set valid: hdr.qlr_updates[1]");
    hdr.qlr_updates[2].has_next = 1;
    log_msg("set valid: hdr.qlr_updates[2]");
    hdr.qlr_updates[3].has_next = 0;
    log_msg("set valid: hdr.qlr_updates[3]");
    hdr.qlr_updates[4].setInvalid();
    hdr.qlr_updates[4].dst_id = 0;
    log_msg("set invalid: hdr.qlr_updates[4]");
}

action qlr_pkt_set_2_3_4_5() {
    hdr.ethernet.dst_addr[47:40] = 0x1;
    hdr.qlr_updates[0].setInvalid();
    hdr.qlr_updates[0].dst_id = 0;
    log_msg("set invalid: hdr.qlr_updates[0]");
    hdr.qlr_updates[1].has_next = 1;
    log_msg("set valid: hdr.qlr_updates[1]");
    hdr.qlr_updates[2].has_next = 1;
    log_msg("set valid: hdr.qlr_updates[2]");
    hdr.qlr_updates[3].has_next = 1;
    log_msg("set valid: hdr.qlr_updates[3]");
    hdr.qlr_updates[4].has_next = 0;
    log_msg("set valid: hdr.qlr_updates[4]");
}

action qlr_pkt_set_2_3_5() {
    hdr.ethernet.dst_addr[47:40] = 0x1;
    hdr.qlr_updates[0].setInvalid();
    hdr.qlr_updates[0].dst_id = 0;
    log_msg("set invalid: hdr.qlr_updates[0]");
    hdr.qlr_updates[1].has_next = 1;
    log_msg("set valid: hdr.qlr_updates[1]");
    hdr.qlr_updates[2].has_next = 1;
    log_msg("set valid: hdr.qlr_updates[2]");
    hdr.qlr_updates[3].setInvalid();
    hdr.qlr_updates[3].dst_id = 0;
    log_msg("set invalid: hdr.qlr_updates[3]");
    hdr.qlr_updates[4].has_next = 0;
    log_msg("set valid: hdr.qlr_updates[4]");
}

action qlr_pkt_set_2_4() {
    hdr.ethernet.dst_addr[47:40] = 0x1;
    hdr.qlr_updates[0].setInvalid();
    hdr.qlr_updates[0].dst_id = 0;
    log_msg("set invalid: hdr.qlr_updates[0]");
    hdr.qlr_updates[1].has_next = 1;
    log_msg("set valid: hdr.qlr_updates[1]");
    hdr.qlr_updates[2].setInvalid();
    hdr.qlr_updates[2].dst_id = 0;
    log_msg("set invalid: hdr.qlr_updates[2]");
    hdr.qlr_updates[3].has_next = 0;
    log_msg("set valid: hdr.qlr_updates[3]");
    hdr.qlr_updates[4].setInvalid();
    hdr.qlr_updates[4].dst_id = 0;
    log_msg("set invalid: hdr.qlr_updates[4]");
}

action qlr_pkt_set_2_4_5() {
    hdr.ethernet.dst_addr[47:40] = 0x1;
    hdr.qlr_updates[0].setInvalid();
    hdr.qlr_updates[0].dst_id = 0;
    log_msg("set invalid: hdr.qlr_updates[0]");
    hdr.qlr_updates[1].has_next = 1;
    log_msg("set valid: hdr.qlr_updates[1]");
    hdr.qlr_updates[2].setInvalid();
    hdr.qlr_updates[2].dst_id = 0;
    log_msg("set invalid: hdr.qlr_updates[2]");
    hdr.qlr_updates[3].has_next = 1;
    log_msg("set valid: hdr.qlr_updates[3]");
    hdr.qlr_updates[4].has_next = 0;
    log_msg("set valid: hdr.qlr_updates[4]");
}

action qlr_pkt_set_2_5() {
    hdr.ethernet.dst_addr[47:40] = 0x1;
    hdr.qlr_updates[0].setInvalid();
    hdr.qlr_updates[0].dst_id = 0;
    log_msg("set invalid: hdr.qlr_updates[0]");
    hdr.qlr_updates[1].has_next = 1;
    log_msg("set valid: hdr.qlr_updates[1]");
    hdr.qlr_updates[2].setInvalid();
    hdr.qlr_updates[2].dst_id = 0;
    log_msg("set invalid: hdr.qlr_updates[2]");
    hdr.qlr_updates[3].setInvalid();
    hdr.qlr_updates[3].dst_id = 0;
    log_msg("set invalid: hdr.qlr_updates[3]");
    hdr.qlr_updates[4].has_next = 0;
    log_msg("set valid: hdr.qlr_updates[4]");
}

action qlr_pkt_set_3() {
    hdr.ethernet.dst_addr[47:40] = 0x1;
    hdr.qlr_updates[0].setInvalid();
    hdr.qlr_updates[0].dst_id = 0;
    log_msg("set invalid: hdr.qlr_updates[0]");
    hdr.qlr_updates[1].setInvalid();
    hdr.qlr_updates[1].dst_id = 0;
    log_msg("set invalid: hdr.qlr_updates[1]");
    hdr.qlr_updates[2].has_next = 0;
    log_msg("set valid: hdr.qlr_updates[2]");
    hdr.qlr_updates[3].setInvalid();
    hdr.qlr_updates[3].dst_id = 0;
    log_msg("set invalid: hdr.qlr_updates[3]");
    hdr.qlr_updates[4].setInvalid();
    hdr.qlr_updates[4].dst_id = 0;
    log_msg("set invalid: hdr.qlr_updates[4]");
}

action qlr_pkt_set_3_4() {
    hdr.ethernet.dst_addr[47:40] = 0x1;
    hdr.qlr_updates[0].setInvalid();
    hdr.qlr_updates[0].dst_id = 0;
    log_msg("set invalid: hdr.qlr_updates[0]");
    hdr.qlr_updates[1].setInvalid();
    hdr.qlr_updates[1].dst_id = 0;
    log_msg("set invalid: hdr.qlr_updates[1]");
    hdr.qlr_updates[2].has_next = 1;
    log_msg("set valid: hdr.qlr_updates[2]");
    hdr.qlr_updates[3].has_next = 0;
    log_msg("set valid: hdr.qlr_updates[3]");
    hdr.qlr_updates[4].setInvalid();
    hdr.qlr_updates[4].dst_id = 0;
    log_msg("set invalid: hdr.qlr_updates[4]");
}

action qlr_pkt_set_3_4_5() {
    hdr.ethernet.dst_addr[47:40] = 0x1;
    hdr.qlr_updates[0].setInvalid();
    hdr.qlr_updates[0].dst_id = 0;
    log_msg("set invalid: hdr.qlr_updates[0]");
    hdr.qlr_updates[1].setInvalid();
    hdr.qlr_updates[1].dst_id = 0;
    log_msg("set invalid: hdr.qlr_updates[1]");
    hdr.qlr_updates[2].has_next = 1;
    log_msg("set valid: hdr.qlr_updates[2]");
    hdr.qlr_updates[3].has_next = 1;
    log_msg("set valid: hdr.qlr_updates[3]");
    hdr.qlr_updates[4].has_next = 0;
    log_msg("set valid: hdr.qlr_updates[4]");
}

action qlr_pkt_set_3_5() {
    hdr.ethernet.dst_addr[47:40] = 0x1;
    hdr.qlr_updates[0].setInvalid();
    hdr.qlr_updates[0].dst_id = 0;
    log_msg("set invalid: hdr.qlr_updates[0]");
    hdr.qlr_updates[1].setInvalid();
    hdr.qlr_updates[1].dst_id = 0;
    log_msg("set invalid: hdr.qlr_updates[1]");
    hdr.qlr_updates[2].has_next = 1;
    log_msg("set valid: hdr.qlr_updates[2]");
    hdr.qlr_updates[3].setInvalid();
    hdr.qlr_updates[3].dst_id = 0;
    log_msg("set invalid: hdr.qlr_updates[3]");
    hdr.qlr_updates[4].has_next = 0;
    log_msg("set valid: hdr.qlr_updates[4]");
}

action qlr_pkt_set_4() {
    hdr.ethernet.dst_addr[47:40] = 0x1;
    hdr.qlr_updates[0].setInvalid();
    hdr.qlr_updates[0].dst_id = 0;
    log_msg("set invalid: hdr.qlr_updates[0]");
    hdr.qlr_updates[1].setInvalid();
    hdr.qlr_updates[1].dst_id = 0;
    log_msg("set invalid: hdr.qlr_updates[1]");
    hdr.qlr_updates[2].setInvalid();
    hdr.qlr_updates[2].dst_id = 0;
    log_msg("set invalid: hdr.qlr_updates[2]");
    hdr.qlr_updates[3].has_next = 0;
    log_msg("set valid: hdr.qlr_updates[3]");
    hdr.qlr_updates[4].setInvalid();
    hdr.qlr_updates[4].dst_id = 0;
    log_msg("set invalid: hdr.qlr_updates[4]");
}

action qlr_pkt_set_4_5() {
    hdr.ethernet.dst_addr[47:40] = 0x1;
    hdr.qlr_updates[0].setInvalid();
    hdr.qlr_updates[0].dst_id = 0;
    log_msg("set invalid: hdr.qlr_updates[0]");
    hdr.qlr_updates[1].setInvalid();
    hdr.qlr_updates[1].dst_id = 0;
    log_msg("set invalid: hdr.qlr_updates[1]");
    hdr.qlr_updates[2].setInvalid();
    hdr.qlr_updates[2].dst_id = 0;
    log_msg("set invalid: hdr.qlr_updates[2]");
    hdr.qlr_updates[3].has_next = 1;
    log_msg("set valid: hdr.qlr_updates[3]");
    hdr.qlr_updates[4].has_next = 0;
    log_msg("set valid: hdr.qlr_updates[4]");
}

action qlr_pkt_set_5() {
    hdr.ethernet.dst_addr[47:40] = 0x1;
    hdr.qlr_updates[0].setInvalid();
    hdr.qlr_updates[0].dst_id = 0;
    log_msg("set invalid: hdr.qlr_updates[0]");
    hdr.qlr_updates[1].setInvalid();
    hdr.qlr_updates[1].dst_id = 0;
    log_msg("set invalid: hdr.qlr_updates[1]");
    hdr.qlr_updates[2].setInvalid();
    hdr.qlr_updates[2].dst_id = 0;
    log_msg("set invalid: hdr.qlr_updates[2]");
    hdr.qlr_updates[3].setInvalid();
    hdr.qlr_updates[3].dst_id = 0;
    log_msg("set invalid: hdr.qlr_updates[3]");
    hdr.qlr_updates[4].has_next = 0;
    log_msg("set valid: hdr.qlr_updates[4]");
}

table qlr_pkt_updates {
    key = {
        row_num: exact;
        standard_metadata.egress_spec: exact;
    }
    actions = {
        qlr_pkt_set_1;
        qlr_pkt_set_1_2;
        qlr_pkt_set_1_2_3;
        qlr_pkt_set_1_2_3_4;
        qlr_pkt_set_1_2_3_4_5;
        qlr_pkt_set_1_2_3_5;
        qlr_pkt_set_1_2_4;
        qlr_pkt_set_1_2_4_5;
        qlr_pkt_set_1_2_5;
        qlr_pkt_set_1_3;
        qlr_pkt_set_1_3_4;
        qlr_pkt_set_1_3_4_5;
        qlr_pkt_set_1_3_5;
        qlr_pkt_set_1_4;
        qlr_pkt_set_1_4_5;
        qlr_pkt_set_1_5;
        qlr_pkt_set_2;
        qlr_pkt_set_2_3;
        qlr_pkt_set_2_3_4;
        qlr_pkt_set_2_3_4_5;
        qlr_pkt_set_2_3_5;
        qlr_pkt_set_2_4;
        qlr_pkt_set_2_4_5;
        qlr_pkt_set_2_5;
        qlr_pkt_set_3;
        qlr_pkt_set_3_4;
        qlr_pkt_set_3_4_5;
        qlr_pkt_set_3_5;
        qlr_pkt_set_4;
        qlr_pkt_set_4_5;
        qlr_pkt_set_5;
    }
    size = 31;
}

#endif