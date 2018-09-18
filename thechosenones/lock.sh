#!/bin/bash

set -e

[[ -n "$(which scrot)" ]] && scrot /tmp/screen.png && convert /tmp/screen.png -scale 4% -scale 2500% /tmp/screen.png
[[ -f $1 ]] && convert /tmp/screen.png $1 -gravity center -composite -matte /tmp/screen.png
if [[ -f /tmp/screen.png ]]; then
    img="-i /tmp/screen.png"
else
    img="-c 000000"
fi
i3lock $img
