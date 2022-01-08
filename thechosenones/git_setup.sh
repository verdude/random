#!/bin/bash

got_git=$(which git)
if [ -z $got_git ]; then
    echo "git is not installed"
    exit 1
fi

generate() {
    # generates ssh keys
    echo "Make sure to name the key pair 'id_rsa'"
    ssh-keygen -t ed25519 -C $EMAIL
    ssh_agent=`eval "$(ssh-agent -s)"`
    if [[ ! -z ssh_agent ]]; then
        ssh-add ~/.ssh/id_rsa
        echo "Adding id_rsa to ssh-agent"
    else
        echo "ssh_agent not found"
    fi
    got_xclip=`which xclip`
    if [[ -z $got_xclip ]]; then
        echo "Downloading xclip"
        sudo apt-get install xclip
    fi
    cat ~/.ssh/id_rsa.pub | xclip -sel clip
    echo "Now add the key to github. (It's in the paste buffer)"
}

confirm() {
    read -r -p "$1" response
    case $response in
        [yY][eE][sS]|[yY])
            return 0
            ;;
        [Nn][Oo]|[Nn])
            return 1
            ;;
        *)
            return 1
            ;;
    esac
}

echo $NAME $EMAIL
if [[ -z "$NAME" ]] || [[ -z "$EMAIL" ]]; then
    echo 'Need $NAME and $EMAIL'
    exit 1
fi
git config --global user.name "$NAME"
git config --global user.email "$EMAIL"
git config --global alias.slog "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
git config --global push.default simple

if confirm "Generate keys? [y/N]"; then
    generate
fi

