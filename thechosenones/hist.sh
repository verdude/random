#!/usr/bin/env bash

set -e

cc=$(git rev-parse HEAD)
index=0
size=0
tempfile=""
hashes=()

while getopts :xc: flag
do
  case ${flag} in
    c) cc=${OPTARG};;
    x) set -x;;
    :) echo ${OPTARG} requires a param; exit 1;;
  esac
done

shift $((OPTIND - 1))
args="$*"

function get_hashes() {
  if [[ -n "$args" ]]; then
    hashes=($(git log $cc --pretty=format:"%h" -- $args))
    size=${#hashes[@]}
    cc=${hashes[$index]}
  fi
}

function next() {
  if [[ $index -lt $size ]]; then
    cc=${hashes[0]}
  else
    cc=$(git rev-parse $cc^)
  fi

  if [[ $index -lt $size ]]; then
    index=$(($index + 1))
    cc=${hashes[$index]}
  elif [[ $size -ne 0 ]]; then
    echo "finished."
    exit
  fi
}

function log() {
  git diff $cc^ $cc -- $args 2>/dev/null
  if [[ $? -eq 128 ]]; then
    echo "Bad Revision! ['$cc^' '$cc']"
    echo "bye."
    exit 1
  fi
  git show --oneline --pretty=format:"%h %f %al" --no-patch $cc
  next
}

get_hashes

while
  log
  read -rn 1 -i n -p "continue? (Y/q): " resp

  if [[ "$resp" == "q" ]]; then
    echo
    echo good day.
    break
  fi
do :; done
