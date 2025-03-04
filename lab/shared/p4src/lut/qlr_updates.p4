#ifndef __QLR_UPDATES__
#define __QLR_UPDATES__

action enable_1() {
    hdr.update_list[0].setValid();
    hdr.update_list.next = 0;
}

action enable_1_2() {
    hdr.update_list[0].setValid();
    hdr.update_list.next = 1;
    hdr.update_list[1].setValid();
    hdr.update_list.next = 0;
}

action enable_1_2_3() {
    hdr.update_list[0].setValid();
    hdr.update_list.next = 1;
    hdr.update_list[1].setValid();
    hdr.update_list.next = 1;
    hdr.update_list[2].setValid();
    hdr.update_list.next = 0;
}

action enable_1_2_3_4() {
    hdr.update_list[0].setValid();
    hdr.update_list.next = 1;
    hdr.update_list[1].setValid();
    hdr.update_list.next = 1;
    hdr.update_list[2].setValid();
    hdr.update_list.next = 1;
    hdr.update_list[3].setValid();
    hdr.update_list.next = 0;
}

action enable_1_2_3_4_5() {
    hdr.update_list[0].setValid();
    hdr.update_list.next = 1;
    hdr.update_list[1].setValid();
    hdr.update_list.next = 1;
    hdr.update_list[2].setValid();
    hdr.update_list.next = 1;
    hdr.update_list[3].setValid();
    hdr.update_list.next = 1;
    hdr.update_list[4].setValid();
    hdr.update_list.next = 0;
}

action enable_1_2_3_5() {
    hdr.update_list[0].setValid();
    hdr.update_list.next = 1;
    hdr.update_list[1].setValid();
    hdr.update_list.next = 1;
    hdr.update_list[2].setValid();
    hdr.update_list.next = 1;
    hdr.update_list[4].setValid();
    hdr.update_list.next = 0;
}

action enable_1_2_4() {
    hdr.update_list[0].setValid();
    hdr.update_list.next = 1;
    hdr.update_list[1].setValid();
    hdr.update_list.next = 1;
    hdr.update_list[3].setValid();
    hdr.update_list.next = 0;
}

action enable_1_2_4_5() {
    hdr.update_list[0].setValid();
    hdr.update_list.next = 1;
    hdr.update_list[1].setValid();
    hdr.update_list.next = 1;
    hdr.update_list[3].setValid();
    hdr.update_list.next = 1;
    hdr.update_list[4].setValid();
    hdr.update_list.next = 0;
}

action enable_1_2_5() {
    hdr.update_list[0].setValid();
    hdr.update_list.next = 1;
    hdr.update_list[1].setValid();
    hdr.update_list.next = 1;
    hdr.update_list[4].setValid();
    hdr.update_list.next = 0;
}

action enable_1_3() {
    hdr.update_list[0].setValid();
    hdr.update_list.next = 1;
    hdr.update_list[2].setValid();
    hdr.update_list.next = 0;
}

action enable_1_3_4() {
    hdr.update_list[0].setValid();
    hdr.update_list.next = 1;
    hdr.update_list[2].setValid();
    hdr.update_list.next = 1;
    hdr.update_list[3].setValid();
    hdr.update_list.next = 0;
}

action enable_1_3_4_5() {
    hdr.update_list[0].setValid();
    hdr.update_list.next = 1;
    hdr.update_list[2].setValid();
    hdr.update_list.next = 1;
    hdr.update_list[3].setValid();
    hdr.update_list.next = 1;
    hdr.update_list[4].setValid();
    hdr.update_list.next = 0;
}

action enable_1_3_5() {
    hdr.update_list[0].setValid();
    hdr.update_list.next = 1;
    hdr.update_list[2].setValid();
    hdr.update_list.next = 1;
    hdr.update_list[4].setValid();
    hdr.update_list.next = 0;
}

action enable_1_4() {
    hdr.update_list[0].setValid();
    hdr.update_list.next = 1;
    hdr.update_list[3].setValid();
    hdr.update_list.next = 0;
}

action enable_1_4_5() {
    hdr.update_list[0].setValid();
    hdr.update_list.next = 1;
    hdr.update_list[3].setValid();
    hdr.update_list.next = 1;
    hdr.update_list[4].setValid();
    hdr.update_list.next = 0;
}

action enable_1_5() {
    hdr.update_list[0].setValid();
    hdr.update_list.next = 1;
    hdr.update_list[4].setValid();
    hdr.update_list.next = 0;
}

action enable_2() {
    hdr.update_list[1].setValid();
    hdr.update_list.next = 0;
}

action enable_2_3() {
    hdr.update_list[1].setValid();
    hdr.update_list.next = 1;
    hdr.update_list[2].setValid();
    hdr.update_list.next = 0;
}

action enable_2_3_4() {
    hdr.update_list[1].setValid();
    hdr.update_list.next = 1;
    hdr.update_list[2].setValid();
    hdr.update_list.next = 1;
    hdr.update_list[3].setValid();
    hdr.update_list.next = 0;
}

action enable_2_3_4_5() {
    hdr.update_list[1].setValid();
    hdr.update_list.next = 1;
    hdr.update_list[2].setValid();
    hdr.update_list.next = 1;
    hdr.update_list[3].setValid();
    hdr.update_list.next = 1;
    hdr.update_list[4].setValid();
    hdr.update_list.next = 0;
}

action enable_2_3_5() {
    hdr.update_list[1].setValid();
    hdr.update_list.next = 1;
    hdr.update_list[2].setValid();
    hdr.update_list.next = 1;
    hdr.update_list[4].setValid();
    hdr.update_list.next = 0;
}

action enable_2_4() {
    hdr.update_list[1].setValid();
    hdr.update_list.next = 1;
    hdr.update_list[3].setValid();
    hdr.update_list.next = 0;
}

action enable_2_4_5() {
    hdr.update_list[1].setValid();
    hdr.update_list.next = 1;
    hdr.update_list[3].setValid();
    hdr.update_list.next = 1;
    hdr.update_list[4].setValid();
    hdr.update_list.next = 0;
}

action enable_2_5() {
    hdr.update_list[1].setValid();
    hdr.update_list.next = 1;
    hdr.update_list[4].setValid();
    hdr.update_list.next = 0;
}

action enable_3() {
    hdr.update_list[2].setValid();
    hdr.update_list.next = 0;
}

action enable_3_4() {
    hdr.update_list[2].setValid();
    hdr.update_list.next = 1;
    hdr.update_list[3].setValid();
    hdr.update_list.next = 0;
}

action enable_3_4_5() {
    hdr.update_list[2].setValid();
    hdr.update_list.next = 1;
    hdr.update_list[3].setValid();
    hdr.update_list.next = 1;
    hdr.update_list[4].setValid();
    hdr.update_list.next = 0;
}

action enable_3_5() {
    hdr.update_list[2].setValid();
    hdr.update_list.next = 1;
    hdr.update_list[4].setValid();
    hdr.update_list.next = 0;
}

action enable_4() {
    hdr.update_list[3].setValid();
    hdr.update_list.next = 0;
}

action enable_4_5() {
    hdr.update_list[3].setValid();
    hdr.update_list.next = 1;
    hdr.update_list[4].setValid();
    hdr.update_list.next = 0;
}

action enable_5() {
    hdr.update_list[4].setValid();
    hdr.update_list.next = 0;
}
table enable_updates {
    key = {
        dst_num: exact;
    }
    actions = {
        enable_1;
        enable_1_2;
        enable_1_2_3;
        enable_1_2_3_4;
        enable_1_2_3_4_5;
        enable_1_2_3_5;
        enable_1_2_4;
        enable_1_2_4_5;
        enable_1_2_5;
        enable_1_3;
        enable_1_3_4;
        enable_1_3_4_5;
        enable_1_3_5;
        enable_1_4;
        enable_1_4_5;
        enable_1_5;
        enable_2;
        enable_2_3;
        enable_2_3_4;
        enable_2_3_4_5;
        enable_2_3_5;
        enable_2_4;
        enable_2_4_5;
        enable_2_5;
        enable_3;
        enable_3_4;
        enable_3_4_5;
        enable_3_5;
        enable_4;
        enable_4_5;
        enable_5;
    }
    size = 31;
}

#endif