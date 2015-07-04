#! /usr/bin/python
# -*- coding: utf-8 -*-

def checkOnceMore():
	page = getPage()
	return parseInfo(page.text)

def parseInfo(html):
	soup = BeautifulSoup(html.encode('utf-8'), 'html.parser')
	target = soup.find(id='ContentPlaceHolder1_RoomsPanel').findAll('table')[2].findAll('td')[1]
	[x.extract() for x in target.findAll('h3')]
	response = re.sub(r'\s+',' ', target.get_text()).strip()
	return "goOn" if response == 'No beds available.' else response

def getPage():
	return requests.get('http://www.byu.edu/housing/oncampushousing/bed/beds19plus.aspx?ap=156FaWi')

def notifyMeh(content, subject, email, password, queries):
	import smtplib
	from email.mime.text import MIMEText

	msg = MIMEText(content + '\n\nchecked: %i times' % queries)

	msg['Subject'] = subject
	msg['From'] = email
	msg['To'] = email if queries > 0 else 'santiago.verdu.01@gmail.com'

	s = smtplib.SMTP('smtp.gmail.com', 587)
	s.ehlo()
	s.starttls()
	s.login(email, password)
	s.sendmail(msg['From'], msg['To'], msg.as_string())
	s.quit()

if __name__ == "__main__":
	import requests
	import time
	from bs4 import BeautifulSoup
	import re
	import sys

	queries = 0

	try:
		import argparse
		if sys.argv[2]:
			parser = argparse.ArgumentParser()
			parser.add_argument("-e", "--email", help="enter email to send to and from")
			parser.add_argument("-p", "--password", help="The password for the email")
			args = parser.parse_args();

			while checkOnceMore() == "goOn":
				time.sleep(60)
				queries += 1
				print 'checked: %i times' % queries
				if queries % 240 == 0:
					notifyMeh("routine update", "updation", args.email, args.password, queries)

			# here send the information in an email
			notifyMeh(checkOnceMore(), "found it bruh", args.email, args.password, queries)
	except:
		notifyMeh("Hi, thars an issue.\ncode:[73] query Failure. abort checkOnceMore. restart wyview",
			"script Broke", "wyviewchecker@gmail.com", "lovethestruggle", queries)
		print "specify email and password plis"