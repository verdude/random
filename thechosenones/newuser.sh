#!/usr/bin/env bash

set -euo pipefail

if [[ $UID -eq 0 ]]; then
  echo "no sudo pls"
  exit 1
fi

function create_user() {
  username="$1"

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
  sudo chsh -s /bin/bash $username
  sudo mkdir /home/$username/.ssh

  if [[ -f ~/.ssh/authorized_keys ]]; then
    sudo cp ~/.ssh/authorized_keys /home/$username/.ssh
  fi

  sudo chown -R $username:$username /home/$username/.ssh
}

function block_user() {
  sudo chsh -s /usr/bin/false $(whoami)
  # TODO: block in ssh
}

while getopts u:x flag
do
  case ${flag} in
    u) create_user ${OPTARG};;
    x) block_user;;
  esac
done
