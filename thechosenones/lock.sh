#!/bin/bash

set -e

f=/tmp/screen.png
if [[ -n "$(which shred)" ]]; then
    shred -uz $f 2>/dev/null
else
    rm -f $f
fi
[[ -n "$(which scrot)" ]] && scrot $f && convert $f -scale 4% -scale 2500% $f
[[ -f $1 ]] && convert $f $1 -gravity center -composite -matte $f
if [[ -f $f ]]; then
    img="-i $f"
else
    img="-c 000000"
fi
i3lock $img
