#!/usr/bin/env python

import argparse
import logging
import getpass
import traceback
import json
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
conffile = os.path.expanduser("~/.clockrc")

class Bot():
    def __init__(self, show):
        self.chromeDriverLocation = "./chromedriver"
        self.show = show
        if not self.show:
            self.display = Display(visible=0, size=(800, 600))
            self.display.start()
        else: self.display = None
        self.driver = webdriver.Chrome(self.chromeDriverLocation)

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

    def clock_p(self,cin):
        clocked = False
        inbtn = None
        outbtn = None
        anchors = []
        anchors = self.driver.find_elements_by_tag_name("a")
        for el in anchors:
            if el.text.lower() == "in":
                inbtn = el
            elif el.text.lower() == "clocked in":
                inbtn = el
                clocked = True
            elif el.text.lower() == "out":
                outbtn = el
            elif el.text.lower() == "clocked out":
                outbtn = el
                clocked = False

        # NAND of clocked in and clock in
        doingabad = (cin and clocked) or not (cin or clocked)
        if doingabad:
            logging.warn("YO DAWG UR TRYNA SCREW UP UR TIMECARD")
            sys.exit()

        if cin:
            logging.info("clocking in")
            inbtn.click()
        else:
            logging.info("clocking out")
            outbtn.click()

    def login(self, netid, passwd):
        self.driver.find_element_by_id("portalCASLoginLink").click()
        netidbox = self.driver.find_element_by_id("netid")
        self.type(netidbox, netid)
        passwordbox = self.driver.find_element_by_id("password")
        self.type(passwordbox, passwd)
        passwordbox.send_keys(Keys.RETURN)

    def maibyoodeeyou(self):
        success = False
        while not success:
            try:
                if self.driver is not None:
                    self.driver.get("https://my.byu.edu")
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
    bot.clock_p(args.clock_in)
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
