#!/usr/bin/env bash

set -eEuo pipefail

seconds=$(($1*60))
message="Time's up"

while getopts :m: FLAG; do
  case $FLAG in
    m) message=$OPTARG ;;
    :) echo "${OPTARG} requires a param"; exit 1 ;;
    ?) echo "Unkown  argument -${OPTARG}"; exit 1 ;;
  esac
done

echo "sleeping for $seconds seconds (${1}m)"
sleep $seconds
notify-send -u critical "$message"
