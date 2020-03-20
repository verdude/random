#!/usr/bin/env bash

eval $(keychain --eval --agents ssh id_rsa)

if [[ $# -gt 0 ]]; then
  $1
fi

