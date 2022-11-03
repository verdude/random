#!/bin/bash

set -xeuo pipefail

cn=""
msg=""
cache=""

while getopts :hm:c: flag
do
  case "${flag}" in
    c) cn="${OPTARG}";;
    m) msg="${OPTARG}";;
    h) cache="yeah";;
    :) echo "Argument required for option: -${OPTARG}"; exit 1;;
    ?) echo "Bad argument: -${OPTARG}"; exit 1;;
  esac
done

if [[ -z "$cn" ]]; then
  echo "missing -c arg"
  exit 1
fi

CACHE="/tmp/${cn}-checker.log"

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
