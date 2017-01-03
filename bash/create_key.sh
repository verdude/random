#!/bin/bash

echo "Use the default for the name"
ssh-keygen -t rsa -b 4096 -C "santiago.verdu.01@gmail.com"
ssh_agent=`eval "$(ssh-agent -s)"`
if [[ ! -z ssh_agent ]]; then
    ssd-add ~/.ssh/id_rsa
    echo "Adding id_rsa to ssh-agent"
else
    echo "ssh_agent not found"
fi

