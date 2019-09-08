#!/usr/bin/env bash

LOGFILE=${1:-~/.waitlist.log}
initline=""

log () {
    [[ -z $initline ]] && echo >> $LOGFILE
    initline="initialized"
    echo $1 >> $LOGFILE
}

IFS=
html=$(curl -s 'https://replace')
if [ $? -ne 0 ]; then
    log $html
    log "Failed to get response."
    send_text -m "failed to get response"
    exit 1
fi

class=$(echo $html | grep -B 11 "Arts, Michael A T M")
if [ $? -ne 0 ]; then
    log $html
    log "Class not found."
    send_text -m "Class was not found"
    exit 1
fi

line=$(echo $class | head -1)
spots=$(echo $line | tr -dc '0-9')

if [ $spots -ne 0 ]; then
    log "$spots spot(s) available."
    send_text -m "$spots are available"
fi

printf "." >> $LOGFILE
