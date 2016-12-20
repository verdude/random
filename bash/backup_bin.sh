#!/bin/bash

cd ~
if [[ -d bin ]]; then
    if [[ ! -d docs ]]; then
        printf "Making docs directory..."
        mkdir docs
    fi
    cp -r bin docs/bin
fi
