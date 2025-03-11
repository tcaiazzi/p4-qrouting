#!/usr/bin/env python
import argparse
import sys
import random
import struct

from scapy.all import *

def main():
    if len(sys.argv) != 3:
        print('Usage: send.py <mac> <ip>')
        exit(1)

    mac_addr = sys.argv[1]
    ip_addr = sys.argv[2]
    iface = "eth0"

    print(f"sending on interface {iface} to mac={mac_addr} ip={ip_addr}")

    pkt = Ether(src=get_if_hwaddr(iface), dst=mac_addr)
    pkt = pkt / IP(dst=ip_addr, ttl=255) / ICMP()
    sendp(pkt, iface=iface, verbose=True)

if __name__ == '__main__':
    main()
