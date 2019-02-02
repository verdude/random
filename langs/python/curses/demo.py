#!/usr/bin/env python

import curses
import curses.textpad
import time
from curses import wrapper
from leaderboard import Leaderboard

def main(stdscr):
    lb = Leaderboard(True)
    while 1:
        lb.addch(lb.readch())
        stdscr.addstr(0, 0, "Current mode: Typing mode",
              curses.A_REVERSE)
    time.sleep(49)

try:
    stdscr = curses.initscr()
    curses.noecho()
    stdscr.keypad(True)
    wrapper(main)
except KeyboardInterrupt:
    pass
finally:
    stdscr.keypad(False)
    curses.echo()
    curses.endwin()

