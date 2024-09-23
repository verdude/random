#!/usr/bin/env bash

set -ex

fn=/tmp/tmp.png
ssh-add -D
secret-tool lock
scrot "$fn"
convert "$fn" -blur 0x8 "$fn"
i3lock -i "$fn"
rm -f "${fn}"
