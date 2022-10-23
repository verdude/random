#!/usr/bin/env bash

haves_tilda=$(which tilda)
if [[ -z haves_tilda ]]; then
    echo "install tilda"
    exit 1
fi
tilda & tilda & tilda & tilda &

