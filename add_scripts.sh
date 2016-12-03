#!/bin/bash



chmod 775 bash/binify.sh
bash/binify.sh bash/binify.sh
binify python/twilio/send_text.py
binify python/email/send_email.py
binify bash/create_start_virtualenv.sh
binify bash/tildas.sh

echo 'alias envify="source create_start_virtualenv"' >> ~/.bashrc
. ~/.bashrc

