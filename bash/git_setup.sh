#!/bin/bash

got_got=`which git`
if [ -z $got_git ]; then
    echo "git is not installed"
    exit 1
fi

generate() {
    # generates keys for github
    echo "Make sure to name the key pair 'id_rsa'"
    ssh-keygen -t rsa -b 4096 -C "santiago.verdu.01@gmail.com"
    eval "$(ssh-agent -s)"
    confirm "Did the ssh-agent run?" && ssh-add ~/.ssh/id_rsa
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

git config --global user.name "Santiago Verdu"
git config --global user.email "santiago.verdu.01@gmail.com"
git config --global alias.slog "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
confirm "Generate Keys?" && generate
got_xclip=`which xclip`
if [[ -z $got_xclip ]]; then
    echo "Downloading xclip"
    sudo apt-get install xclip
fi
xclip -sel clip < ~/.ssh/id_rsa.pub
echo "Now add the key to github. (It's in the paste buffer)"
