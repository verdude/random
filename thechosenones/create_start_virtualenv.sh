#!/bin/bash

environment=""

for file in $(ls); do
   if [ -d "$file" ]; then
       cd "$file"
       if [ -f "pip-selfcheck.json" ] && [ -d bin ]; then
            cd ..
            environment="$file"
       else
           cd ..
       fi
   fi
done

if [ -n "$environment" ]; then
    virtualenv env
fi

. "$environment/bin/activate"

# make script check if there is a requirements file and 
# and then load it in
req=`ls -1 req*.txt`
if [ ! -z $req ]; then
    pip install -r $req
fi

