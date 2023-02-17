#!/usr/bin/env bash

set -euo pipefail

cc=$(git rev-parse HEAD)
stringsearch=""
quiet=""
useless="yeah"
diffargs=()
index=0
size=0
tempfile=""
hashes=()

while getopts :xltnqS:c: flag
do
  case ${flag} in
    S) stringsearch="-S ${OPTARG}";;
    c) cc=${OPTARG};;
    x) set -x;;
    t) diffargs=(--compact-summary);;
    l) diffargs=(--name-only);;
    n) useless="";;
    q) quiet="yeah";;
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
  local logline
  local output

  logline="$(git show --oneline --pretty=format:"%h-%f-%al" --no-patch $cc)"
  if [[ -n ${useless} ]]; then
    tempfile="$(mktemp /tmp/${logline}-XXX.tmp)"
    output=("--output=${tempfile}")
  else
    output=()
  fi

  git diff "${output[@]}" "${diffargs[@]}" --color=always $cc^ $cc -- $args 2>/dev/null

  if [[ $? -eq 128 ]]; then
    echo
    echo "Bad Revision! ['$cc^' '$cc']"
    echo "bye."
    exit 1
  fi

  if [[ -n ${useless} ]]; then
    less -frc "$tempfile"
  fi

  rm -f "${tempfile}"

  if [[ -z ${quiet} ]]; then
    echo "$logline"
  fi

  next
}

function rm_tempfile() {
  rm -f "${tempfile}"
}
trap rm_tempfile EXIT

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
