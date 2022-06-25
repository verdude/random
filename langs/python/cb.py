import json, hmac, hashlib, time, requests
from requests.auth import AuthBase
import os

# Before implementation, set environmental variables with the names API_KEY and API_SECRET
API_KEY = os.environ.get('COINBASE_API_KEY')
API_SECRET = os.environ.get('COINBASE_API_SECRET')
if not API_KEY or not API_SECRET:
    print("haha, bad")
    exit(1)

# Create custom authentication for Coinbase API
class CoinbaseWalletAuth(AuthBase):
    def __init__(self, api_key, secret_key):
        self.api_key = api_key
        self.secret_key = secret_key

    def __call__(self, request):
        timestamp = str(int(time.time()))
        message = timestamp + request.method + request.path_url + (request.body or '')
        signature = hmac.new(self.secret_key, message, hashlib.sha256).hexdigest()

        request.headers.update({
            'CB-ACCESS-SIGN': signature,
            'CB-ACCESS-TIMESTAMP': timestamp,
            'CB-ACCESS-KEY': self.api_key,
        })
        return request

api_url = 'https://api.coinbase.com/v2/'
auth = CoinbaseWalletAuth(API_KEY, API_SECRET)

r = requests.get(api_url + 'user', auth=auth)
print(r.json())
# {u'data': {u'username': None, u'resource': u'user', u'name': u'User'...

# Send funds
tx = {
    'type': 'send',
    'to': 'user@example.com',
    'amount': '10.0',
    'currency': 'USD',
}
r = requests.post(api_url + 'accounts/primary/transactions', json=tx, auth=auth)
print(r.json())
