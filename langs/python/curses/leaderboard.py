#!/usr/bin/env python3

import curses
import curses.textpad
import time
import binascii

import logging

class Leaderboard():
    def __init__(self,log=False):
        height = self.calcheight()
        width = self.calcwidth()
        if log:
            logging.basicConfig(level=logging.DEBUG, filename="lb.log")
            self.lg = logging.getLogger("Leaderboard")
        self.lg.debug("height set: [%s] width set: [%s]" % (height, width))
        self.lg.debug("Has colors: [%s]" % str(curses.has_colors()))
        self.win = curses.newwin(height, width, 1, 2)

    def calcheight(self):
        h = curses.LINES - 2    
        return h

    def calcwidth(self):
        w = curses.COLS - 4
        return w

    def addch(self,string):
        self.win.addstr(string)
        self.win.refresh()

    def readch(self):
        c = self.win.getch()
        return chr(c)

