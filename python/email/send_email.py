#!/usr/bin/env python

import json
import argparse
import logging
import os
import getpass
import smtplib
from email.mime.text import MIMEText

CONFIG_FILENAME = ".emailrc"

class bcolors:
    cols = {
        "HEADER": '\033[95m',
        "BLUE": '\033[94m',
        "GREEN": '\033[92m',
        "WARNING": '\033[93m',
        "FAIL": '\033[91m',
        "ENDC": '\033[0m',
        "BOLD": '\033[1m',
        "UNDERLINE": '\033[4m'
    }

    @staticmethod
    def color(s, c="BLUE", b=False, u=False):
        decorators = bcolors.cols[c]
        if b:
            decorators += bcolors.cols["BOLD"]
        if u:
            decorators += bcolors.cols["UNDERLINE"]
        return "%s%s%s" % (decorators,s,bcolors.cols["ENDC"])

def send(args, config):
    """
        Expected credentials:
            content=the text content of the email, string
            subject=the email subject, string
            from=the outgoing email, string
            password=the outgoing email password, string
            to=the target emails, list of strings
    """
    msg = MIMEText(args.message)

    msg['Subject'] = args.subject
    msg['From'] = config["name"]

    s = smtplib.SMTP('smtp.gmail.com', 587)
    s.ehlo()
    s.starttls()
    s.login(config["email"], config["password"])
    s.sendmail(msg['From'], args.to, msg.as_string())
    s.quit()
    logging.info(bcolors.OKGREEN + bcolors.BOLD + "Success: Email sent." + bcolors.ENDC)

def get_config(config_filename=""):
    logging.debug(bcolors.color("Config Filename: %s" % config_filename, "BLUE"))
    if config_filename is "" or config_filename is None:
        config_filename = os.path.expanduser("~")+"/"+CONFIG_FILENAME
        logging.debug("Setting conf filename: %s", config_filename)
    try:
        with open(config_filename, "r") as config:
            return json.load(config)
    except:
        logging.debug("exeption while trying to read config file: %s" % config_filename)
        config = {}
        config["email"] = get_user_response("email")
        config["password"] = get_user_response("password", password=True)
        config["name"] = get_user_response("name")
        return config

def parse_options():
    parser = argparse.ArgumentParser(prog="updates", description="Send and Email.", add_help=True)
    parser.add_argument("-m", "--message", action="store", help="The email body")
    parser.add_argument("-t", "--to", action="store")
    parser.add_argument("-s", "--subject", action="store")
    parser.add_argument("-d", "--debug", action="store_true", help="set logging to debug")
    parser.add_argument("-q", "--quiet", action="store_true", help="set logging to quiet")
    parser.add_argument("-c", "--config", action="store", help="The configuration filename")
    return parser.parse_args()

def setup_logging(args):
    if args.quiet:
        lg_level = logging.WARN
    elif args.debug:
        lg_level = logging.DEBUG
    else:
        lg_level = logging.INFO
    logging.basicConfig(level=lg_level)

def get_user_response(prompt, multi_line=False, password=False):
    prompt = ("%s: " % prompt).rjust(12)
    response = ""
    exit = 2
    while 1:
        chunk = getpass.getpass(prompt=prompt) if password else raw_input(prompt)
        if not multi_line:  
            response = chunk
            break
        else: prompt = "cont: ".rjust(12)
        if chunk is "":
            exit -= 1
            if exit is 0:   
                break
            else: prompt = ": ".rjust(12)
        else:
            chunk += "\n" if exit is 2 else "\n\n"
            exit = 2
        logging.debug("chunk: %s" % chunk)
        response += chunk
    return response

def get_fields(args):
    if args.message is None:    
        args.message = get_user_response("message", True)
    if args.to is None:
        args.to = get_user_response("to")
    if args.subject is None:
        args.subject = get_user_response("subject")
    return args

def main():
    args = parse_options()
    setup_logging(args)
    config = get_config(args.config)
    args = get_fields(args)
    try:
        send(args, config)
    except smtplib.SMTPRecipientsRefused, e:
        logging.error(bcolors.color("[%s]'s probly not an email." % args.to, "FAIL", b=True))

try:
    main()
except KeyboardInterrupt:
    print "\n" + bcolors.color("Caught Keyboard Interrupt. Exiting.", "WARNING", b=True)

