#!/bin/bash

if [[ ! -d ~/docs/11b ]]; then
    mkdir -p ~/docs/11b
fi
filename=~/docs/11b/$(date +%m%d_%H-%M.html)
curl -sSL https://efy.byu.edu/efy_session/10087614 | grep "<" > $filename

isFull=$(grep '<p class="center"><a href="#" disabled="disabled" title="Full" class="button btn btn-closed">Full</a></p>' $filename)
if [[ -z $isFull ]]; then
    ~/bin/send_text -m "11b EFY is not full anymore. $filename"
    ~/bin/send_email -m"https://efy.byu.edu/efy_session/10087614 $filename" -s"11b open" -t"santiago.verdu.01@gmail.com"
else
    echo "STILL FULL" >> $filename
fi

