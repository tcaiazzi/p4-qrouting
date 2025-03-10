#!/usr/bin/env python
import argparse
import sys
import random
import struct

from scapy.all import sendp, get_if_hwaddr
from scapy.all import Ether, IP, UDP, TCP

def main():
    if len(sys.argv) != 2:
        print('pass 2 arguments: <destination>')
        exit(1)

    addr = sys.argv[1]
    iface = "eth0"

    print("sending on interface %s to %s" % (iface, str(addr)))

    pkt = Ether(src=get_if_hwaddr(iface), dst='00:00:00:01:01:00')
    pkt = pkt /IP(dst=addr) / UDP(dport=random.randint(5000,60000), sport=random.randint(49152,65535))
    sendp(pkt, iface=iface, verbose=True)

if __name__ == '__main__':
    main()