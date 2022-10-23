#!/usr/bin/env bash

files=$(ls -1 /tmp/*.swp 2> /dev/null)
if [[ -n $files ]]; then
    echo "Going to delete:"
    echo $files
    rm -f /tmp/*.swp
else
    echo "...I'm bored..."
fi

