#!/usr/bin/env bash

cd ~
mkdir -p Documents/Docker/ && cd Documents/Docker
git clone https://github.com/dro248/ayamelDBDockerfile
git clone https://github.com/dro248/AyamelDockerfile
git clone https://github.com/dro248/runAyamel

scp arclite@sartre4.byu.edu:~/application.conf ./AyamelDockerfile

sudo service mysql stop

cd runAyamel
sudo docker-compose up


