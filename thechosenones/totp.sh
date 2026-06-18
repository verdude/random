#!/usr/bin/env bash

if [[ $OSTYPE != darwin* ]]; then
  echo "script is only for darwin"
  exit 1
fi

set -Eeuo pipefail

KEYCHAIN="$1"

selection="$(
  security dump-keychain -d "$KEYCHAIN" 2>/dev/null |
  awk '
    function emit() {
      if (acct != "" && svce != "") {
        print svce "\t" acct
      }
    }

    /^class:/ {
      emit()
      acct = ""
      svce = ""
      next
    }

    /"acct"<blob>=/ {
      acct = $0
      sub(/^.*"acct"<blob>="/, "", acct)
      sub(/".*$/, "", acct)
      next
    }

    /"svce"<blob>=/ {
      svce = $0
      sub(/^.*"svce"<blob>="/, "", svce)
      sub(/".*$/, "", svce)
      next
    }

    END {
      emit()
    }
  ' |
  sort -u |
  fzf \
    --delimiter=$'\t' \
    --with-nth=1,2 \
    --prompt='totp> ' \
    --height=40% \
    --layout=reverse
)"

[ -z "${selection:-}" ] && exit 0

IFS=$'\t' read -r service account <<< "$selection"

security find-generic-password \
  -a "$account" \
  -s "$service" \
  -w "$KEYCHAIN" | linzhong | pbcopy
