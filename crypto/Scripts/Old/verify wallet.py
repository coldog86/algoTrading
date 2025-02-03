import xrpl
from xrpl.clients import JsonRpcClient
from xrpl.wallet import Wallet
from xrpl.models.transactions import OfferCreate
from xrpl.transaction import sign_and_submit, submit_and_wait

# Note function names were changed in v2
# send_reliable_submission > submit_and_wait
# safe_sign_and_submit_transaction > sign_and_submit 
# https://xrpl.org/blog/2023/xrpl-py-2.0-release#simplified-signing/submitting-functions

secret_key = "shfACzT559YWHtb1u4zyGyN5MewPR"
private_key_hex = "006667EAF9F431EE0735A283DF82D1FAD187FD143D34D3077962BC477BD85F99C0" # xumm
private_key_hex = "e3c59e9a014d9777a259743b6bd8695fb998afccf8d44c5a5311c7eb67c71df5" # trust wallet
mnemonic_phrase = "able monkey believe uphold toe before onion truck scout pigeon sort master bulk clerk spike keep unhappy dance juice property sketch draft roast parent" # firstLedger (main)
mnemonic_phrase = "library empty pencil damage able goose radar silver letter worry emerge lizard scale height member cloth region agent anxiety body cloth scene story modify" # firstLedger
mnemonic_phrase = "ketchup buyer tennis survey dirt skill mule seek approve nation gravity sight glue syrup home animal aisle emotion lonely science empty neglect axis priority" # firstLedger
mnemonic_phrase = "mammal eyebrow custom invest scorpion staff zero forest find february power brother" # trust wallet
secret_numbers = "261821 244950 228027 024930 002940 326313 427315 043170" # xumm

# Setup - Define the XRPL Client for Mainnet
client = JsonRpcClient("https://s1.ripple.com:51234")  # Mainnet JSON-RPC endpoint

# Define your wallet's credentials (Replace with an actual seed)
seed = "4eba2dcc1b305c67f6cc5178fda5a52e46077f95de869d3eac729298447dda4b"  # Replace with your actual secret seed

wallet = Wallet.from_secret(seed)
print(wallet)