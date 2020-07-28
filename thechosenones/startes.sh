#!/usr/bin/env bash

exc=$HOME/elasticsearch-7.7.1/bin/elasticsearch
pid=$HOME/.es.pid

if [[ -f "$exc" ]]; then
  rm -f "$pid"
  $exc -p "$pid"
else
  echo "$exc" not found.
  exit 1
fi

