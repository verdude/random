#!/usr/bin/env python3

import re

"""
	Used to change c style variable names (names with underscores) to camel case
	A different version is stored in the
"""
def autoSubTest(path):
	c_style = re.compile('\\_+[a-zA-Z0-9]')
	lines = []
	try:
		with open(path) as thing:
			lines = thing.readlines()
		with open("Santi.java", "w") as test:
			for line in lines:
				test.write(c_style.sub("TEST", line))
	except:
		print "Failed to open file: ", path

class cToCam:
	lines = []
	dictionaryName = ""
	dictionary = []
	affirmative = [
		"yes", "y", "yas", "uhuh", "yessir", "yesm", "yup", "affirmative", "hai", "yea", "ye", "yay"
	]
	negative = [
		"no", "n", "nope", "nosir", "no sir", "never", "not", "negative", "nah", "nay"
	]
	match = re.compile('\\_+[a-zA-Z0-9]')

	def __init__(self, path):
		lines = open(path).readlines()
		self.path = path

	def convert(self, var):
		res = []
		tsugi = False
		for s in var:
			if tsugi:
				if s == "_":
					tsugi = True
				else:
					res.append(s.upper())
					tsugi = False
				continue
			if s == "_":
				tsugi = True
			else:
				res.append(s)
				tsugi = False
		return "".join(res)

	def addToDictionary(self, string):
		cToCam.dictionary.append(string)

	def check(self, ans, first=True):
		if ans in cToCam.affirmative:
			return True
		elif ans in cToCam.negative:
			return False
		else:
			if not first:
				return False
			return self.check(raw_input("Come Again? ").strip().lower(), False)

	def query(self, line):
		print "Change: ", line
		if (self.check(raw_input("[y/n] ").strip().lower())):
			new = self.convert(line)
			self.addToDictionary(new)
			return new
		else: return line

	def run(self, out):
		with (open(out, "w") if out is not None else open("def.txt", "w")) as f:
			print len(cToCam.lines)
			for line in cToCam.lines:
				if len(cToCam.match.findall(line)) > 0:
					f.write(self.query(line))

if __name__ == "__main__":
	import sys
	import argparse
	try:
		if sys.argv[1]:
			parser = argparse.ArgumentParser()
			parser.add_argument("-f", "--file", help="Filepath to plain text file.")
			args = parser.parse_args();
			# do some testing to make sure filepath is legit.
			#run(args.file)
	except:
		print "No Arg Given - Using C:\\Users\\Santi\\Documents\\GitHub\CS_240\\recordindexer\\src\\client\\synchronizer\\BatchState.java"
		filepaf = "C:\\Users\\Santi\\Documents\\GitHub\\CS_240\\recordindexer\\src\\client\\synchronizer\\BatchState.java"
		test = cToCam(filepaf)
		test.run("Santi.java")
