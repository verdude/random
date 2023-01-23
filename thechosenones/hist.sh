#!/usr/bin/env bash

set -eo pipefail

cc=$(git rev-parse HEAD)
stringsearch=""
index=0
size=0
tempfile=""
hashes=()

while getopts :xS:c: flag
do
  case ${flag} in
    S) stringsearch="-S ${OPTARG}";;
    c) cc=${OPTARG};;
    x) set -x;;
    :) echo ${OPTARG} requires a param; exit 1;;
  esac
done

shift $((OPTIND - 1))
args="$*"

function get_hashes() {
  if [[ -n "$args$stringsearch$cc" ]]; then
    hashes=($(git log $cc $stringsearch --pretty=format:"%h" -- $args))
    size=${#hashes[@]}
    cc=${hashes[$index]}
    echo $hashes
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
  logline="$(git show --oneline --pretty=format:"%h-%f-%al" --no-patch $cc)"
  tempfile="$(mktemp XXXXXX-${logline}.tmp)"
  git diff --color=always $cc^ $cc -- $args 2>/dev/null > "$tempfile"
  if [[ $? -eq 128 ]]; then
    echo
    echo "Bad Revision! ['$cc^' '$cc']"
    echo "bye."
    exit 1
  fi
  less -frc "$tempfile"
  rm "$tempfile"
  echo "$logline"
  next
}

get_hashes

while
  log
  [[ -z "$cc" ]] && exit
  read -rn 1 -i n -p "continue? (Y/q): " resp

  if [[ "$resp" == "q" ]]; then
    echo
    echo good day.
    break
  else
    echo
  fi
do :; done
