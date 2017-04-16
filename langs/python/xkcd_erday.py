#!/usr/bin/env python

import argparse
import logging
from bs4 import BeautifulSoup
import requests

class Comic():
    def __init__(self):
        pass
    def link(self):
        r = requests.get("http://xkcd.com")
        soup = BeautifulSoup(r.content, "html.parser")
        imgs = soup.find_all("img")
        links = [img.get("src") for img in imgs if img.get("src").find("comics") != -1]
        return "http:" + links[0]
        

def pargs():
    parser = argparse.ArgumentParser(prog="Comic", description="get xkcd comic from homepage", add_help=True)
    parser.add_argument("-v", action="store_true", help="Verbose mode.")
    return parser.parse_args()

if __name__ == "__main__":
    args = pargs()
    level = logging.INFO if args.v else logging.ERROR
    logging.basicConfig(level=level)
    print Comic().link()

