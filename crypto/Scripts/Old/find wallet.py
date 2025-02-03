import xrpl
from xrpl.clients import JsonRpcClient
from xrpl.models.requests.account_info import AccountInfo
from xrpl.models.requests.account_info import AccountInfo as AccountInfoResponse

# The address you want to check (replace with the actual XRP address)
xrp_address = "rDXgW8ZdcPwmSzEzK7s45V6xeSwuwgiVYG"

# Connect to the XRP mainnet server
client = JsonRpcClient("https://s2.ripple.com:51234/")  # Mainnet JSON-RPC server

# Prepare the request
request = AccountInfo(
    account=xrp_address,
    strict=True,
    ledger_index="validated",
)

# Send the request and get the response
response = client.request(request)
print(response)
# Check the response
if isinstance(response, AccountInfoResponse) and 'account_data' in response.result:
    # If the wallet exists, print its balance
    balance = response.result["account_data"]["Balance"]
    print(f"Balance for account {xrp_address}: {balance} drops")
else:
    print(f"Could not find the wallet for address: {xrp_address}")