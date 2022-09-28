#!/usr/bin/env bash

set -euo pipefail

if [[ $UID -eq 0 ]]; then
  echo "no sudo pls"
  exit 1
fi

username=""
block_current_user=""

while getopts u:x flag
do
  case ${flag} in
    u) username=${OPTARG};;
    x) block_current_user="true";;
  esac
done

if [[ -z "$username" ]]; then
  echo "-u username # required"
  exit 1
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

if [[ -n "$block_current_user" ]]; then
  sudo chsh -s /usr/bin/false $(whoami)
  # TODO: block in ssh
fi
