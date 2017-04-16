#!/bin/bash

cd ~
if [[ ! -d docs ]]; then
    echo "docs folder not found."
    exit 1
fi
dryrun=$([[ "$1" = "--dry-run" ]] && echo true)

pushd () {
    command pushd "$@" > /dev/null
}

popd () {
    command popd "$@" > /dev/null
}


annotate_repo () {
    updir () { echo $1 | python -c "import sys;i=sys.stdin.read();i=i.rstrip('/');print i[:0-len(i.split('/')[-1])].rstrip('/')"; }
    repo_parent () { updir $(git rev-parse --show-toplevel 2>/dev/null); }
    fix_dir () { if [[ -n $(pwd | grep "\.git") ]]; then updir $(pwd); else echo $(pwd); fi; }
    relpath(){ python -c "import os.path; print os.path.relpath('$1','${2:-$PWD}')" ; }
    remote () { if [[ -n $(git remote 2>/dev/null) ]]; then git remote get-url --all $(git remote); fi; }
    curr_lvl () { printf '%s\n' "${PWD##*/}"; }
    if [[ ! -d $1 ]] | [[ $# -ne 1 ]]; then
        >&2 echo "annotate_repo needs a directory..."
        exit 1
    else
        cd $1
        rem=$(remote)
        cd $(fix_dir $1)
        parent_dir=$(repo_parent)
        if [[ -n $rem ]]; then
            filename=$parent_dir/.repos
            if [[ -n $(grep $rem $filename) ]]; then
                cat $filename | grep -v $rem > $filename
            fi
            echo "git clone $rem $(curr_lvl)" >> $filename
            echo "--exclude=$(relpath $(pwd) ~ )"
        fi
    fi
}

commit_ () {
    git commit -m "backup"
    git push $(git remote) $(git rev-parse --symbolic-full-name --abbrev-ref HEAD)
}

repos_commit () {
    for f in $(find ~/docs -name ".repos"); do
        pushd $(dirname $f)
        for d in $(cat .repos | awk '{print $4}'); do
            if [[ -d $d ]]; then
                pushd $d
                git update-index -q --refresh 
                untracked=$(git ls-files --others)
                changed=$(git diff-files | awk '{print $6}')
                if [[ -n $untracked ]]; then
                    if [[ -n $dryrun ]]; then
                        echo "would git add untracked files in $(pwd)::$untracked"
                    else
                        git add .
                    fi
                fi
                if [[ -n $changed ]]; then
                    if [[ -n $dryrun ]]; then
                        echo "would git add changed files in $(pwd)::$changed"
                    else
                        for filepath in $changed; do
                            git add $filepath
                        done
                    fi
                fi
                if [[ -n $untracked ]] || [[ -n $changed ]]; then
                    if [[ -n $dryrun ]]; then
                        echo "would commit $d"
                    else
                        commit_
                    fi
                fi
                popd
            fi
        done
        popd
    done
}

dotfiles(){
    cd ~
    if [[ ! -d docs/dotfiles ]]; then
        echo "Making docs/dotfiles..."
        mkdir docs/dotfiles
    fi
    if [[ -d .emacs.d ]]; then
        echo "Backing up emacs conf..."
        cp -r .emacs.d docs
    fi
    if [[ -d .i3 ]]; then
        echo "Backing up i3 conf..."
        cp -r .i3 docs/dotfiles
    fi
    if [[ -d .fonts ]]; then
        echo "Backing up the fonts dir"
        cp -r .fonts docs/dotfiles
    fi

    cd ~
    cp .*rc docs/dotfiles/
    cp .bash_aliases docs/dotfiles/
    cp .bash_profile docs/dotfiles/
    cp .tmux.conf docs/dotfiles
}

check_size() {
    find ~/docs -type d -exec du -s {} \; | awk '$1>90000{print $0}'
}

gitxclude () {
    # uber hacks; export the function and then exec a subshell
    # the zero seems to be the {} that is the curr dir find is exec'ing on
    export -f annotate_repo
    find ~/docs/ -name "\.git" -type d -exec bash -c 'annotate_repo "$0"' {} \;
}

compress_encrypt() {
    cd ~
    if [[ ! -d docs ]]; then
        echo "Docs directory not found. Exiting."
        exit 1
    fi
    echo "compressing docs..."
    excludes=$(gitxclude)
    repos_commit
    [[ -n $dryrun ]] && echo $excludes && cleanup && exit 0
    tar $excludes -cjf docs.bz2 docs
    openssl enc -aes-256-cbc -in docs.bz2 -out docs.bz2.enc
}

backup () {
    cd ~
    if [[ -f docs.bz2.enc ]]; then
        echo "Backing up to spooq.website..."
        scp docs.bz2.enc jelly@spooq.website:~/docs.bz2.enc
    else
        echo "encrypted file not found."
    fi
}

cleanup () {
    echo "cleanup..."
    [[ -f docs.bz2 ]] && rm docs.bz2
    rm -rf ~/docs/dotfiles
    rm -rf ~/docs/.emacs.d
    echo "Done"
}

check_size
dotfiles
compress_encrypt
backup
cleanup

