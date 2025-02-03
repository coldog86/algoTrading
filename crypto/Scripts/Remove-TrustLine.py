import xrpl
from xrpl.clients import JsonRpcClient
from xrpl.wallet import Wallet
from xrpl.models.transactions import TrustSet
from xrpl.models.amounts import IssuedCurrencyAmount
from xrpl.transaction import sign_and_submit
import argparse

# Parse command-line arguments
parser = argparse.ArgumentParser(description="Remove a trust line on the XRP Ledger.")
parser.add_argument("ISSUER", help="Issuer address for the token")
parser.add_argument("CURRENCY_CODE", help="Currency code for the token")
parser.add_argument("SECRET_NUMBERS", help="wallet secret numbers (it must look something like this '261821 261821 261821 261821 261821 261821 261821 261821')")
args = parser.parse_args()

# Setup - Define the XRPL Client
client = JsonRpcClient("https://s1.ripple.com:51234")  # Mainnet JSON-RPC endpoint

# Get wallet (replace with actual secret or secure method)
secret_numbers = args.SECRET_NUMBERS
wallet = Wallet.from_secret_numbers(secret_numbers)

# Token details from arguments
ISSUER = args.ISSUER
CURRENCY_CODE = args.CURRENCY_CODE

# Fetch account info to get the sequence number
account_info = client.request(xrpl.models.requests.AccountInfo(account=wallet.classic_address))
sequence = account_info.result['account_data']['Sequence']

# Create the TrustSet transaction with a limit of zero to remove the trust line
trust_set_tx = TrustSet(
    account=wallet.classic_address,
    limit_amount=IssuedCurrencyAmount(
        currency=CURRENCY_CODE,
        issuer=ISSUER,
        value="0"
    ),
    fee="10",  # Transaction fee in drops
    sequence=sequence
)

# Sign and submit the transaction
signed_tx = sign_and_submit(trust_set_tx, client, wallet)

# Check the result
if signed_tx.result['engine_result'] == 'tesSUCCESS':
    print(f"Trust line successfully removed with hash: {signed_tx.result['tx_json']['hash']}")
else:
    print(f"Transaction failed with result: {signed_tx.result['engine_result_message']}")

