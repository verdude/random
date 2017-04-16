#!/bin/bash

if [[ ! -d ~/bin ]]; then
    mkdir ~/bin
fi

rel=$(echo ~/bin/)

for file in $(ls thechosenones); do
    fname=$(python -c "print '$file'.split('/')[-1].split('.')[0]")
    ln -s $(readlink -e "thechosenones/$file") "$rel$fname"
done

