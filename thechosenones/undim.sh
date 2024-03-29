#!/usr/bin/env bash

max_brightness=$(cat /sys/class/backlight/intel_backlight/max_brightness)
brightness=$(cat /sys/class/backlight/intel_backlight/brightness)

if [[ $brightness -lt $max_brightness ]]; then
    let brightness=$brightness+100
    if [[ $brightness -gt $max_brightness ]]; then
        brightness=$max_brightness
    fi
    echo $brightness | sudo tee /sys/class/backlight/intel_backlight/brightness
fi

