#!/bin/bash

sudo apt-get install -y --no-install-recommends apt-transport-https ca-certificates curl software-properties-common

curl -silent -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
has=$(sudo apt-key fingerprint 0EBFCD88)

if [[ -z $has ]]; then
    echo "Error adding key. exiting"
    exit 1
fi

sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu zesty stable"

sudo apt-get update
sudo apt-get install docker-ce

# DOCKER COMPoSE
sudo curl -L "https://github.com/docker/compose/releases/download/1.13.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
echo "Docker is done"

