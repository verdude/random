#!/bin/bash

cd ~/docs/github/random
chmod 775 bash/binify.sh
home_bin=$(echo $PATH | grep ~/bin)
if [[ -z $home_bin ]]; then
    echo 'export PATH=$PATH:~/bin' >> ~/.bashrc;
fi
rel=$(echo ~/bin/)
bash/binify.sh bash/binify.sh $1
$rel""binify python/twilio/send_text.py $1
$rel""binify python/email/send_email.py $1
$rel""binify bash/create_start_virtualenv.sh $1
$rel""binify bash/tildas.sh $1
$rel""binify bash/activator.sh $1
$rel""binify bash/swishmac.sh $1
$rel""binify bash/plan.sh $1
$rel""binify bash/wiface.sh $1
$rel""binify bash/git_setup.sh $1
$rel""binify bash/backup.sh $1

envify_alias=$(alias | grep envify)
if [[ -z envify_alias ]]; then
    echo 'alias envify="source create_start_virtualenv"' >> ~/.bashrc
fi
. ~/.bashrc

