#!/usr/bin/env python3

import argparse
import logging
import getpass
import traceback
import json
import time
import os
import sys
import logging

from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.common.exceptions import *
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.alert import Alert
from pyvirtualdisplay import Display
from selenium.webdriver.chrome.options import Options

from pdb import set_trace as bp

# Global filename
conffile = os.path.expanduser("~/.ploprc")

class Bot():
    def __init__(self, show):
        self.chromeDriverLocation = ["./chromedriver","/usr/bin/chromedriver"]
        self.show = show
        if not self.show:
            self.display = Display(visible=0, size=(800, 600))
            self.display.start()
        else: self.display = None
        for x in self.chromeDriverLocation:
            if os.path.isfile(x):
                self.driver = webdriver.Chrome(x)
                break

    def finish(self):
        """ Cleanup the driver and display """
        self.driver.close()
        if self.display is not None:
            self.display.stop()


    def type(self, element, text):
        try:
            for ch in text:
                element.send_keys(ch)
        except Exception as e:
            logging.info("Caught Exception: %s" % str(e))
            sys.exit(1)

    def clock(self,cin,fakemode):
        time.sleep(2)
        btnclock = self.driver.find_element_by_id("btnClock")
        t=btnclock.text.lower()
        if btnclock.text.lower() == "clock out":
            if cin:
                logging.error("D1s s0m3 w31rd cr4p...")
            else:
                logging.info("cl0cking 0u7")
                if fakemode: return
                btnclock.click()
                time.sleep(3)
        elif btnclock.text.lower() == "clock in":
            if cin:
                logging.info("cl0cking 1n")
                if fakemode: return
                btnclock.click()
                time.sleep(3)
            else:
                logging.error("D1s s0m3 w31rd cr4p...")
                if fakemode: return
        elif t=="clock":
            logging.error("weeeeeiiiird")
            if fakemode: logging.info("4dv_u53r...")

    def logintoteam(self, t):
        tb = self.driver.find_element_by_id("txtCompanyName")
        self.type(tb, t)
        tb.send_keys(Keys.RETURN)
        logging.info("10gg3d_1n70_734m")

    def login(self, username, password):
        time.sleep(3)
        logging.info("logging into user")
        usernamebox = self.driver.find_element_by_id("txtUser")
        self.type(usernamebox, username)
        passwordbox = self.driver.find_element_by_id("txtPassword")
        self.type(passwordbox, password)

    def visit(self, site):
        success = False
        while not success:
            try:
                if self.driver is not None:
                    self.driver.get(site)
                    success = True
                else:
                    logging.info("No driver defined. Exiting.")
                    sys.exit(1)
            except UnexpectedAlertPresentException as (e, msg):
                logging.info("caught alert...")
                self.handlealert(e,msg)

    # untested
    def handlealert(self, e, msg=None):
        Alert(self.driver).dismiss()

def parse_options():
    parser = argparse.ArgumentParser(prog="clockinoutofparktime...", description="cl0ck5u1nn0u7...", add_help=True)
    parser.add_argument("-d", "--debug", action="store_true", help="Enable debug level logging. A toooon of stuff from selenium gets logged btw.")
    parser.add_argument("-v", "--verbose", action="store_true", help="Enable info level logging")
    parser.add_argument("-n", "--number", action="store", type=int, help="The number of searches to do.", default=200)
    parser.add_argument("-s", "--show", action="store_true", help="Shows the display")
    parser.add_argument("-c", "--config", action="store", help="Path to file with account info. default is ~/.ploprc")
    parser.add_argument("-i", "--clock-in", action="store_true", help="Means you wanna clock out", default=False)
    parser.add_argument("-f", "--engage-fake-mode", action="store_true", help="not found.", default=False)
    parser.add_argument("-q", "--shut-up-plock", action="store_true", help="quitemode", default=False)
    return parser.parse_args()

def configure_output(args):
    if args.shut_up_plock:
        logging.basicConfig(level=logging.CRITICAL)
    elif args.verbose:
        logging.basicConfig(level=logging.INFO)
    else:
        logging.basicConfig(level=logging.DEBUG if args.debug else logging.WARN)

def clock(args, account={}):
    site = account.get("site")
    username = account.get("username")
    password = account.get("password")
    team = account.get("team")

    if username == None or password == None or team == None or site == None:
        logging.error("No username or password or site or team provided")
        return

    bot = Bot(args.show)
    bot.visit(site)
    bot.logintoteam(team)
    bot.login(username, password)
    bot.clock(args.clock_in, args.engage_fake_mode)
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
