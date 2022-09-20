#!/usr/bin/env bash

cc=$(git rev-parse HEAD)
args=$@

function next() {
    cc=$(git rev-parse $cc^)
}

function log() {
    git diff $cc^ $cc -- $args
    next
}

while
  log
  read -rn 1 -i n -p "continue? (Y/n): " resp

  if [[ "$resp" == "n" ]]; then
    echo
    echo good day.
    break
  fi
do :; done
