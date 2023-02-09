#!/usr/bin/env bash

set -euo pipefail

scriptpath="$( cd "$(dirname "$0")" ; pwd -P )"

mkdir -p ~/bin

pushd () {
  command pushd "$@" > /dev/null
}

popd () {
  command popd "$@" > /dev/null
}

scripts_dirname="thechosenones"

get_clip() {
  make -C $(find $scriptpath -name clip -type d) install
}

check_for_script_folder() {
  if [[ ! -d "$scripts_dirname" ]]; then
      dir=$(find ${GITDIR:-.} -name "$scripts_dirname" -maxdepth 2 -type d -quit)
    if [[ -z "$dir" ]]; then
      echo "Repository with $scripts_dirname not found. Exiting."
      exit 1
    fi
  fi

  echo "Found $scripts_dirname directory"
}

link_files() {
  rel=~/bin/
  for file in $(ls $1); do
    printf .
    fname="$(readlink -f $scripts_dirname/$file)"
    linkname=$(echo $file | sed -E 's/^([^\.]*).*/\1/')
    ln -s -f "$fname" "$rel$linkname" 2>/dev/null
  done
  echo
  echo "scripts added."
}

main() {
  scriptpath="$( cd "$(dirname "$0")" ; pwd -P )"
  cd $scriptpath

  if [[ -d $scripts_dirname ]]; then
    link_files "$scripts_dirname"
  elif [[ "${PWD##*/}" = "thechosenones" ]]; then
    pushd ..
    link_files "$scripts_dirname"
    popd
  else
    check_for_script_folder
  fi
}

main
