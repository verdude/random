#!/usr/bin/env bash

set -euo pipefail

groups=""
block=""
username=""

if [[ $UID -eq 0 ]]; then
  echo "no sudo pls"
  exit 1
fi

function create_user() {
  if [[ -z "$username" ]]; then
    echo "-u username # required"
    return 1
  fi

  if id -u $username &>/dev/null; then
    echo User $username already exists.
    return 1
  fi

  echo "Creating user: $username"
  sudo useradd -m $username
  echo "Set $username password"
  sudo passwd $username
  echo "Change shell for $username"
  sudo chsh -s $(which bash) $username
  sudo mkdir /home/$username/.ssh

  if [[ -f ~/.ssh/authorized_keys ]]; then
    sudo cp ~/.ssh/authorized_keys /home/$username/.ssh
  fi

  sudo chown -R $username:$username /home/$username/.ssh
}

function block_user() {
  if ! id -u $username &>/dev/null; then
    echo "User $username does not exist, cannot add groups."
    return 1
  fi
  echo "Disabling $(whoami)"
  sudo chsh -s $(which false) $(whoami)
  # TODO: block in ssh
}

function add_groups() {
  if ! id -u $username &>/dev/null; then
    echo "User $username does not exist, cannot add groups."
    return 1
  fi
  sudo usermod -aG $groups $username
}

while getopts g:u:x flag
do
  case ${flag} in
    u) username="${OPTARG}";;
    g) groups="${OPTARG}";;
    x) block=true;;
  esac
done

create_user
block_user
add_groups
