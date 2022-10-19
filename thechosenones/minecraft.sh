#!/usr/bin/env bash

set -eu

sudo apt update
sudo apt install openjdk-18-jdk-headless
mkdir -p mc
cd mc
echo eula=true > eula.txt
curl -O https://piston-data.mojang.com/v1/objects/f69c284232d7c7580bd89a5a4931c3581eae1378/server.jar
java -Xmx1024M -Xms1024M -jar server.jar nogui
