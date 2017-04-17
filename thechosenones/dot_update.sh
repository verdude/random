#!/bin/bash

commit () {
    pushd "$DOTDIR"
    git add .
    git commit -am "dot_update"
    git push
    popd
}

if [[ -d "$DOTDIR" ]]; then
    commit
else
    echo "dots folder not found."
    echo "Is this your git directory: ${GITDIR}?"
fi

