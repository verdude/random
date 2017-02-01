#!/usr/bin/env python

import argparse
import logging
import getpass
import traceback
import json
import os

from bot import Bot
from pdb import set_trace as bp

# Global filename
conffile = os.path.expanduser("~/.clockrc")

def parse_options():
    parser = argparse.ArgumentParser(prog="pyMiner", description="Searches BING with your account!", add_help=True)
    parser.add_argument("-d", "--debug", action="store_true", help="Enable debug level logging. A toooon of stuff from selenium gets logged btw.")
    parser.add_argument("-v", "--verbose", action="store_true", help="Enable info level logging")
    parser.add_argument("-n", "--number", action="store", type=int, help="The number of searches to do.", default=200)
    parser.add_argument("-s", "--show", action="store_true", help="Shows the display")
    parser.add_argument("-c", "--config", action="store", help="Path to file with account info. default is ~/.clockrc")
    parser.add_argument("-i", "--clock-in", action="store_true", help="Means you wanna clock out", default=False)
    return parser.parse_args()

def configure_output(args):
    if args.verbose:
        logging.basicConfig(level=logging.INFO)
    else:
        logging.basicConfig(level=logging.DEBUG if args.debug else logging.WARN)

def clock(args, account={}):
    """
    @param account json { netid: "", password: ""}
    """
    netid = account.get("netid")
    password = account.get("password")

    if netid == None or password == None:
        logging.error("No netid or password provided")
        return

    bot = Bot(args.show)
    bot.maibyoodeeyou()
    bot.login(netid, password)
    bot.clock_p(args.clock_out)
    bot.finish()

def getaccounts(args):
    filename = args.config or conffile
    with open(filename) as conf:
        creds = json.loads(conf.read())
        return creds

def main():
    args = parse_options()
    try:
        configure_output(args)
        clock(args, getaccounts(args))
    except KeyboardInterrupt:
        logging.info("Caught Keyboard Interrupt. Exiting.")
    except Exception as e:
        logging.error("Error. Use -v for more details.")
        logging.info("Exception Message: %s" % traceback.format_exc())

if __name__ == "__main__":
    main()
