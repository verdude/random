#!/usr/bin/env bash

brightness=$(cat /sys/class/backlight/intel_backlight/brightness)

if [[ $brightness -gt 0 ]]; then
    let brightness=$brightness-10
    if [[ $brightness -lt 5 ]]; then
        brightness=5
    fi
    echo $brightness | sudo tee /sys/class/backlight/intel_backlight/brightness
fi

