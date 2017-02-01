from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.common.exceptions import *
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.alert import Alert
from pyvirtualdisplay import Display
from selenium.webdriver.chrome.options import Options
import sys
import logging

from pdb import set_trace as bp

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
                btn = el
            elif el.text.lower() == "clocked in":
                btn = el
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
