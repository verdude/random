#!/bin/bash

commit () {
    git add .
    git commit -am "dot_update"
}

pull () {
    git pull
}

push () {
    git push
}

if [[ -d "$DOTDIR" ]]; then
    pushd "$DOTDIR"
    commit
    pull
    push
    popd
else
    echo "dots folder not found."
    echo "Is this your dotfile directory: ${DOTDIR}?"
fi

