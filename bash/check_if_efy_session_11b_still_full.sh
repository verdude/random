#!/bin/bash

filename=~/docs/11b/$(date +%D_%H:%M.html)
curl -sSL https://efy.byu.edu/efy_session/10087614 | grep -v "<" > $filename

element='<p class="center"><a href="#" disabled="disabled" title="Full" class="button btn btn-closed">Full</a></p>'
isFull=$(grep $element $filename)
if [[ -z $isFull ]]; then
    ~/bin/send_text -m "11b EFY is not full anymore."
    ~/bin/send_email -m"https://efy.byu.edu/efy_session/10087614 $filename" -s"11b open" -t"santiago.verdu.01@gmail.com"
else
    echo "STILL FULL" >> $filename
fi

