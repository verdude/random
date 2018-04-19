#!/usr/bin/env python

from twilio.rest import TwilioRestClient
import argparse
import logging
import json
import os

def load_config(filename):
    with open(filename) as fl:
        config = json.load(fl)
        return config

class Texter():
    def __init__(self):
        self.config = load_config(os.path.expanduser("~")+"/.texterrc")
        self.tc = TwilioRestClient(str(self.config["account_sid"]),str(self.config["auth_token"]))

    def send(self, number, message):
        number = number or self.config["default"]
        logging.info("seding message to: %s", str(number))
        logging.info("Sending message: %s", message)
        self.tc.messages.create(body=message, to=str(number), from_=str(self.config["number"]))

def parse_options():
    parser = argparse.ArgumentParser(prog="updates", description="Send Text", add_help=True)

    parser.add_argument("-m", "--message", action="store", help="The text message")
    parser.add_argument("-n", "--number", action="store", help="Phone number to text.")

    parser.add_argument("-d", "--debug", action="store_true", help="set logging to debug")
    parser.add_argument("-q", "--quiet", action="store_true", help="set logging to quiet")
    return parser.parse_args()

def get_message():
    print("Not yet Implemented")

if __name__ == "__main__":
    args = parse_options()
    if args.quiet:
        lg_level = logging.WARN
    elif args.debug:
        lg_level = logging.DEBUG
    else:
        lg_level = logging.INFO
    logging.basicConfig(level=lg_level)
    message = args.message if args.message is not None else get_message()
    Texter().send(args.number, message)
