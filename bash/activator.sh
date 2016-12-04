#!/bin/bash

if [ -d ~/activator ]; then
    ~/activator/bin/activator $@
else
    cd ~
    wget https://downloads.typesafe.com/typesafe-activator/1.3.12/typesafe-activator-1.3.12.zip
    unzip typesafe-activator-1.3.12.zip
    mv typesafe-activator-1.3.12.zip activator
fi

