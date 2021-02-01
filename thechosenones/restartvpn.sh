#!/bin/bash
expressvpn disconnect
sudo systemctl restart expressvpn
expressvpn connect
