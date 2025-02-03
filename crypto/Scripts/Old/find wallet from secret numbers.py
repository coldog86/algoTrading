from xrpl.core.keypairs import derive_keypair
import xrpl
from xrpl.wallet import Wallet
from xrpl.core.keypairs import derive_classic_address

secret_key = "shfACzT559YWHtb1u4zyGyN5MewPR"
private_key_hex = "006667EAF9F431EE0735A283DF82D1FAD187FD143D34D3077962BC477BD85F99C0" # xumm
private_key_hex = "e3c59e9a014d9777a259743b6bd8695fb998afccf8d44c5a5311c7eb67c71df5" # trust wallet
mnemonic_phrase = "able monkey believe uphold toe before onion truck scout pigeon sort master bulk clerk spike keep unhappy dance juice property sketch draft roast parent" # xumm
mnemonic_phrase = "mammal eyebrow custom invest scorpion staff zero forest find february power brother" # trust wallet
secret_numbers = "261821 244950 228027 024930 002940 326313 427315 043170"

key_pair = derive_keypair(secret_key)
print(key_pair)

# Create wallet object using the private key
wallet = Wallet.from_secret_numbers(secret_numbers)
print(wallet)

# Derive the classic XRP address
# wallet_address = derive_classic_address(wallet.public_key)
    
# rint(wallet_address)


# # e3c59e9a014d9777a259743b6bd8695fb998afccf8d44c5a5311c7eb67c71df5