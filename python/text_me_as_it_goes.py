from twilio.rest import TwilioRestClient
import os
import time

class JohnUpdate():
	def __init__(self, filename):
		self.filename = filename
		self.loop()
		self.accountId = 
		self.auth_token

	def status(self):
		res = os.system("john --show %s" % self.filename)
		return res

	def check(self):
		

	def loop(self):
		while True:
			time.sleep(60)
			if self.check():

	def senf_text(self):
		

def parse_options():
    parser = argparse.ArgumentParser(prog="updates", description="Thingie", add_help=True)
    parser.add_argument("-d", "--debug", action="store_true", help="Turn on logging")
    return parser.parse_args()

if __name__ == "__main__":
	args = parse_options()
	u = JohnUpdate()

