#ifndef __QLR_PKT_UPDATES__
#define __QLR_PKT_UPDATES__

action qlr_pkt_set_1() {
    hdr.qlr_updates[0].setValid();
    hdr.qlr_updates.has_next = 0;
    log_msg("set valid: hdr.qlr_updates[0]");
}

action qlr_pkt_set_1_2() {
    hdr.qlr_updates[0].setValid();
    hdr.qlr_updates.has_next = 1;
    log_msg("set valid: hdr.qlr_updates[0]");
    hdr.qlr_updates[1].setValid();
    hdr.qlr_updates.has_next = 0;
    log_msg("set valid: hdr.qlr_updates[1]");
}

action qlr_pkt_set_1_2_3() {
    hdr.qlr_updates[0].setValid();
    hdr.qlr_updates.has_next = 1;
    log_msg("set valid: hdr.qlr_updates[0]");
    hdr.qlr_updates[1].setValid();
    hdr.qlr_updates.has_next = 1;
    log_msg("set valid: hdr.qlr_updates[1]");
    hdr.qlr_updates[2].setValid();
    hdr.qlr_updates.has_next = 0;
    log_msg("set valid: hdr.qlr_updates[2]");
}

action qlr_pkt_set_1_2_3_4() {
    hdr.qlr_updates[0].setValid();
    hdr.qlr_updates.has_next = 1;
    log_msg("set valid: hdr.qlr_updates[0]");
    hdr.qlr_updates[1].setValid();
    hdr.qlr_updates.has_next = 1;
    log_msg("set valid: hdr.qlr_updates[1]");
    hdr.qlr_updates[2].setValid();
    hdr.qlr_updates.has_next = 1;
    log_msg("set valid: hdr.qlr_updates[2]");
    hdr.qlr_updates[3].setValid();
    hdr.qlr_updates.has_next = 0;
    log_msg("set valid: hdr.qlr_updates[3]");
}

action qlr_pkt_set_1_2_3_4_5() {
    hdr.qlr_updates[0].setValid();
    hdr.qlr_updates.has_next = 1;
    log_msg("set valid: hdr.qlr_updates[0]");
    hdr.qlr_updates[1].setValid();
    hdr.qlr_updates.has_next = 1;
    log_msg("set valid: hdr.qlr_updates[1]");
    hdr.qlr_updates[2].setValid();
    hdr.qlr_updates.has_next = 1;
    log_msg("set valid: hdr.qlr_updates[2]");
    hdr.qlr_updates[3].setValid();
    hdr.qlr_updates.has_next = 1;
    log_msg("set valid: hdr.qlr_updates[3]");
    hdr.qlr_updates[4].setValid();
    hdr.qlr_updates.has_next = 0;
    log_msg("set valid: hdr.qlr_updates[4]");
}

action qlr_pkt_set_1_2_3_5() {
    hdr.qlr_updates[0].setValid();
    hdr.qlr_updates.has_next = 1;
    log_msg("set valid: hdr.qlr_updates[0]");
    hdr.qlr_updates[1].setValid();
    hdr.qlr_updates.has_next = 1;
    log_msg("set valid: hdr.qlr_updates[1]");
    hdr.qlr_updates[2].setValid();
    hdr.qlr_updates.has_next = 1;
    log_msg("set valid: hdr.qlr_updates[2]");
    hdr.qlr_updates[4].setValid();
    hdr.qlr_updates.has_next = 0;
    log_msg("set valid: hdr.qlr_updates[4]");
}

action qlr_pkt_set_1_2_4() {
    hdr.qlr_updates[0].setValid();
    hdr.qlr_updates.has_next = 1;
    log_msg("set valid: hdr.qlr_updates[0]");
    hdr.qlr_updates[1].setValid();
    hdr.qlr_updates.has_next = 1;
    log_msg("set valid: hdr.qlr_updates[1]");
    hdr.qlr_updates[3].setValid();
    hdr.qlr_updates.has_next = 0;
    log_msg("set valid: hdr.qlr_updates[3]");
}

action qlr_pkt_set_1_2_4_5() {
    hdr.qlr_updates[0].setValid();
    hdr.qlr_updates.has_next = 1;
    log_msg("set valid: hdr.qlr_updates[0]");
    hdr.qlr_updates[1].setValid();
    hdr.qlr_updates.has_next = 1;
    log_msg("set valid: hdr.qlr_updates[1]");
    hdr.qlr_updates[3].setValid();
    hdr.qlr_updates.has_next = 1;
    log_msg("set valid: hdr.qlr_updates[3]");
    hdr.qlr_updates[4].setValid();
    hdr.qlr_updates.has_next = 0;
    log_msg("set valid: hdr.qlr_updates[4]");
}

action qlr_pkt_set_1_2_5() {
    hdr.qlr_updates[0].setValid();
    hdr.qlr_updates.has_next = 1;
    log_msg("set valid: hdr.qlr_updates[0]");
    hdr.qlr_updates[1].setValid();
    hdr.qlr_updates.has_next = 1;
    log_msg("set valid: hdr.qlr_updates[1]");
    hdr.qlr_updates[4].setValid();
    hdr.qlr_updates.has_next = 0;
    log_msg("set valid: hdr.qlr_updates[4]");
}

action qlr_pkt_set_1_3() {
    hdr.qlr_updates[0].setValid();
    hdr.qlr_updates.has_next = 1;
    log_msg("set valid: hdr.qlr_updates[0]");
    hdr.qlr_updates[2].setValid();
    hdr.qlr_updates.has_next = 0;
    log_msg("set valid: hdr.qlr_updates[2]");
}

action qlr_pkt_set_1_3_4() {
    hdr.qlr_updates[0].setValid();
    hdr.qlr_updates.has_next = 1;
    log_msg("set valid: hdr.qlr_updates[0]");
    hdr.qlr_updates[2].setValid();
    hdr.qlr_updates.has_next = 1;
    log_msg("set valid: hdr.qlr_updates[2]");
    hdr.qlr_updates[3].setValid();
    hdr.qlr_updates.has_next = 0;
    log_msg("set valid: hdr.qlr_updates[3]");
}

action qlr_pkt_set_1_3_4_5() {
    hdr.qlr_updates[0].setValid();
    hdr.qlr_updates.has_next = 1;
    log_msg("set valid: hdr.qlr_updates[0]");
    hdr.qlr_updates[2].setValid();
    hdr.qlr_updates.has_next = 1;
    log_msg("set valid: hdr.qlr_updates[2]");
    hdr.qlr_updates[3].setValid();
    hdr.qlr_updates.has_next = 1;
    log_msg("set valid: hdr.qlr_updates[3]");
    hdr.qlr_updates[4].setValid();
    hdr.qlr_updates.has_next = 0;
    log_msg("set valid: hdr.qlr_updates[4]");
}

action qlr_pkt_set_1_3_5() {
    hdr.qlr_updates[0].setValid();
    hdr.qlr_updates.has_next = 1;
    log_msg("set valid: hdr.qlr_updates[0]");
    hdr.qlr_updates[2].setValid();
    hdr.qlr_updates.has_next = 1;
    log_msg("set valid: hdr.qlr_updates[2]");
    hdr.qlr_updates[4].setValid();
    hdr.qlr_updates.has_next = 0;
    log_msg("set valid: hdr.qlr_updates[4]");
}

action qlr_pkt_set_1_4() {
    hdr.qlr_updates[0].setValid();
    hdr.qlr_updates.has_next = 1;
    log_msg("set valid: hdr.qlr_updates[0]");
    hdr.qlr_updates[3].setValid();
    hdr.qlr_updates.has_next = 0;
    log_msg("set valid: hdr.qlr_updates[3]");
}

action qlr_pkt_set_1_4_5() {
    hdr.qlr_updates[0].setValid();
    hdr.qlr_updates.has_next = 1;
    log_msg("set valid: hdr.qlr_updates[0]");
    hdr.qlr_updates[3].setValid();
    hdr.qlr_updates.has_next = 1;
    log_msg("set valid: hdr.qlr_updates[3]");
    hdr.qlr_updates[4].setValid();
    hdr.qlr_updates.has_next = 0;
    log_msg("set valid: hdr.qlr_updates[4]");
}

action qlr_pkt_set_1_5() {
    hdr.qlr_updates[0].setValid();
    hdr.qlr_updates.has_next = 1;
    log_msg("set valid: hdr.qlr_updates[0]");
    hdr.qlr_updates[4].setValid();
    hdr.qlr_updates.has_next = 0;
    log_msg("set valid: hdr.qlr_updates[4]");
}

action qlr_pkt_set_2() {
    hdr.qlr_updates[1].setValid();
    hdr.qlr_updates.has_next = 0;
    log_msg("set valid: hdr.qlr_updates[1]");
}

action qlr_pkt_set_2_3() {
    hdr.qlr_updates[1].setValid();
    hdr.qlr_updates.has_next = 1;
    log_msg("set valid: hdr.qlr_updates[1]");
    hdr.qlr_updates[2].setValid();
    hdr.qlr_updates.has_next = 0;
    log_msg("set valid: hdr.qlr_updates[2]");
}

action qlr_pkt_set_2_3_4() {
    hdr.qlr_updates[1].setValid();
    hdr.qlr_updates.has_next = 1;
    log_msg("set valid: hdr.qlr_updates[1]");
    hdr.qlr_updates[2].setValid();
    hdr.qlr_updates.has_next = 1;
    log_msg("set valid: hdr.qlr_updates[2]");
    hdr.qlr_updates[3].setValid();
    hdr.qlr_updates.has_next = 0;
    log_msg("set valid: hdr.qlr_updates[3]");
}

action qlr_pkt_set_2_3_4_5() {
    hdr.qlr_updates[1].setValid();
    hdr.qlr_updates.has_next = 1;
    log_msg("set valid: hdr.qlr_updates[1]");
    hdr.qlr_updates[2].setValid();
    hdr.qlr_updates.has_next = 1;
    log_msg("set valid: hdr.qlr_updates[2]");
    hdr.qlr_updates[3].setValid();
    hdr.qlr_updates.has_next = 1;
    log_msg("set valid: hdr.qlr_updates[3]");
    hdr.qlr_updates[4].setValid();
    hdr.qlr_updates.has_next = 0;
    log_msg("set valid: hdr.qlr_updates[4]");
}

action qlr_pkt_set_2_3_5() {
    hdr.qlr_updates[1].setValid();
    hdr.qlr_updates.has_next = 1;
    log_msg("set valid: hdr.qlr_updates[1]");
    hdr.qlr_updates[2].setValid();
    hdr.qlr_updates.has_next = 1;
    log_msg("set valid: hdr.qlr_updates[2]");
    hdr.qlr_updates[4].setValid();
    hdr.qlr_updates.has_next = 0;
    log_msg("set valid: hdr.qlr_updates[4]");
}

action qlr_pkt_set_2_4() {
    hdr.qlr_updates[1].setValid();
    hdr.qlr_updates.has_next = 1;
    log_msg("set valid: hdr.qlr_updates[1]");
    hdr.qlr_updates[3].setValid();
    hdr.qlr_updates.has_next = 0;
    log_msg("set valid: hdr.qlr_updates[3]");
}

action qlr_pkt_set_2_4_5() {
    hdr.qlr_updates[1].setValid();
    hdr.qlr_updates.has_next = 1;
    log_msg("set valid: hdr.qlr_updates[1]");
    hdr.qlr_updates[3].setValid();
    hdr.qlr_updates.has_next = 1;
    log_msg("set valid: hdr.qlr_updates[3]");
    hdr.qlr_updates[4].setValid();
    hdr.qlr_updates.has_next = 0;
    log_msg("set valid: hdr.qlr_updates[4]");
}

action qlr_pkt_set_2_5() {
    hdr.qlr_updates[1].setValid();
    hdr.qlr_updates.has_next = 1;
    log_msg("set valid: hdr.qlr_updates[1]");
    hdr.qlr_updates[4].setValid();
    hdr.qlr_updates.has_next = 0;
    log_msg("set valid: hdr.qlr_updates[4]");
}

action qlr_pkt_set_3() {
    hdr.qlr_updates[2].setValid();
    hdr.qlr_updates.has_next = 0;
    log_msg("set valid: hdr.qlr_updates[2]");
}

action qlr_pkt_set_3_4() {
    hdr.qlr_updates[2].setValid();
    hdr.qlr_updates.has_next = 1;
    log_msg("set valid: hdr.qlr_updates[2]");
    hdr.qlr_updates[3].setValid();
    hdr.qlr_updates.has_next = 0;
    log_msg("set valid: hdr.qlr_updates[3]");
}

action qlr_pkt_set_3_4_5() {
    hdr.qlr_updates[2].setValid();
    hdr.qlr_updates.has_next = 1;
    log_msg("set valid: hdr.qlr_updates[2]");
    hdr.qlr_updates[3].setValid();
    hdr.qlr_updates.has_next = 1;
    log_msg("set valid: hdr.qlr_updates[3]");
    hdr.qlr_updates[4].setValid();
    hdr.qlr_updates.has_next = 0;
    log_msg("set valid: hdr.qlr_updates[4]");
}

action qlr_pkt_set_3_5() {
    hdr.qlr_updates[2].setValid();
    hdr.qlr_updates.has_next = 1;
    log_msg("set valid: hdr.qlr_updates[2]");
    hdr.qlr_updates[4].setValid();
    hdr.qlr_updates.has_next = 0;
    log_msg("set valid: hdr.qlr_updates[4]");
}

action qlr_pkt_set_4() {
    hdr.qlr_updates[3].setValid();
    hdr.qlr_updates.has_next = 0;
    log_msg("set valid: hdr.qlr_updates[3]");
}

action qlr_pkt_set_4_5() {
    hdr.qlr_updates[3].setValid();
    hdr.qlr_updates.has_next = 1;
    log_msg("set valid: hdr.qlr_updates[3]");
    hdr.qlr_updates[4].setValid();
    hdr.qlr_updates.has_next = 0;
    log_msg("set valid: hdr.qlr_updates[4]");
}

action qlr_pkt_set_5() {
    hdr.qlr_updates[4].setValid();
    hdr.qlr_updates.has_next = 0;
    log_msg("set valid: hdr.qlr_updates[4]");
}

table qlr_pkt_updates {
    key = {
        row_num: exact;
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