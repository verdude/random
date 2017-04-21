#!/bin/bash

pushd() {
    command pushd "$@" >/dev/null 2>&1
}
popd() {
    command popd "$@" >/dev/null 2>&1
}

get_dep() {
    # args: $1=repository name, $2=directory name
    git clone git@github.com:byu-odh/$1 >/dev/null 2>&1
    pushd $1
    git checkout develop >/dev/null 2>&1
    popd
}

update_dep() {
    # $1=directory name
    pushd $1
    git checkout develop >/dev/null 2>&1
    git pull >/dev/null 2>&1
    popd
}

dependencies() {
    pushd /var/www/html
    if [[ $(stat -c %U /var/www/html) != $USER ]]; then
        echo "chowning server root to $USER:$USER"
        sudo chown -R $USER:$USER .
    fi
    deps=$(ls -F /var/www/html | grep "/")
    ajs=$(echo $deps | grep Ayamel.js)
    ews=$(echo $deps | grep EditorWidgets)
    tmt=$(echo $deps | grep TimedText)
    tle=$(echo $deps | grep subtitle-timeline-editor)

    if [[ -z $ajs ]]; then
        get_dep Ayamel.js
    else
        update_dep Ayamel.js
    fi
    if [[ -z $ews ]]; then
        get_dep EditorWidgets
    else
        update_dep EditorWidgets
    fi
    if [[ -z $tmt ]]; then
        get_dep TimedText
    else
        update_dep TimedText
    fi
    if [[ -z $tle ]]; then
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

if [[ $1 == "help" ]]; then
    echo "USAGE:"
    echo "    $0 [command] # to run different play commands on the project"
    echo "COMMANDS:"
    echo "    run                        Runs the project in development mode."
    echo "    compile                    Compiles the project."
    echo "    help [play/sbt command]    Information about how to run a specific play/sbt command."
    echo "    update                     Updates all of the dependencies in /var/www/html."
    echo
    echo "NOTE: Only works on Debian based systems, atm."
    echo "NOTE: Just typing $0 will launch the play/sbt console for the project in the current directory."
    exit
fi

if [[ $1 == "update" ]]; then
    dependencies
    exit
fi

if [ -z $(which sbt) ]; then
    sbt "$@"
else
    echo "check this out: scala-sbt.org/download.html"
    echo "try: $0 help"
fi

