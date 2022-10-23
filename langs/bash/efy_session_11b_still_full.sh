#!/usr/bin/env bash

filename=/tmp/efy_$(date +%m%d_%H-%M.html)
curl -sSL https://efy.byu.edu/efy_session/10087614 | grep "<" > $filename

isFull=$(grep '<p class="center"><a href="#" disabled="disabled" title="Full" class="button btn btn-closed">Full</a></p>' $filename)
if [[ $(stat -c %s $filename) -eq 0 ]]; then
    rm $filename
    exit 1
fi
if [[ -z $isFull ]]; then
    echo "https://efy.byu.edu/efy_session/10087614" >> "$filename"
    ~/bin/send_text -m "11b EFY is not full anymore. $filename"
    ~/bin/send_email -f"$filename" -s"11b open: $filename" -t"santiago.verdu.01@gmail.com"
    ~/bin/send_email -m"https://efy.byu.edu/efy_session/10087614" -s"EFY session 11b has open spots" -t"mudrev@gmail.com"
else
    rm $filename
fi

