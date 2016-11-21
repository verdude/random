#!/usr/bin/env python

import json
import argparse
import logging
import os

def send(args, creds):
    """
        Expected credentials:
            content=the text content of the email, string
            subject=the email subject, string
            from=the outgoing email, string
            password=the outgoing email password, string
            to=the target emails, list of strings
    """
    import smtplib
    from email.mime.text import MIMEText

    msg = MIMEText(args.message)

    msg['Subject'] = args.subject
    msg['From'] = str(creds["name"])

    s = smtplib.SMTP('smtp.gmail.com', 587)
    s.ehlo()
    s.starttls()
    s.login(str(creds["email"]), str(creds["password"]))
    s.sendmail(msg['From'], args.to, msg.as_string())
    s.quit()

def get_creds(config_filename=""):
    if config_filename is "":
        config_filename = os.path.expanduser("~")+"/.send_emailrc"
    try:
        with open(config_filename, "r") as config:
            return json.load(config)
    except IOError as err:
        logging.error("File [%s] not found." % config_filename)
        return None

def parse_options():
    parser = argparse.ArgumentParser(prog="updates", description="Send and Email.", add_help=True)
    parser.add_argument("-m", "--message", action="store", help="The email body", required=True)
    parser.add_argument("-t", "--to", action="store", required=True)
    parser.add_argument("-s", "--subject", action="store")
    parser.add_argument("-d", "--debug", action="store_true", help="set logging to debug")
    parser.add_argument("-q", "--quiet", action="store_true", help="set logging to quiet")
    return parser.parse_args()

def setup_logging(args):
    if args.quiet:
        lg_level = logging.WARN
    elif args.debug:
        lg_level = logging.DEBUG
    else:
        lg_level = logging.INFO
    logging.basicConfig(level=lg_level)

def main():
    args = parse_options()
    setup_logging(args)
    creds = get_creds()
    if creds is None:
        return
    logging.debug(creds)
    send(args, creds)

main()

