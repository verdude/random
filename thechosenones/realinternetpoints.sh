#!/usr/bin/env bash

pushd ~/git/pyminer/

jsonout=$(./miner.py -a ~/.bingrc -j)

~/bin/send_text -m "m1n3r 0u7pu7: $jsonout"

popd

