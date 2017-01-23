#!/bin/bash

if [[ ! -d /var/www/html ]]; then
    echo "Install lamp first noob."
    exit 1
elif [[ $(stat -c %U /var/www/html) != $USER ]]; then
    cd /var/www/html
    echo "chowning server root to $USER:$USER"
    sudo chown -R $USER:$USER .
    dependencies=$(ls /var/www/html | grep ayameljs | grep editorwidgets | grep timedtext | grep timelineeditor)
    if [[ -z dependencies ]]; then
        git clone git@github.com:byu-odh/ayamel.js ayameljs
        cd ayameljs
        git checkout develop
        cd ..
        git clone git@github.com:byu-odh/editorwidgets
        cd editorwidgets
        git checkout develop
        cd ..
        git clone git@github.com:byu-odh/timedtext
        cd timedtext
        git checkout develop
        cd ..
        git clone git@github.com:byu-odh/subtitle-timeline-editor timelineeditor
        cd timelineeditor
        git checkout develop
    fi
fi
if [ -d ~/activator ]; then
    ~/activator/bin/activator $@
else
    cd ~
    wget https://downloads.typesafe.com/typesafe-activator/1.3.12/typesafe-activator-1.3.12.zip
    unzip typesafe-activator-1.3.12.zip
    mv "typesafe-activator-1.3.12" activator
    ~/activator/bin/activator $@
fi

