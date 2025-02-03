from xrpl.wallet import Wallet

# Replace this with your XRP family seed
family_seed = "209f87643c0c8c3a7d0e888ff89909b11a04633dd04c6516fae89da46021687c4f4f0d086c35e0c35daa54dfde0463321abb6554a02c22a8ab7762166ffff4dd"

# Create a wallet from the family seed
wallet = Wallet.from_seed(family_seed)

# Access the secret key and public key
secret_key = wallet.seed  # This is the secret key (family seed)
public_key = wallet.public_key

# Print the keys
print("Secret Key:", secret_key)
print("Public Key:", public_key)