#!/bin/bash

sudo apt-get install -y --no-install-recommends apt-transport-https ca-certificates curl software-properties-common

if [[ -z $(lsb_release -r | grep "17") ]]; then

    curl -silent -fsSL https://apt.dockerproject.org/gpg | sudo apt-key add -
    has=$(apt-key fingerprint 58118E89F3A912897C070ADBF76221572C52609D)

    if [[ -z $has ]]; then
        echo "Error adding key. exiting"
        exit 1
    fi

    sudo add-apt-repository "deb https://apt.dockerproject.org/repo/ ubuntu-$(lsb_release -cs) main"

    sudo apt update >/dev/null 2>&1
    sudo apt -y install docker-engine

else
    curl -silent -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    has=$(sudo apt-key fingerprint 0EBFCD88)

    if [[ -z $has ]]; then
        echo "Error adding key. exiting"
        exit 1
    fi

    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu zesty stable"

    sudo apt-get update
    sudo apt-get install docker-ce
fi

# DOCKER COMPoSE
sudo curl -L "https://github.com/docker/compose/releases/download/1.13.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
echo "Docker is done"

