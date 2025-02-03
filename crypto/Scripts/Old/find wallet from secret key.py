from xrpl.wallet import Wallet

# Replace with your XRP secret key (family seed)
secret_key = "shfACzT559YWHtb1u4zyGyN5MewPR"
address = "rDXgW8ZdcPwmSzEzK7s45V6xeSwuwgiVYG"

# Create the wallet from the secret key (family seed)
wallet = Wallet.from_seed(secret_key)
print(wallet)

# Output the generated wallet information
print(f"Secret Key: {wallet.seed}")
print(f"XRP Address: {wallet.classic_address}")
print(f"Public Key: {wallet.public_key}")



