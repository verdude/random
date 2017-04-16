#!/usr/bin/env python

import os, re
cmd = os.popen("nmcli -t --fields name c show --active")
output = cmd.read()
ap = re.sub("docker\S*", "", output).strip().replace("\n", " ")

if ap == "":
    ap = "Not Associated"
    color = "#FF0000"
else:
    color = "#00FF00"

print ap
print ap
print color

