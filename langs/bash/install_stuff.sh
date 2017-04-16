#!/bin/bash

peda () {
    mkdir -p ~/github && cd github
    git clone https://github.com/longld/peda
    echo "source ~/github/peda/peda.py" >> ~/.gdbinit
}

peda

