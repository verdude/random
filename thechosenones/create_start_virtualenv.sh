#!/bin/bash

environment=""

# find the environment
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
    python3 -m venv env
    environment="env"
fi

. "$environment/bin/activate"

# make script check if there is a requirements file and 
# and then load it in
req=$(ls -1 req*.txt 2>/dev/null)
if [[ -n $req ]]; then
    pip install -r $req
else
    echo "Brother, I regret to inform you that a requirements file has not been found."
    echo "While this may come as a shock to you, it is most likely that it is not."
fi

