#! /bin/bash


aptUpdate() {
    echo Updating apt-get...
    sudo apt-get update >NUL 2>&1
    echo "done."
}

basicPrograms() {
    # downloads:
    #   - sublime
    #   - google-chrome
    #   - git
    #   - vim

    #0check if sublime text 3 is installed :: apt-cache policy sublime-text-installer
    sudo add-apt-repository ppa:webupd8team/sublime-text-3
    aptUpdate
    
    sudo apt-get install sublime-text-installer
    
    sudo apt-get -y install libxss1 libappindicator1 libindicator7
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo dpkg -i google-chrome*.deb
    
    sudo apt-get -f install
    sudo apt-get install git
    sudo apt-get install vim
}

desktopCustomization() {
    # downloads:
    #   - unity tweak tool
    sudo apt-add-repository ppa:freyja-dev/unity-tweak-tool-daily
    aptUpdate
    sudo apt-get install unity-tweak-tool

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
            sudo apt-get install unzip >> /dev/null
            unzip play-2.1.0.zip -d ~ >> /dev/null
            rm -f play-2.1.0.zip
            echo "export PATH=\$PATH:~/play-2.1.0" >> .bashrc
            . .bashrc
            echo "Downloaded and added Play! to the PATH in .bashrc"
    fi
}

arclite() {
    #find out where the github folder is
    #clone all repositories
    play2_1_0
    #download LAMP
}

verdudeGit() {
    downloadEverything
}

downloadEverything() {
    echo not yet implemented
}

usage() {
    echo
    echo "  -h                        for this help message."
    echo "  -e                        to download and set everything up."
    echo "  --choose <section>.*      To download specific sections."
    echo
    echo "  SECTIONS:"
    echo "      basic"
    echo "      play                    Play! Framework version 2.1.0"
    echo "      arclite                 Includes play"
    echo "      desktop                 Includes cool-retro-term, unity-tweak-tool"
    echo "      verdudeGit              Downloads all of verdude's repositories"
    echo "  "
}

# set the script to exit on errors
set -e

if [ $SHELL != /bin/bash ]; then
    echo incorrect shell error
    return 1
fi

#TODO:: #if first argument is random => print usage and exit

if [ $# -eq 0 ] || [ $1 = -h ]; then
    usage
    return 1
fi

if [ $1 = -e ]
    then downloadEverything
    return 0
    else if [ $1 = --choose ]; then
        for arg in $*; do
            #echo $arg
            case $arg in 
                downloadEverything)
                    usage
                    return 1
                ;;
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
                verdudeGit)
                    verdudeGit
                ;;
            esac
        done
    fi
fi
