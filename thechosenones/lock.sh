#!/bin/bash
scrot /tmp/screen.png
convert /tmp/screen.png -scale 4% -scale 2500% /tmp/screen.png
[[ -f $1 ]] && convert /tmp/screen.png $1 -gravity center -composite -matte /tmp/screen.png
i3lock -i /tmp/screen.png
rm /tmp/screen.png
