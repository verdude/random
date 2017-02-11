#!/bin/bash

pushd() {
    command pushd "$@" >/dev/null 2>&1
}
popd() {
    command popd "$@" >/dev/null 2>&1
}

get_dep() {
    pwd
    echo "get $@"
    # args: $1=repository name, $2=directory name
    git clone git@github.com:byu-odh/$1
    pushd $1
    git checkout develop
    popd
}

update_dep() {
    pwd
    echo "updoot $@"
    # $1=directory name
    pushd $1
    git checkout develop
    git pull
    popd
}

dependencies() {
    pushd /var/www/html
    if [[ $(stat -c %U /var/www/html) != $USER ]]; then
        echo "chowning server root to $USER:$USER"
        sudo chown -R $USER:$USER .
    fi
    deps=$(ls -F /var/www/html | grep "/")
    ajs=$(echo $deps | grep ayameljs)
    ews=$(echo $deps | grep editorwidgets)
    tmt=$(echo $deps | grep timedtext)
    tle=$(echo $deps | grep timelineeditor)

    if [[ -z ajs ]]; then
        get_dep Ayamel.js
    else
        update_dep Ayamel.js
    fi
    if [[ -z ews ]]; then
        get_dep EditorWidgets
    else
        update_dep EditorWidgets
    fi
    if [[ -z tmt ]]; then
        get_dep TimedText
    else
        update_dep TimedText
    fi
    if [[ -z tle ]]; then
        get_dep subtitle-timeline-editor
    else
        update_dep subtitle-timeline-editor
    fi
    popd
}

if [[ ! -d /var/www/html ]]; then
    echo "Install lamp first noob."
    echo "# sudo apt install tasksel"
    echo "# Then select lamp and follow the prompts"
    exit
fi

if [[ $1 == "update" ]]; then
    dependencies
fi

if [ -d ~/activator ]; then
    ~/activator/bin/activator $@
else
    echo "not gonna download...exiting"
    exit
    cd ~
    wget https://downloads.typesafe.com/typesafe-activator/1.3.12/typesafe-activator-1.3.12.zip
    unzip typesafe-activator-1.3.12.zip
    mv "activator-dist-1.3.12" activator
    ~/activator/bin/activator $@
fi

