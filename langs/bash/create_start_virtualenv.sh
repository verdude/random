#!/bin/bash

if [ ! -d env ]; then
    virtualenv env
fi

. env/bin/activate

# make script check if there is a requirements file and 
# and then load it in
req=`ls -1 req*.txt`
if [ ! -z $req ]; then
    pip install -r $req
fi
