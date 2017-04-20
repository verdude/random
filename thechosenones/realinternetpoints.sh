#!/bin/bash

pushd ~/git/pyminer/

jsonout=$(./miner.py -a ~/.bingrc -j)

/home/dockeruser/bin/send_text -m "m1n3r 0u7pu7: $jsonout"

popd

