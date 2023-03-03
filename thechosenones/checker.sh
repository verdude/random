#!/bin/bash

set -euo pipefail

cn=""
exe=""
msg=""
cache=""
configarg=""

while getopts :hf:m:c:e: flag
do
  case "${flag}" in
    c) cn="${OPTARG}";;
    e) exe="${OPTARG}";;
    m) msg="${OPTARG}";;
    h) cache="yeah";;
    f) configarg="-c ${OPTARG}";;
    :) echo "Argument required for option: -${OPTARG}"; exit 1;;
    ?) echo "Bad argument: -${OPTARG}"; exit 1;;
  esac
done

if [[ -z $cn ]]; then
  echo "missing -c arg"
  exit 1
fi

if [[ -z $exe ]]; then
  echo "missing -e arg"
  exit 1
fi

CACHE="/tmp/${cn}-checker.log"

if [[ -n "$cache" ]] && [[ -f "$CACHE" ]]; then
  exit 0
fi

out="$($exe | grep "${cn}")"

if [[ -n $out ]]; then
  echo 1 > $CACHE
  send_text -m "${msg:-$0}" ${configarg}
elif [[ -f $CACHE ]]; then
  rm $CACHE
fi
