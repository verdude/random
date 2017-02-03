#!/bin/bash

clone () {
    rep_dir=$(echo $1 | python -c "import sys;i=sys.stdin.read();i=i.rstrip('/');print i[:0-len(i.split('/')[-1])].rstrip('/')")
    pushd "$rep_dir"
    cat .repos | bash -
    popd
}

export -f clone
find . -type f -name '.repos' -exec bash -c 'clone "$0"' {} \; 2>/dev/null

