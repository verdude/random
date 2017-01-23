#!/usr/bin/env python

import argparse

class patroller():
    def __init__(self,ip_range):
        self.single = self.check_ip(ip_range)
        if (self.single):
            self.ip = ip_range
            self.cmd = "sudo nmap -sn -PS443 %s" % self.ip
        else:
            self.ip_range = ip_range
            self.cmd = "sudo nmap -sn -PS443 %s" % self.ip_range

    def check_ip(self, ip):
        slash_index = ip.find("/")
        if slash_index >= 0:
            ip = ip[:slash_index]
        segs = ip.split(".")
        for seg in segs:
            try:
                if int(seg) > 255 or int(seg) < 0:
                    return False
            except:
                return False
        return True

    def patrol(self):
        process = subprocess.Popen(cmd.split(), stdout=subprocess.PIPE)
        output, error = process.communicate()
