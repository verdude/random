#!/bin/bash

commit () {
    pushd "$GITDIR"/dots
    git add .
    git commit -am "dot_update"
    git push
    popd
}

if [[ -d "$GITDIR"/dots ]]; then
    commit
else
    echo "dots folder not found."
    echo "Is this your git directory: ${GITDIR}?"
fi

