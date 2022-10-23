#!/usr/bin/env bash

set -e

f=/home/erra/git/dropper_api/cloudapp.png
if [[ -f $f ]]; then
    img="-f -t -c 000000 -i $f"
else
    img="-f -c 000000"
fi
i3lock $img
