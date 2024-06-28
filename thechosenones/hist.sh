#!/usr/bin/env bash

set -euo pipefail

cc=$(git rev-parse HEAD)
declare -i index=0 size=0 useless=1 loud=1 reverse=0
stringsearch=()
diffargs=()
colors="always"
tempfile=""
hashes=()
merges=()

function usage() {
  cat <<EOF
-S <arg> stringsearch
-r <arg> Set starting ref
-b <arg> Set base ref
-e       Reverse walk direction
-c       Disable Colors
-x       set -o xtrace
-t       sets --compact-summary
-l       sets --name-only
-m       sets --merges
-n       Don't use less for diff output
-q       quiet
EOF
}

while getopts :xhltnqS:b:ecr:m flag
do
  case ${flag} in
    S) stringsearch=(-S "${OPTARG}");;
    r) cc=${OPTARG};;
    b) base=${OPTARG};;
    e) reverse=1;;
    c) colors="never";;
    x) set -x;;
    t) diffargs=(--compact-summary);;
    l) diffargs=(--name-only);;
    n) useless=0;;
    m) merges=(--merges);;
    q) loud=0;;
    h)
      usage
      exit 0
      ;;
    :)
      echo ${OPTARG} requires a param
      exit 1
      ;;
    ?)
      echo "invalid arg: ${OPTARG}"
      exit 1
      ;;
  esac
done

shift $((OPTIND - 1))
args="$*"

function get_hashes() {
  hashes=($(git log "${base:+${base}..}$cc" "${stringsearch[@]}" "${merges[@]}" --pretty=format:"%h" -- $args))
  size=${#hashes[@]}
  if ! ((size)); then
    echo "Nothing found."
    exit
  fi
  if ((reverse)); then
    index=$(($size - 1))
  fi
  cc=${hashes[$index]}
}

function next() {
  if ((reverse)) && [[ $index -gt 0 ]]; then
    index=$(($index - 1))
    cc=${hashes[$index]}
  elif ! ((reverse)) && [[ $(($index + 1)) -lt $size ]]; then
    index=$(($index + 1))
    cc=${hashes[$index]}
  else
    echo "finished."
    exit
  fi
}

function log() {
  local logline
  local output

  logline="$(git show --oneline --pretty=format:"%h-%f-%al-%aI" --no-patch $cc)"
  if ((useless)); then
    tempfile="$(mktemp /tmp/${logline}-XXX.tmp)"
    output=("--output=${tempfile}")
  else
    output=()
  fi

  git diff "${output[@]}" "${diffargs[@]}" --color="${colors}" $cc^ $cc -- $args 2>/dev/null

  if [[ $? -eq 128 ]]; then
    echo
    echo "Bad Revision! ['$cc^' '$cc']"
    echo "bye."
    exit 1
  fi

  if ((useless)); then
    less -frc "$tempfile"
  fi

  rm -f "${tempfile}"

  if ((loud)); then
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
