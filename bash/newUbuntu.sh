#! /bin/bash

aptUpdate() {
    echo "Updating apt-get..."
    sudo apt-get update > /dev/null 2>&1
}

basicPrograms() {
    # downloads:
    #   - sublime
    #   - google-chrome
    #   - spotify
    #   - git
    #   - vim

    #0check if sublime text 3 is installed :: apt-cache policy sublime-text-installer
    if [ `dpkg-query -s sublime-text-installer 2>&1 | grep -c "install ok installed"` -eq 0 ]; then
        sudo add-apt-repository -y ppa:webupd8team/sublime-text-3 > /dev/null 2>&1
        aptUpdate
        sudo apt-get install sublime-text-installer > /dev/null 2>&1
        else
            aptUpdate
            echo "Did not install sublime."
    fi
    
    if [ `dpkg-query -s google-chrome-stable 2>&1 | grep -c "install ok installed"` -eq 0 ]; then
        echo "Installing google chrome..."
        sudo apt-get -y install libxss1 libappindicator1 libindicator7 > /dev/null 2>&1
        wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
        sudo dpkg -i google-chrome*.deb > /dev/null 2>&1
        
        sudo apt-get -f install > /dev/null 2>&1
        else
            echo "Did not install chrome."
    fi

    if [ `dpkg-query -s spotify-client 2>&1 | grep -c "install ok installed"` -eq 0 ]; then
        echo "Installing spotify..."
        sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys BBEBDCB318AD50EC6865090613B00F1FD2C19886 > /dev/null 2>&1
        echo deb http://repository.spotify.com stable non-free | sudo tee /etc/apt/sources.list.d/spotify.list > /dev/null 2>&1
        aptUpdate
        sudo apt-get -y install spotify-client > /dev/null 2>&1
    else echo "Did not install spotify."
    fi
    sudo apt-get -y install git > /dev/null 2>&1
    sudo apt-get -y install vim > /dev/null 2>&1
}

desktopCustomization() {
    # downloads:
    #   - unity tweak tool
    #   - cool-retro-term
    #   - numix theme and icons

    gitFolder=$(find /home ~ ~/Documents -maxdepth 1 -type d | grep -iE "git(hub)")
    # -z is true if the length of the string is zero
    #if the github folder is not found in the home folder or documents
    if [ -z $gitFolder ]; then
        let gitFolder='~/github'
        mkdir $gitFolder
    fi
    echo "Git Folder: $gitFolder"
    if [ `dpkg-query -s unity-tweak-tool 2>&1 | grep -c "install ok installed"` -eq 0 ]; then
        echo "Installing unity-tweak-tool."
        sudo apt-add-repository -y ppa:freyja-dev/unity-tweak-tool-daily > /dev/null 2>&1
        aptUpdate
        sudo apt-get install unity-tweak-tool > /dev/null 2>&1
        echo 'done.'
    else echo "unity-tweak-tool was not installed."
    fi
    if [ `find $gitFolder /home ~ ~/Documents ~/Desktop -maxdepth 1 -type d | grep -ic 'cool-retro-term'` -eq 0 ]; then
        echo "Installing cool-retro-term..."
        sudo apt-get -y install build-essential qmlscene qt5-qmake qt5-default qtdeclarative5-dev qtdeclarative5-controls-plugin qtdeclarative5-qtquick2-plugin libqt5qml-graphicaleffects qtdeclarative5-dialogs-plugin qtdeclarative5-localstorage-plugin qtdeclarative5-window-plugin > /dev/null 2>&1
        git clone --recursive https://github.com/Swordfish90/cool-retro-term.git $gitFolder/cool-retro-term > /dev/null 2>&1
        cd $gitFolder/cool-retro-term
        echo "This may take a while..."
        qmake > /dev/null 2>&1 && make > /dev/null 2>&1
        cd ~
        [[ -d ~/bin ]] || mkdir ~/bin
        printf '#!/bin/bash' > ~/bin/term
        printf "\n$gitFolder/cool-retro-term/cool-retro-term" >> ~/bin/term
        sudo chmod 775 ~/bin/term
    else echo "cool-retro-term was not installed."
    fi
    if [ `dpkg -s numix-gtk-theme 2>&1 | grep -c "install ok installed"` -eq 0 ]; then
        echo "Adding Numix theme..."
        sudo add-apt-repository -y ppa:numix/ppa > /dev/null 2>&1
        aptUpdate
        sudo apt-get install -y numix-gtk-theme numix-icon-theme-circle > /dev/null 2>&1
        confirm "Would you like to install numix wallpapers?" && sudo apt-get install numix-wallpaper-* > /dev/null 2>&1
    else echo "Numix theme was not installed."
    fi
}

play2_1_0() {
    # To get rid of a directory in you path: export PATH=`echo $PATH | sed -e 's/:\/home\/santi\/play-2.1.0$//'`
    playFolder=$(find / /home ~ -maxdepth 1 -type d -name 'play-2.1.0')
    if [ ${#playFolder} -gt 0 ]
        then
            echo "Play 2.1.0 folder was found in $playFolder."
            playInPath=$(echo $PATH | grep -c $playFolder)
            #printenv PATH
            if [ $playInPath -gt 0 ]
                then 
                    echo "Play! is already in PATH."
                else
                    echo "export PATH=\$PATH:$playFolder" >> .bashrc
                    . .bashrc
                    echo "Added Play! to path in .bashrc"
            fi
        else
            echo "Downloading Play-2.1.0..."
            #not sure if the the next line will actually reroute the output to devnull
            sudo wget http://downloads.typesafe.com/play/2.1.0/play-2.1.0.zip
            sudo apt-get -y install unzip > /dev/null 2>&1
            unzip play-2.1.0.zip -d ~ > /dev/null 2>&1
            rm -f play-2.1.0.zip
            echo "export PATH=\$PATH:~/play-2.1.0" >> .bashrc
            . .bashrc
            echo "Downloaded and added Play! to the PATH in .bashrc"
    fi
}

arclite() {
    play2_1_0
    getLamp
    sudo apt-get -y install git > /dev/null 2>&1
    getArcliteRepos
}

getArcliteRepos() {
    gitFolder=$(find /home ~ ~/Documents -maxdepth 1 -type d | grep -iE 'git(hub)?')
    if [ -z $gitFolder ]; then
        let gitFolder='~/github'
        mkdir $gitFolder
    fi
    for repo in Ayamel-Examples DictionaryLookup DictionaryCreator; do
        if [ `ls $gitFolder | grep -c '$repo'` -eq 0 ]; then
            echo "Cloning $repo..." 
            git clone https://github.com/BYU-ARCLITE/$repo.git $gitFolder/$repo > /dev/null 2>&1
        fi
    done
    if [ -d /var/www ]; then
        git clone https://github.com/BYU-ARCLITE/Ayamel.js.git /var/www/Ayamel.js > /dev/null 2>&1
        else echo "Install Lamp first! Ayamel.js not cloned."
    fi
}

getLamp() {
    aptUpdate
    echo Installing apache2...
    sudo apt-get -y install apache2 > /dev/null 2>&1
    mysqlinstalled=$(apt-cache policy mysql-server | grep -c "(none)")
    if [ $mysqlinstalled -gt 0 ]; then
        echo "Installing mysql-server. Follow prompts to securly set up MySQL."
        sudo apt-get -y install mysql-server > /dev/null 2>&1
        sudo mysql_secure_installation
    fi
    echo Installing php4, php-pear, and php5-mysql...
    sudo apt-get -y install php5 php-pear php5-mysql > /dev/null 2>&1
    echo Installing phpmyadmin...
    sudo apt-get -y install phpmyadmin
    sudo service apache2 restart > /dev/null 2>&1
    echo "Finished installing lamp."
}

verdudeGit() {
    gitFolder=$(find /home ~ ~/Documents -maxdepth 1 -type d | grep -iE 'git(hub)?')
    if [ -z $gitFolder ]; then
        let gitFolder='~/github'
        mkdir $gitFolder
    fi
    echo "Github Folder: $gitFolder"
    for repo in madatest random CS_240 dingo_django; do
        if [ `ls $gitFolder | grep -c '$repo'` -eq 0 ]; then
            #works with this line here only for some strange reason...
            ls $gitFolder | grep -c '$repo' > /dev/null 2>&1
            echo "Cloning $repo..."
            git clone https://github.com/verdude/$repo.git $gitFolder/$repo
        fi
    done
}

downloadEverything() {
    echo 'INSTALLING BASIC PROGRAMS.'
    basicPrograms
    echo 'INSTALLING DESKTOP CUSTOMIZATIONS.'
    desktopCustomization
    echo 'INSTALLING ARCLITE REPOS AND PLAY.'
    arclite
    echo "INSTALLING VERDUDE'S REPOSITORIES."
    verdude
}

# prompts the user whether or not they wish to execute some following command.
confirm () {
    # call with a prompt string or use a default
    read -r -p "${1:-Are you sure? [y/N]} " response
    case $response in
        [yY][eE][sS]|[yY]) 
            true
            ;;
        [Nn][Oo]|[Nn])
            false
            ;;
        *)
            false
            #need to create a way to loop back to the read statement.
            ;;
    esac
}

quit() {
    if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
        return $1
        else exit $1
    fi
}

usage() {
    echo
    echo "  -h                          For this help message."
    echo "  -e                          To download and set everything up."
    echo "  -c | --choose <section>.*   To download specific sections."
    echo
    echo "  SECTIONS:"
    echo "      basic"
    echo "      play                    Play! Framework version 2.1.0"
    echo "      arclite                 Includes play"
    echo "      desktop                 Includes cool-retro-term, unity-tweak-tool"
    echo "      verdude                 Downloads all of verdude's repositories"
    echo "  "
}

# set the script to exit on errors=
set -e

if [ $SHELL != /bin/bash ]; then
    echo incorrect shell error
    quit 1
fi

if [ $# -eq 0 ]; then
    usage
    quit 1
elif [ $1 = -h ]; then
    usage
    quit 0
fi

if [ $1 = "-e" ]; then
    downloadEverything
elif [ $1 == '--choose' -o $1 == '-c' ]; then
    if [ $# -eq 1 ]; then
        usage
        quit 1
    fi
    for arg in $*; do
        case $arg in
            basic)
                basicPrograms
            ;;
            arclite)
                arclite
            ;;
            play)
                play2_1_0
            ;;
            desktop)
                desktopCustomization
            ;;
            verdude)
                verdudeGit
            ;;
        esac
    done
else
    printf "Invalid Argument: $1\nUse -h for help.\n"
    quit 1  
fi
