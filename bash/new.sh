#!/bin/bash

got_got=`which git`
if [ -z $got_git ]; then
    echo "git is not installed"
elif
    git config --global alias.slog "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
fi

