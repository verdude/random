#!/usr/bin/env bash

sudo ifconfig $1 down
sudo macchanger -r $1
sudo ifconfig $1 up

