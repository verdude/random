#! /usr/bin/python

from scapy.all import *
from random import randint
import os
directory = '/usr/lib/portalSounds'

def main():
    print "Sniffing for ARP Probes..."
    while True:
        sniff(prn=arp_display, filter="arp", store=0, count=2)
    print "Stopped sniffing for ARP Probes."

def arp_display(pkt):
    print str(pkt)
    #if pkt[ARP].op == 1 and str(pkt[ARP].hwsrc) == '74:c2:46:1d:4a:11':
        #print "Button clicked."
        #os.system('cvlc ' + os.path.join(directory, random.choice(os.listdir(directory))) + ' --play-and-exit')
        #print "Message sent."

try:
    main()
except KeyboardInterrupt:
    print "Caught C- c. Exiting"

