#! /usr/bin/python
# -*- coding: utf-8 -*-
	
class Gluon:
	"""
		Gets the info from the secrets.sv file or whatever configuration file you give it.
		Only designed to work with the .sv configuration syntax.
	"""
	conf = {}

	def loadAll(self, filepath):
		for line in open(filepath if filepath else 'secrets.sv', 'r').readlines():
			line = line.strip()
			if not line.startswith('#') and len(line)>1:
				(obj, val) = line.rstrip().split('=', 1)
				Gluon.conf[obj] = val

	def get(self, thingie):
		"""get somethingie from the conf dictionary"""
		return self.conf[thingie]