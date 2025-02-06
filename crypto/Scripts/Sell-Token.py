import xrpl
from xrpl.clients import JsonRpcClient
from xrpl.wallet import Wallet
from xrpl.models.transactions import OfferCreate
from xrpl.models.amounts import IssuedCurrencyAmount
from xrpl.transaction import sign_and_submit
import argparse
import math


# PROOF WE ARE WORKING RIGHT

# Parse command-line arguments
parser = argparse.ArgumentParser(description="Sell a token for XRP on the XRP Ledger.")
parser.add_argument("TOKEN_ISSUER", help="Issuer address for the token")
parser.add_argument("TOKEN_CODE", help="Currency code for the token")
parser.add_argument("SELL_AMOUNT", type=float, help="Amount of the token to sell")
parser.add_argument("XRP_PRICE_PER_TOKEN", type=float, help="Price per token in XRP")
parser.add_argument("SECRET_NUMBERS", help="wallet secret numbers (it must look something like this '261821 261821 261821 261821 261821 261821 261821 261821')")
args = parser.parse_args()

# Setup - Define the XRPL Client
client = JsonRpcClient("https://s1.ripple.com:51234")  # Mainnet JSON-RPC endpoint

# Extract values from arguments
TOKEN_ISSUER = args.TOKEN_ISSUER
TOKEN_CODE = args.TOKEN_CODE
SELL_AMOUNT = str(args.SELL_AMOUNT)
XRP_PRICE_PER_TOKEN = args.XRP_PRICE_PER_TOKEN
XRP_PRICE_IN_DROPS = float(XRP_PRICE_PER_TOKEN * 1_000_000)

# Get wallet
secret_numbers = args.SECRET_NUMBERS
wallet = Wallet.from_secret_numbers(secret_numbers)
#print(wallet)

# Check for NaN and invalid values
if math.isnan(XRP_PRICE_IN_DROPS) or math.isnan(float(SELL_AMOUNT)):
    raise ValueError("XRP_PRICE_IN_DROPS or SELL_AMOUNT is NaN or invalid")

# Ensure both values are numeric and proceed
try:
    XRP_PRICE_IN_DROPS = float(XRP_PRICE_IN_DROPS)  # Ensure it's a float
    SELL_AMOUNT = float(SELL_AMOUNT)  # Ensure it's a float
      
    # Calculate total XRP in drops
    taker_pays = str(int(XRP_PRICE_IN_DROPS * SELL_AMOUNT))
    print(f"Taker pays: {taker_pays} drops")
except ValueError as e:
    print(f"Error: {e}")

# Define taker_pays as the amount of XRP you expect to receive
taker_pays = str(int(XRP_PRICE_IN_DROPS * float(SELL_AMOUNT)))  # Total XRP in drops

# Define taker_pays as an IssuedCurrencyAmount
taker_gets = IssuedCurrencyAmount(
    currency=TOKEN_CODE,
    issuer=TOKEN_ISSUER,
    value=SELL_AMOUNT
)

# Build an OfferCreate transaction
offer = OfferCreate(
    account=wallet.classic_address,
    taker_gets=taker_gets,
    taker_pays=taker_pays,
    flags=131072   # Sell offer
)

# Sign and submit the transaction
signed_tx = sign_and_submit(offer, client, wallet)

if "engine_result" in signed_tx.result:
    if signed_tx.result["engine_result"] == "tesSUCCESS":
        print(f"Transaction Result: {signed_tx.result['engine_result']}")
    else:
        print(f"Transaction failed or returned a different result: {signed_tx.result['engine_result']}")        
else:
    print("Transaction did not return 'engine_result'. Here is the full response:")
    print(signed_tx.result)

