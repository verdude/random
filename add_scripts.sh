#!/bin/bash

chmod 775 bash/binify.sh
bash/binify.sh bash/binify.sh
binify python/twilio/send_text.py
binify python/email/send_email.py
binify bash/create_start_virtualenv.sh
binify bash/tildas.sh
binify bash/activator.sh
binify bash/swishmac.sh
binify bash/plan.sh
binify bash/wiface.sh

envify_alias=$(alias | grep envify)
if [[ -z envify_alias ]]; then
    echo 'alias envify="source create_start_virtualenv"' >> ~/.bashrc
fi
. ~/.bashrc

