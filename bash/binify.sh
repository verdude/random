#!/bin/bash

if [ ! $# -eq 1 ]; then
	echo "Illegal number of parameters"
fi

if [ -f $1 ]; then
	if [ ! -d ~/bin ]; then
		mkdir ~/bin
	fi
	filename=~/bin/`python -c "print '$temp'.split('/')[-1].split('.')[0]"`
	if [ -f fname ]; then
		echo "that script already exists..."
		exit
	fi
	echo "saving file to $filename"
	cp $1 "$filename"
	chmod 775 "$filename"
else
	echo "file does not exist..."
fi

