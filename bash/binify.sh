#!/bin/bash

if [ ! $# -eq 1 ]; then
    echo "Illegal number of parameters"
    exit
fi

save() {
    echo "saving file to $fname"
    cp $1 "$fname"
    chmod 775 "$fname"
}

# prompts the user whether or not they wish to execute some following command.
confirm() {
    # call with a prompt string or use a default
    read -r -p "${1:-Are you sure? [y/N]} " response
    case $response in
        [yY][eE][sS]|[yY]) 
            true
            ;;
        [Nn][Oo]|[Nn])
            false
            ;;
        *)
            false
            #need to create a way to loop back to the read statement.
            ;;
    esac
}

if [ -f $1 ]; then
    if [ ! -d ~/bin ]; then
        mkdir ~/bin
    fi
    fname=~/bin/`python -c "print '$1'.split('/')[-1].split('.')[0]"`
    if [ -f $fname ]; then
        echo "that script already exists..."
        confirm "Do you want to overwrite the file?" && save $1 $fname
        exit
    fi
    save $1 $fname
else
    echo "file does not exist..."
fi

