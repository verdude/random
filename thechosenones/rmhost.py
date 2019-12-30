#!/usr/bin/env python3

import sys
import os
import logging
import argparse
import math

class Index:
    def __init__(self, value, upper_bound=math.inf):
        self.value = value
        self.i = self.value - 1
        self.set_valid(upper_bound)

    def format(self):
        return self.value

    def index(self):
        return self.i

    def set_valid(self, upper_bound):
        self.valid = self.i >= 0 and self.i < upper_bound

class Hosts:
    def __init__(self, path=None):
        if path:
            self.path = path
        else:
            self.path = os.path.expanduser("~/.ssh/known_hosts")
        self.lines = []
        self.modified = False

    def remove_host(self, name=None, line=None):
        if type(line) == int:
            line = Index(line, len(self.lines))
        elif type(line) == Index:
            pass
        else:
            logging.error("Invalid type for given line number: {}".format(line))
            sys.exit(1)

        if name:
            # remove by name
            logging.error("Remove by name not yet implemented.")
            sys.exit(1)
        if line.valid:
            self.lines.pop(line.index())
            self.modified = True
        else:
            logging.error("Invalid line number: {}".format(line.format()))
            sys.exit(1)

    def read_file(self):
        try:
            hosts_file = open(self.path, "r")
            self.lines = hosts_file.readlines();

        except:
            logging.error("failed to open/read {}".format(self.hosts))
            sys.exit(1)
        finally:
            hosts_file.close()

    def view(self):
        print("".join(self.lines))

    def save(self):
        if self.modified:
            try:
                hosts_file = open(self.path, "w")
                hosts_file.write("".join(self.lines))
            except:
                logging.error("Failed attempting to save modified hosts file.")
                sys.exit(1)
            finally:
                hosts_file.close()
        else:
            logging.warning("Not going to save unmodified file")

def parse_args():
    parser = argparse.ArgumentParser(prog="updates", description="Remove a line from known_hosts", add_help=True)
    parser.add_argument("-l", "--line", action="store", type=int, help="Removes the host on the given line number.")
    parser.add_argument("-n", "--name", action="store", help="Removes a host by its name.")
    parser.add_argument("-v", "--view", action="store_true", help="Prints out the hosts after updates have taken place.")
    parser.add_argument("-s", "--save", action="store_true", help="Writes the hosts back to the file if there has been an update.")
    return parser.parse_args()

if __name__ == "__main__":
    args = parse_args()
    hosts = Hosts()
    if args.line or args.name:
        hosts.read_file()
    else:
        sys.exit(0)
    hosts.remove_host(name=args.name, line=args.line)
    if args.view:
        hosts.view()
    if args.save:
        hosts.save()

