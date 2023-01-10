#!/usr/bin/env bash

set -euo pipefail

DOTDIR=${DOTDIR:-}
name="p"
efile="p.enc"
dfile="$name.tar.gz"
pfile="$HOME/.secretpw"
decrypt=""
force=""
cipher="chacha20"
keyderivation="pbkdf2"
rmflags="-f"
untar=""
tarcomp="z"
private=(
  .secrets.sh
  .texterrc
  .bin/
)

while getopts :fdp:oxyt flag
do
  case ${flag} in
    f) force="yeah";;
    d) decrypt="-d";;
    p) pfile="${OPTARG}";;
    y) rmflags="-i";;
    t) untar="yeah";;
    x) set -x;;
    :) echo "-${OPTARG}: Requires an argument."; exit 1;;
    ?) echo "-${OPTARG}: Invalid argument."; exit 1;;
  esac
done

# remove temp files
function _cleanup() {
  rm $rmflags *.tar.gz
}
trap _cleanup EXIT

# decrypt or encrypt private files depending on
# whether -d was passed in or not.
function enc() {
  if [[ ! -f "$pfile" ]]; then
    echo "enc: $pfile not found."
    exit 1
  fi

  local dec=${1:-}
  local infile="$efile"
  local outfile="$dfile"

  if [[ $dec != "-d" ]]; then
    dec=""
    infile="$dfile"
    outfile="$efile"
    tar --mtime=0 -c${tarcomp}f "$dfile" "${private[@]}"
  elif [[ ! -f "$efile" ]]; then
    echo "enc: $efile not found. cannot decrypt."
    exit 1
  fi

  openssl enc $dec -pass "file:$pfile" -$cipher \
    -in "$infile" -out "$outfile" -$keyderivation

  if [[ -n "$untar" ]]; then
    tar x${tarcomp}f "$dfile"
  fi
}

# check if private files have been changed.
# writes to stdout if there was a change.
function check() {
  enc -d
  local oldhash=$(sha1sum "$dfile" | cut -d' ' -f1)
  local newhash=$oldhash
  local newf="$(openssl rand -hex 5).temp.tar.gz"

  tar --mtime=0 -c${tarcomp}f "$newf" "${private[@]}"
  newhash=$(sha1sum "$newf" | cut -d' ' -f1)

  if [[ "$oldhash" != "$newhash" ]]; then
    echo changed
  fi
}

if [[ -z "$DOTDIR" ]] || [[ ! -d "$DOTDIR" ]]; then
  echo Weird.
  exit 1
fi

cd "${DOTDIR}"

if [[ -z "$force" ]]; then
  changed=$(check)
  if [[ -n "$changed" ]]; then
    enc $decrypt
    echo Updated.
  else
    echo No change.
  fi
else
  enc $decrypt
  echo Forced.
fi
