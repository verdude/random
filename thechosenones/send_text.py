#!/usr/bin/env python

from twilio.rest import Client
import argparse
import logging
import json
import os

def stripper(s):
    return s.strip()

def read_from_file(filename):
    config = {}
    with open(filename, "r") as f:
        l = map(stripper, f.readlines()[:4])
        config['account_sid'], config['auth_token'], config['from_num'], config['to_num'] = l
    return config

def load_from_env():
    config = {}
    config['account_sid'] = os.environ.get('TWILIO_ACCOUNT_SID')
    config['auth_token'] = os.environ.get('TWILIO_AUTH_TOKEN')
    config['from_num'] = os.environ.get('TWILIO_FROM_NUMBER')
    config['to_num'] = os.environ.get('MY_PHONE')
    return config

class Texter():
    def __init__(self, config_path):
        self.config = load_from_env()
        self.tc = Client(str(self.config["account_sid"]),str(self.config["auth_token"]))

    def send(self, number, message):
        number = number or self.config["to_num"]
        logging.info("seding message to: %s", str(number))
        logging.info("Sending message: %s", message)
        resp = self.tc.messages.create(body=message, to=str(number), from_=str(self.config["from_num"]))
        print(resp.sid)

def parse_options():
    parser = argparse.ArgumentParser(prog="updates", description="Send Text", add_help=True)

    parser.add_argument("-m", "--message", action="store", help="The text message")
    parser.add_argument("-n", "--number", action="store", help="Phone number to text")
    parser.add_argument("-c", "--config", action="store", help="Config file location")

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
    Texter(args.config).send(args.number, message)
