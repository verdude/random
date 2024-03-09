#!/usr/bin/env bash

set -Eeuo pipefail

sed -Ei 's/^URxvt.(font|italic|bold|boldItalic|keysym.M-C-[0-9]).*//' $DOTDIR/.Xresources

if [[ -n ${1:-} ]]; then
  echo "${1}" >> $DOTDIR/.Xresources
fi
