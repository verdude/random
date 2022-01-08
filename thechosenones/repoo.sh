#!/usr/bin/env bash

eval $(keychain --eval --agents ssh id_ed25519)

if [[ $# -gt 0 ]]; then
  $@
fi

