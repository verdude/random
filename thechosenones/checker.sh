#!/bin/bash

set -euo pipefail

cn=""
msg=""
cache=""
CACHE="/tmp/checker.log"

while getopts :hmc: flag
do
  case "${flag}" in
    c) cn="${OPTARG}";;
    m) msg="${OPTARG}";;
    h) cache="yeah"
    :) echo "Argument required for option: -${OPTARG}"; exit 1;;
    ?) echo "Bad argument: -${OPTARG}"; exit 1;;
  esac
done

if [[ -z "$cn" ]]; then
  echo "missing -c arg"
  exit 1
fi

if [[ -n "$cache" ]] && [[ -f "$CACHE" ]]; then
  exit 0
fi

out="$(tcli | grep "${cn}")"

if [[ -n "$out" ]]; then
  echo 1 > $CACHE
  send_text -m "${msg:-$0}"
elif [[ -f $CACHE ]]; then
  rm $CACHE
fi
