#!/usr/bin/env python

from twilio.rest import TwilioRestClient
import argparse
import logging
import json

def load_config(filename):
    with open(filename) as fl:
        config = json.load(fl)
        return config

class Texter():
    def __init__(self, message):
        self.config = load_config(".texterrc")
        self.message = message
        self.tc = TwilioRestClient(str(self.config["account_sid"]),str(self.config["auth_token"]))

    def send(self):
        logging.info("Sending message: %s", self.message)
        self.tc.messages.create(body=self.message, to=str(self.config["to"]), from_=str(self.config["number"]))

def parse_options():
    parser = argparse.ArgumentParser(prog="updates", description="Send Text", add_help=True)

    parser.add_argument("-m", "--message", action="store", help="The text message")

    parser.add_argument("-d", "--debug", action="store_true", help="set logging to debug")
    parser.add_argument("-q", "--quiet", action="store_true", help="set logging to quiet")
    return parser.parse_args()

if __name__ == "__main__":
    args = parse_options()
    if args.quiet:
        lg_level = logging.WARN
    elif args.debug:
        lg_level = logging.DEBUG
    else:
        lg_level = logging.INFO
    logging.basicConfig(level=lg_level)
    run_message = "-\n-=-=-=-=-=-=-=-=-=-=-=-\n Run_the_script_now\n-=-=-=-=-=-=-=-=-=-=-=-"
    Texter(args.message if args.message is not None else run_message).send()

