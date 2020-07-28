#!/usr/bin/env bash

pid=$HOME/.es.pid

if [[ -f "$pid" ]]; then
  kill $(cat "$pid")
else
  echo "ES is not running..."
  exit 1
fi

