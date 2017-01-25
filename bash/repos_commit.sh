#!/bin/bash

commit_ () {
    git commit -m "backup"
    git push $(git remote) $(git rev-parse --symbolic-full-name --abbrev-ref HEAD)
}

for f in $(find . -name ".repos"); do
    pushd $(dirname $f);
    for d in $(cat .repos | awk '{print $4}'); do
        if [[ -d $d ]]; then
            pushd $d
            git update-index -q --refresh 
            untracked=$(git ls-files --others)
            changed=$(git diff-files | awk '{print $6}')
            if [[ -n $untracked ]]; then
                git add .
            elif [[ -n $changed ]]; then
                for filepath in $changed; do
                    git add $filpath
                done
            fi
            popd;
        fi
    done;
    popd
done

