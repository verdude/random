#!/bin/bash

environment=""

for file in $(ls); do
   if [[ -d "$file" ]]; then
       cd "$file"
       if [[ -f "pip-selfcheck.json" ]] && [[ -d bin ]]; then
            environment="$file"
            cd ..
       else
           cd ..
       fi
   fi
done

if [[ -z "$environment" ]]; then
    echo "creating virtual environment"
    virtualenv -p python3 env
    environment="env"
fi

. "$environment/bin/activate"

# make script check if there is a requirements file and 
# and then load it in
req=$(ls -1 req*.txt)
if [[ -n $req ]]; then
    pip install -r $req
fi

