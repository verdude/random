#!/usr/bin/env bash

set -eEuo pipefail

got_git=$(which git)
if [ -z $got_git ]; then
    echo "git is not installed"
    exit 1
fi

function generate() {
    ssh-keygen -t ed25519 -C $EMAIL
    ssh_agent=`eval "$(ssh-agent -s)"`
    if [[ ! -z ssh_agent ]]; then
        ssh-add ~/.ssh/id_ed25519
        echo "Adding id_ed25519 to ssh-agent"
    else
        echo "ssh_agent not found"
    fi
    got_xclip=`which xclip`
    if [[ -z $got_xclip ]]; then
        echo "Downloading xclip"
        sudo apt-get install xclip || sudo pacman -S xclip
    fi
    cat ~/.ssh/id_ed25519.pub | xclip -sel clip
    echo "Now add the key to github. (It's in the paste buffer)"
}

function confirm() {
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

function gitconfig() {
  if [[ -z "$NAME" ]] || [[ -z "$EMAIL" ]]; then
    git config --global user.name "$NAME"
    git config --global user.email "$EMAIL"
  else
    echo 'Need $EMAIL/$NAME to generate keys'
    echo "skipping name/email config"
  fi

  git config --global alias.slog "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
  git config --global push.default simple

  gclpath=/usr/lib/git-core/git-credential-libsecret
  if [[ -f $gclpath ]]; then
    git config --global credential.helper "$gclpath"
  else
    echo "skipping libsecret credential helper config"
  fi
}

gitconfig

if confirm "Generate keys? [y/N]"; then
    if [[ -z "$EMAIL" ]]; then
        echo 'Need $EMAIL to generate keys'
        exit 1
    fi
    generate
fi
