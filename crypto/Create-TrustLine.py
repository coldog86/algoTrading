import xrpl
from xrpl.wallet import Wallet
from xrpl.models.transactions import TrustSet
from xrpl.models.amounts import IssuedCurrencyAmount
from xrpl.transaction import sign_and_submit
from xrpl.clients import JsonRpcClient
import argparse

# Set up command-line arguments
parser = argparse.ArgumentParser(description="Create a TrustSet transaction on the XRP Ledger.")
parser.add_argument("issuer", help="Issuer address for the token")
parser.add_argument("currency_code", help="Currency code for the token")
parser.add_argument("trust_limit", help="Trust limit to set")
args = parser.parse_args()

# Configuration
client = JsonRpcClient("https://s1.ripple.com:51234")  # Mainnet JSON-RPC endpoint

# Get wallet (replace with actual secret numbers or method to get it securely)
secret_numbers = "261821 244950 228027 024930 002940 326313 427315 043170"
wallet = Wallet.from_secret_numbers(secret_numbers)

# Token details from arguments
issuer = args.issuer
currency_code = args.currency_code
trust_limit = args.trust_limit

# Fetch account info to get the sequence number
account_info = client.request(xrpl.models.requests.AccountInfo(account=wallet.classic_address))
sequence = account_info.result['account_data']['Sequence']

# Create the TrustSet transaction
trust_set_tx = TrustSet(
    account=wallet.classic_address,
    limit_amount=IssuedCurrencyAmount(
        currency=currency_code,
        issuer=issuer,
        value=trust_limit
    ),
    fee="10",  # Transaction fee in drops
    #flags=xrpl.models.transactions.TrustSetFlag.tfSetNoRipple, # Disable rippling
    flags=xrpl.models.transactions.TrustSetFlag.TF_SET_NO_RIPPLE,
    sequence=sequence
)

# Sign and submit the transaction
response = sign_and_submit(trust_set_tx, client, wallet)

# Check the result
if response.result['engine_result'] == 'tesSUCCESS':
    print(f"Trust line successfully established with hash: {response.result['tx_json']['hash']}")
else:
    print(f"Transaction failed with result: {response.result['engine_result_message']}")
