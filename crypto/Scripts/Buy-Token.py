import xrpl
import argparse
from xrpl.clients import JsonRpcClient
from xrpl.wallet import Wallet
from xrpl.models.transactions import OfferCreate
from xrpl.models.amounts import IssuedCurrencyAmount
from xrpl.transaction import sign_and_submit

# Setup command-line argument parsing
parser = argparse.ArgumentParser(description='Create an XRP OfferCreate transaction.')
parser.add_argument('--xrp_amount', type=float, required=True, help='Amount of XRP to spend.')
parser.add_argument('--token_amount', type=str, required=True, help='Amount of the token to receive.')
parser.add_argument('--token_issuer', type=str, required=True, help='Issuer of the token.')
parser.add_argument('--token_code', type=str, required=True, help='Token code (currency).')
parser.add_argument("SECRET_NUMBERS", help="wallet secret numbers (it must look something like this '261821 261821 261821 261821 261821 261821 261821 261821')")
args = parser.parse_args()

# Setup - Define the XRPL Client
client = JsonRpcClient("https://s1.ripple.com:51234")  # Mainnet JSON-RPC endpoint

# Get wallet
secret_numbers = args.SECRET_NUMBERS
wallet = Wallet.from_secret_numbers(secret_numbers)
#print(wallet)

# Set the parameters from the command line arguments
XRP_AMOUNT = args.xrp_amount
TOKEN_AMOUNT = args.token_amount
TOKEN_ISSUER = args.token_issuer
TOKEN_CODE = args.token_code

XRP_AMOUNT_IN_DROPS = str(int(XRP_AMOUNT * 1_000_000))  # Convert XRP amount to drops

# Define taker_pays as an IssuedCurrencyAmount
taker_pays = IssuedCurrencyAmount(
    currency=TOKEN_CODE,
    issuer=TOKEN_ISSUER,
    value=TOKEN_AMOUNT
)

# Build an OfferCreate transaction
offer = OfferCreate(
    account=wallet.classic_address,
    taker_gets=XRP_AMOUNT_IN_DROPS,
    taker_pays=taker_pays,
    flags=65536  # Optional flags: 131072 for sell offers, 65536 for buy, 0 for regular offer (buy or sell depending on other parameters)
)

# Sign and submit the transaction
signed_tx = sign_and_submit(offer, client, wallet)

#print(signed_tx.result)




if "engine_result" in signed_tx.result:
    if signed_tx.result["engine_result"] == "tesSUCCESS":
        print(f"Transaction Result: {signed_tx.result['engine_result']}")
        gets = signed_tx.result['tx_json']['TakerGets']
        pays = signed_tx.result['tx_json']['TakerPays']['value']

        xrp_value = int(gets) / 1_000_000
        buy_price = float(pays) / xrp_value

        print(f"BuyPrice = {buy_price:.12f}")
        
    else:
        print(f"Transaction failed or returned a different result: {signed_tx.result['engine_result']}")
        print(signed_tx.result)
else:
    print("Transaction did not return 'engine_result'. Here is the full response:")
    print(signed_tx.result)

