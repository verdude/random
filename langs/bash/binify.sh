#!/bin/bash

if [[ $# -gt 3 ]] || [[ $# -le 0 ]]; then
    echo "Illegal number of parameters"
    exit
fi

noconfirm=$([[ "$3" = "--yes" ]] || [[ "$2" = "--yes" ]] && echo true)

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
            ;;
    esac
}

localrun() {
    fname=/usr/local/bin/$(python -c "print '$1'.split('/')[-1].split('.')[0]")
    if [ -f $fname ]; then
        if [[ -n $noconfirm ]]; then
            echo "no confirm set."
            save $1 $fname
        else
            echo "that script already exists..."
            confirm "Do you want to overwrite the file?" && save $1 $fname
        fi
        exit
    else
        save $1 $fname
    fi
}

run() {
    if [[ ! -d ~/bin ]]; then
        mkdir ~/bin
    fi
    path=`echo $PATH | grep "/home/$USER/bin"`
    if [ -z path ]; then
        echo 'export PATH=$PATH:~/bin' >> ~/.bashrc
        source ~/.bashrc
    fi

    fname=~/bin/$(python -c "print '$1'.split('/')[-1].split('.')[0]")
    if [ -f $fname ]; then
        if [[ -n $noconfirm ]]; then
            echo "no confirm set."
            save $1 $fname
        else
            echo "that script already exists..."
            confirm "Do you want to overwrite the file?" && save $1 $fname
        fi
        exit
    else
        save $1 $fname
    fi
}

if [[ $1 == "--local" ]] || [[ $1 == "-l" ]]; then
    if [[ $UID -eq 0 ]]; then
        if [[ -f $2 ]]; then
            localrun $2
        else
            echo "file does not exist"
        fi
    else
        echo "need root to save in /usr/local/bin"
    fi
elif [[ -f $1 ]]; then
    if [[ $UID -ne 0 ]]; then
        run $1
    else
        echo "dont use root to save in ~/bin"
    fi
else
    echo "file does not exist..."
fi

