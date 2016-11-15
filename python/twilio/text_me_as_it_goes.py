#!/usr/bin/env python

from twilio.rest import TwilioRestClient
import subprocess
import logging
import json
import time
import argparse

class JohnUpdate():
    def __init__(self, filename):
        self.filename = filename
        self.state = ""
        self.loop()

    def status(self):
        res = subprocess.check_output(("john --show %s" % self.filename), shell=True)
        return res

    def check(self):
        output = self.status()
        logging.INFO(self.status())
        if output != self.state:
            self.state = output
            return True
        return False

    def loop(self):
        while True:
            time.sleep(60)
            if self.check():
                break

def load_config(filename):
    with open(filename) as fl:
        config = json.load(fl)
        return config

class Texter():
    def __init__(self, message):
        config = load_config(".tmaigrc")
        self.message = message
        tc = TwilioRestClient(str(config["account_sid"]),str(config["auth_token"]))

    def send(self):
        tc.message.create(body=self.message, to=str(config["to"]), from_=str(config["number"]))

def parse_options():
    parser = argparse.ArgumentParser(prog="updates", description="Thingie", add_help=True)
    parser.add_argument("-d", "--debug", action="store_true", help="Turn on logging")

    parser.add_argument("-f", "--filename", action="store", help="Phone number file")
    parser.add_argument("-c", "--config", action="store", help="twilio config filename")

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
    u = JohnUpdate()
    Texter("John Output:%s" % u.state).send()

