#!/bin/bash

iwconfig 2>/dev/null | python -c 'import sys;l=sys.stdin.read().split("\n");i=[s.split()[0] for s in l if s.startswith("wlx")];print i[0] if len(i) > 0 else ""'

