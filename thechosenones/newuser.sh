#!/usr/bin/env bash

set -euo pipefail

if [ $UID -eq 0 ]; then
  echo "no sudo pls"
  exit 1
fi

username=""

while getopts u: flag
do
  case ${flag} in
    u) username=${OPTARG};;
  esac
done

if [ -z "$username" ]; then
  echo "-u username # required"
  exit 1
fi

sudo useradd -m $username
sudo passwd $username
sudo mkdir /home/$username/.ssh
sudo chsh -s /bin/bash $username

if [ -f ~/.ssh/authorized_keys ]; then
  sudo cp ~/.ssh/authorized_keys /home/$username/.ssh
fi

sudo chown -R $username:$username /home/$username/.ssh
