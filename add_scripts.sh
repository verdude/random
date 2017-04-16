#!/bin/bash

cd $GITDIR/random
rel=$(echo ~/bin/)
ln -s python/twilio/send_text.py "$rel"
ln -s python/email/send_email.py "$rel"
ln -s bash/activator.sh "$rel"
ln -s bash/wiface.sh "$rel"
ln -s bash/delswaps.sh "$rel"

