#!/bin/bash

gotgot=`which git`
if [[ -z $gotgit ]]; then
    echo "$USER"
    echo "$gotgit"
    echo "git is not installed"
else
    git config --global alias.slog "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
fi

