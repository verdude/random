#!/bin/bash

cd $GITDIR/random
rel=$(echo ~/bin/)

for file in $(ls thechosenones); do
    ln -s $(readlink -e "thechosenones/file") "$rel"
done

