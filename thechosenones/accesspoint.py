#!/usr/bin/env python3

import os, re
cmd = os.popen("ip -o a | grep wlan0 | awk '{print $4}'")
output = cmd.read()
ap = re.sub("docker\S*", "", output).strip().replace("\n", " ")

if ap == "":
    ap = "Not Associated"
    color = "#FF0000"
else:
    color = "#00FF00"

print(ap)
print(ap)
print(color)

