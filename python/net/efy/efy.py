#! /usr/bin/python
# -*- coding: utf-8 -*-

"""
	Dependencies:
		selenium: sudo pip install selenium
		phantomjs: sudo apt-get install phantomjs
"""

### Global url to visit
url = "http://cereg.byu.edu/o3/user/registration/initialize/?product_id=10084548&enrollLocation=user"

## Sends email via gmail
def sendEmail(args):
	"""
		Expected credentials:
			content=the text content of the email, string
			subject=the email subject, string
			from=the outgoing email, string
			password=the outgoing email password, string
			to=the target emails, list of strings
			queries=the amount of time the getpage function was called, number
	"""
	import smtplib
	from email.mime.text import MIMEText

	msg = MIMEText(args["content"] + '\n\nchecked: %i times' % args["queries"])

	msg['Subject'] = args["subject"]
	msg['From'] = args["from"]

	s = smtplib.SMTP('smtp.gmail.com', 587)
	s.ehlo()
	s.starttls()
	s.login(args["from"], args["password"])
	s.sendmail(msg['From'], args["to"], msg.as_string())
	s.quit()

def findSessions(d):
	#d=webdriver
	sections = {}
	sections["a"] = d.find_element(By.ID, 'section_10085041')
	sections["b"] = d.find_element(By.ID, 'section_10085051')
	return sections

def login(d, username, password):
	#d=webdriver
	d.find_element(By.ID, 'user_id').send_keys(username)
	d.find_element(By.ID, 'password').send_keys(password)
	d.find_element(By.ID, 'loginSubmitBtn').submit()

def available(d):
	soup = BeautifulSoup(d.page_source.encode('utf-8'), 'html.parser')
	if int(str(soup.find(id='section_10085041').findAll('td')[3].decode_contents(formatter="html")).strip()) > 0:
		return "section_10085041"
	if int(str(soup.find(id='section_10085051').findAll('td')[3].decode_contents(formatter="html")).strip()) > 0:
		return "section_10085051"
	return "none"

def addToCart(d, sessionId):
	d.find_element_by_xpath("//tr[@id='%s']/td[5]/div/button[1]" % sessionId).click()

def navigate(emailArgs, creds):
	#doesn't work without --ssl-protocol=any
	driver = webdriver.PhantomJS(service_args=['--ignore-ssl-errors=true', "--ssl-protocol=any"])
	driver.get(url)
	#print driver.page_source
	print "Got the page Source. Queries: %i" % emailArgs["queries"]
	try:
		login(d=driver, username=creds["username"], password=creds["password"])
	except Exception, e:
		print "Could not login."
		print traceback.format_exc()
		return "none"

	sections = {}
	sessionId = ""
	try:
		sections = findSessions(d=driver)
	except Exception, e:
		print "Could not find sessions."
		print traceback.format_exc()
		return "none"

	try:
		sessionId = available(driver)
		if sessionId != "none":
			emailArgs["content"] = "There is one free for: %s %s" % (sessionId, url)
			emailArgs["subject"] = "Santi Found an opening in the efy thing"
			sendEmail(emailArgs)
			addToCart(driver, sessionId)
	except Exception, e:
		print "Failed Checking Availability or adding to cart"
		print traceback.format_exc()
		return "none"

	#exit the connection
	driver.close()
	return sessionId

def main(emails):
	pollInterval = int(glue.get("efy.checks.pollInterval"))
	emailArguments = {
		"content": "",
		"subject": "",
		"from": glue.get("efy.email.from"),
		"password": glue.get("efy.email.password"),
		"to": emails,
		"queries": 0
	}
	credentials = {
		"username": glue.get("efy.credentials.username"),
		"password": glue.get("efy.credentials.password")
	}
	while navigate(emailArguments, credentials) == "none":
		time.sleep(pollInterval)
		emailArguments["queries"] += 1
		if emailArguments["queries"] % 60 == 0:
			emailArguments["content"] = "Just An Update\n\n%s" % (url)
			emailArguments["subject"] = "Just An Update"
			sendEmail(emailArguments)

	emailArguments["content"] = "Exiting program"
	emailArguments["subject"] = "The Program is done. Check %s for vacancies." % (url)
	sendEmail(emailArguments)

if __name__ == '__main__':
	try:
		import time
		import argparse
		import sys
		from selenium import webdriver
		from bs4 import BeautifulSoup
		from selenium.webdriver.common.by import By
		from selenium.webdriver.support import expected_conditions as EC
		from selenium.webdriver.common.desired_capabilities import DesiredCapabilities
		from selenium.webdriver.common.keys import Keys

		import traceback

		execfile('gluon.py')
		glue = Gluon()
		glue.loadAll(filepath = None)

		usage = "USAGE:\npython -u wyview.py -e emails**"
		if len(sys.argv) > 1:
			# if the -e flag was given, argv will contain:
			# ["wyview.py", "-e", "emails**"]
			parser = argparse.ArgumentParser()
			parser.add_argument("-e", "--emails", nargs="+", help="enter email to send to and from")
			args = parser.parse_args();
		else:
			print usage
			sys.exit(0)

		main(args.emails)
	except Exception, e:
		print traceback.format_exc()
		test = open("error.log", "w")
		test.write(traceback.format_exc())
		test.close()