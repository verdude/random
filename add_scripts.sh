#!/bin/bash

if [[ ! -d ~/bin ]]; then
    mkdir ~/bin
fi

rel=$(echo ~/bin/)

for file in $(ls $GITDIR/random/thechosenones); do
    fname=$(python -c "print '$file'.split('/')[-1].split('.')[0]")
    ln -s $(readlink -e "$GITDIR/random/thechosenones/$file") "$rel$fname"
done

