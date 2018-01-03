#!/usr/bin/env python

import os
import subprocess
import sys

def a(s1, s2):
    return s1.strip() + "/" + s2.strip()

class Annotator():
    def __init__(self, repos=".repos.txt"):
        if not os.environ.has_key("GITDIR"):
            print("GITDIR not defined.")
            sys.exit()
        self.gitdir = os.environ.get("GITDIR")
        self.f = repos
        self.commands = []
        self.home = ""

    def get_file(self):
        self.home = os.path.expanduser("~")
        if (os.path.isfile(a(self.home,self.f))):
            #get the file and save lines into var
            return True
        else:
            return False

    def get_remotes(self):
        n = open(os.devnull,"w")
        for repo in os.listdir(self.gitdir):
            os.chdir(a(os.environ.get("GITDIR"),repo))
            print("-----------------------------")
            try:
                remote_name = subprocess.check_output(["git", "remote"], stderr=n).strip("\n").strip(" ")
                if remote_name == "":
                    continue
                remote_url = subprocess.check_output(["git", "remote", "get-url", "--all", remote_name], stderr=n).strip("\n").strip(" ")
                self.commands.append("git clone %s %s" % (remote_url, repo))
                print(repo)
            except Exception, e:
                print("broke on %s" % repo)
                print(str(e))
        n.close()

    def update_file(self):
        print("=============================")
        if self.ex:
            with open(a(self.home,self.f), "r") as repo_file:
                l = repo_file.readlines()
        else:
            l = []
        for x in l:
            print("-----------------------------")
            x = x.strip(" ").strip("\n")
            if x == "":
                continue
            repo = x.split(" ")[2]
            if repo not in map(lambda s: s.split(" ")[2], self.commands):
                print("[%s] not currently cloned" % x)
                self.commands.append(x)
        with open(a(self.home,self.f), "w") as repo_file:
            repo_file.write("\n".join(self.commands)+"\n")

    def annotate(self):
        self.ex = self.get_file()
        self.get_remotes()
        self.update_file()

if __name__ == "__main__":
    Annotator().annotate()

