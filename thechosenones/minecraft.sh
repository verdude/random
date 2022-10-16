#!/usr/bin/env bash

set -eu

sudo apt update
sudo apt install openjdk-16-jdk-headless
curl -O https://piston-data.mojang.com/v1/objects/f69c284232d7c7580bd89a5a4931c3581eae1378/server.jar
java -Xmx1024M -Xms1024M -jar minecraft_server.1.19.2.jar nogui

