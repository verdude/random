#!/bin/bash

commit () {
    pushd "$GITDIR"/dotfiles
    git add .
    git commit -am "dot_update"
    git push
    popd
}

if [[ -d "$GITDIR"/dotfiles ]]; then
    commit
else
    echo "dotfiles folder not found."
    echo "Is this your git directory: ${GITDIR}?"
fi

