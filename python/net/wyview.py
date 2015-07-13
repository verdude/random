#! /usr/bin/python
# -*- coding: utf-8 -*-

"""
	Dependencies: BeautifulSoup from beautifulsoup4, requests
	Checks the BYU on campus housing page every minute to find if there are any
	available beds for men at wyview.
"""

def checkOnceMore():
	page = getPage()
	return parseInfo(page.text)

## specifically retrieves the string in the wyview men availability
## returns "goOn" as a continue flag
## returns the info if there are any beds available
def parseInfo(html):
	soup = BeautifulSoup(html.encode('utf-8'), 'html.parser')
	target = soup.find(id='ContentPlaceHolder1_RoomsPanel').findAll('table')[2].findAll('td')[1]
	[x.extract() for x in target.findAll('h3')]
	response = re.sub(r'\s+',' ', target.get_text()).strip()
	return "goOn" if response == 'No beds available.' else response

def getPage():
	return requests.get('http://www.byu.edu/housing/oncampushousing/bed/beds19plus.aspx?ap=156FaWi')

## Sends email via gmail
def notifyMeh(content, subject, from_, password, to, queries):
	"""
		Expected credentials:
			content=the text content of the email, string
			subject=the email subject, string
			from_=the outgoing email, string
			password=the outgoing email password, string
			to=the target emails, list of strings
			queries=the amount of time the getpage function was called, number
	"""
	import smtplib
	from email.mime.text import MIMEText

	msg = MIMEText(content + '\n\nchecked: %i times' % queries)

	msg['Subject'] = subject
	msg['From'] = from_
	msg['To'] = to if queries > 0 else 'santiago.verdu.01@gmail.com'

	s = smtplib.SMTP('smtp.gmail.com', 587)
	s.ehlo()
	s.starttls()
	s.login(from_, password)
	s.sendmail(msg['From'], msg['To'], msg.as_string())
	s.quit()

if __name__ == "__main__":
	import requests
	import time
	from bs4 import BeautifulSoup
	import re
	import sys
	import traceback

	# run the configuration parser
	# there must be a better way to import the file
	execfile('gluon.py')
	glue = Gluon()
	glue.loadAll(filepath = None)

	queries = 0
	args = None
	interval = lambda: int(glue.get("wyviewer.checks.interval"))
	notify = lambda: int(glue.get("wyviewer.checks.notify"))
	from_ = glue.get("wyviewer.email.from")
	password = glue.get("wyviewer.email.password")

	try:
		import argparse
		if len(sys.argv) > 1:
			parser = argparse.ArgumentParser()
			parser.add_argument("-e", "--emails", nargs=".+", help="enter email to send to and from")
			args = parser.parse_args();
		else:
			try:
				while checkOnceMore() == "goOn":
					time.sleep(interval())
					queries += 1
					print 'checked: %i times' % queries
					if queries % notify() == 0:
						break

				# here send the information in an email
				notifyMeh(content=checkOnceMore(), subject="found it bruh", to=args.emails,
					from_=from_, password=password, queries=queries)
			except:
				notifyMeh("Hi, thars an issue.\ncode:[73] query Failure. abort checkOnceMore. restart wyview",
					"script Broke",to=args.emails, from_=from_, password=password, queries=queries)

	except Exception, err:
		print "Something broke. Program Terminated."
		print(traceback.format_exc())