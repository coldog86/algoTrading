


function init(){
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/coldog86/algoTrading/refs/heads/Beta/crypto/Scripts/CryptoModule.psm1" -OutFile "CryptoModule.psm1"
    Import-Module .\CryptoModule.psm1 -Force
    # Create folders and files
    Create-FolderStructure
    Create-PythonScripts
    Create-GoBabyGoScript
    Create-DefaultConfigs -Branch 'Beta' -FileName 'stops.csv'
    Create-DefaultConfigs -Branch 'Beta' -FileName 'buyConditions.csv'
    Create-Doco -Branch 'Beta' -FileName 'ReadMe.txt'
    Create-Doco -Branch 'Beta' -FileName 'RoadMap.txt'
}
function Create-DefaultConfigs(){
    param (
        [Parameter(Mandatory = $false)][string] $Branch = 'main',
        [Parameter(Mandatory = $true)][string] $FileName
    )
    Write-Host "Creating default configs ($($fileName))"
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/coldog86/algoTrading/refs/heads/$($branch)/crypto/config/$($fileName)" -OutFile "config\default\$($fileName)"   
}

function Create-Doco(){
    param (
        [Parameter(Mandatory = $false)][string] $Branch = 'main',
        [Parameter(Mandatory = $true)][string] $FileName
    )
    Write-Host "Creating $($fileName) file"
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/coldog86/algoTrading/refs/heads/$($branch)/crypto/Doco/$($fileName)" -OutFile "Doco\$($fileName)"   
}

function Create-FolderStructure(){

    mkdir config
    mkdir config\default
    mkdir Doco
    mkdir Log
    mkdir Scripts
    mkdir temp
}

function Set-WalletAddress(){
    param (
        [Parameter(Mandatory = $true)][string] $WalletAddress,
        [Parameter(Mandatory = $false)][string] $FilePath = "./config/config.txt"
    )
    Write-Host "Wallet Address set to $($walletAddress)"
    
    $configContent = Get-Content -Path $filePath -Raw

    # Check if walletSecret is present
    if ($configContent -like "walletAddress:*") { 
        # Replace existing walletSecret
        $configContent = $configContent -replace "^walletAddress: .+", "walletAddress: $walletAddress"
    } else {
        # Append walletSecret if not found
        $configContent += "`nwalletAddress: $walletAddress"
    }
}

function Get-WalletAddress(){
    param (
        [Parameter(Mandatory = $false)][string] $FilePath = "./config/config.txt"
    )
        
    $config = Get-Content -Path $filePath
    foreach($line in $config){
        if($line -like "walletAddress:*"){
            $walletAddress = $line.Split(': ')[2]
            Write-Host "Wallet address = $($walletAddress)" -ForegroundColor Green
            return $walletAddress
        }
    }    
}

function Create-PythonScripts(){
    Write-Host "Creating python scripts" -ForegroundColor Green
    Create-BuyTokenScript
    Create-SellTokenScript
    Create-CreateTrustLineScript
    Create-RemoveTrustLineScript
}

function Get-Config(){
    param (
        [Parameter(Mandatory = $false)][string] $FilePath = "./config/config.txt"
    )

    Get-WalletAddress -FilePath $FilePath
    Get-WalletSecret -FilePath $FilePath
    Get-Offset -FilePath $FilePath  
    Get-UserTelegramGroup -FilePath $FilePath  
    Get-AdminTelegramGroup -FilePath $FilePath   
}

function Set-UserTelegramGroup(){
    param (
        [Parameter(Mandatory = $true)][string] $UserTelegramGroup,
        [Parameter(Mandatory = $false)][string] $FilePath = "./config/config.txt"
    )


    $configContent = Get-Content -Path $filePath -Raw

    # Check if walletSecret is present
    if ($configContent -like "userTelegramGroup:*") { 
        # Replace existing walletSecret
        $configContent = $configContent -replace "^userTelegramGroup: .+", "userTelegramGroup: $userTelegramGroup"
    } else {
        # Append walletSecret if not found
        $configContent += "`nuserTelegramGroup: $userTelegramGroup"
    }
}

function Get-UserTelegramGroup() {
    param (
        [Parameter(Mandatory = $false)][string] $FilePath = "./config/config.txt"
    )
        
    $config = Get-Content -Path $filePath
    foreach($line in $config){
        if($line -like "userTelegramGroup:*"){
            $userTelegramGroup = $line.Split(': ')[2]
            Write-Host "User Telegram Group = $($userTelegramGroup)" -ForegroundColor Green
            return $userTelegramGroup
        }
    }
}

function Set-AdminTelegramGroup(){
    param (
        [Parameter(Mandatory = $true)][string] $AdminTelegramGroup,
        [Parameter(Mandatory = $false)][string] $FilePath = "./config/config.txt"
    )
    
    $configContent = Get-Content -Path $filePath -Raw

    # Check if walletSecret is present
    if ($configContent -like "adminTelegramGroup:*") { 
        # Replace existing walletSecret
        $configContent = $configContent -replace "^adminTelegramGroup: .+", "adminTelegramGroup: $adminTelegramGroup"
    } else {
        # Append walletSecret if not found
        $configContent += "`nadminTelegramGroup: $adminTelegramGroup"
    }
}

function Get-AdminTelegramGroup() {
    param (
        [Parameter(Mandatory = $false)][string] $FilePath = "./config/config.txt"
    )
        
    $config = Get-Content -Path $filePath
    foreach($line in $config){
        if($line -like "adminTelegramGroup:*"){
            $adminTelegramGroup = $line.Split(': ')[2]
            Write-Host "Admin Telegram Group = $($adminTelegramGroup)" -ForegroundColor Green
            return $adminTelegramGroup
        }
    }
}


function Set-StandardBuy(){
    param (
        [Parameter(Mandatory = $true)][string] $StandardBuy,
        [Parameter(Mandatory = $false)][string] $FilePath = "./config/config.txt"
    )


    $configContent = Get-Content -Path $filePath -Raw

    # Check if walletSecret is present
    if ($configContent -like "standardBuy:*") { 
        # Replace existing walletSecret
        $configContent = $configContent -replace "^standardBuy: .+", "standardBuy: $standardBuy"
    } else {
        # Append walletSecret if not found
        $configContent += "`nstandardBuy: $standardBuy"
    }
}

function Get-StandardBuy() {
    param (
        [Parameter(Mandatory = $false)][string] $FilePath = "./config/config.txt"
    )
        
    $config = Get-Content -Path $filePath
    foreach($line in $config){
        if($line -like "standardBuy:*"){
            $standardBuy = $line.Split(': ')[2]
            Write-Host "Standard buy = $($standardBuy)" -ForegroundColor Green
            return $standardBuy
        }
    }
}


function Set-Offset(){
    param (
        [Parameter(Mandatory = $true)][string] $Offset,
        [Parameter(Mandatory = $false)][string] $FilePath = "./config/config.txt"
    )


    $configContent = Get-Content -Path $filePath -Raw

    # Check if walletSecret is present
    if ($configContent -like "offset:*") { 
        # Replace existing walletSecret
        $configContent = $configContent -replace "^offset: .+", "offset: $offset"
    } else {
        # Append walletSecret if not found
        $configContent += "`noffset: $offset"
    }
}

function Get-Offset() {
    param (
        [Parameter(Mandatory = $false)][string] $FilePath = "./config/config.txt"
    )
        
    $config = Get-Content -Path $filePath
    foreach($line in $config){
        if($line -like "offset:*"){
            $offset = $line.Split(': ')[1]
            Write-Host "Offset = $($offset)" -ForegroundColor Green
            return $offset
        }
    }
}

function Set-WalletSecret {
    param (
        [Parameter(Mandatory = $true)][string] $SecretNumbers,
        [Parameter(Mandatory = $false)][string] $FilePath = "./config/config.txt"
    )

    if ($secretNumbers -notmatch "^([0-9]{6} )*[0-9]{6}$") {
        Write-Host "Error: Secret format is incorrect!" -ForegroundColor Red
        return
    }
    
    # Ensure the directory exists
    $directory = Split-Path -Path $filePath -Parent
    if (-Not (Test-Path $directory)) {
        New-Item -ItemType Directory -Path $directory -Force 
    }
    # Convert to Base64
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($secretNumbers)
    $encodedSecret = [Convert]::ToBase64String($bytes)

    
    # Read the content of the config file
    $configContent = Get-Content -Path $filePath -Raw

    # Check if walletSecret is present
    if ($configContent -like "walletSecret:*") { 
        # Replace existing walletSecret
        $configContent = $configContent -replace "^walletSecret: .+", "walletSecret: $encodedSecret"
    } else {
        # Append walletSecret if not found
        $configContent += "`nwalletSecret: $encodedSecret"
    }

    # Save the updated content back to the file
    $configContent | Set-Content -Path $filePath
    Write-Host "Secret has been encrypted and saved successfully." -ForegroundColor Green
}

function Get-WalletSecret {
    param (
        [Parameter(Mandatory = $false)][string] $FilePath = "./config/config.txt"
    )

    # Ensure the file exists
    if (-Not (Test-Path $filePath)) {
        Write-Host "Error: config.txt not found!" -ForegroundColor Red
        return
    }

     
    $config = Get-Content -Path $filePath
    foreach($line in $config){
        if($line -like "walletSecret:*"){ 
            Write-Host $line -ForegroundColor cyan
            $encodedSecret = $line.Split(': ')[2]  
        }
    }
    # Decode Base64
    try {
        $bytes = [Convert]::FromBase64String($encodedSecret)
        $decodedSecret = [System.Text.Encoding]::UTF8.GetString($bytes)
    } catch {
        Write-Host "Error: Invalid Base64 string!" -ForegroundColor Red
    }
}



function Set-TelegramToken {
    param (
        [Parameter(Mandatory = $true)][string] $TelegramToken,
        [Parameter(Mandatory = $false)][string] $FilePath = "./config/config.txt"
    )

    # Convert to Base64
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($telegramToken)
    $encodedSecret = [Convert]::ToBase64String($bytes)

    
    # Read the content of the config file
    $configContent = Get-Content -Path $filePath -Raw

    # Check if walletSecret is present
    if ($configContent -like "telegramToken:*") { 
        # Replace existing walletSecret
        $configContent = $configContent -replace "^telegramToken: .+", "telegramToken: $encodedSecret"
    } else {
        # Append walletSecret if not found
        $configContent += "`ntelegramToken: $encodedSecret"
    }

    # Save the updated content back to the file
    $configContent | Set-Content -Path $filePath
    Write-Host "Secret has been encrypted and saved successfully." -ForegroundColor Green
}

function Get-TelegramToken {
    param (
        [Parameter(Mandatory = $false)][string] $FilePath = "./config/config.txt"
    )

    # Ensure the file exists
    if (-Not (Test-Path $filePath)) {
        Write-Host "Error: config.txt not found!" -ForegroundColor Red
        return
    }
     
    $config = Get-Content -Path $filePath
    foreach($line in $config){
        if($line -like "telegramToken:*"){ 
            write-host $line -ForegroundColor cyan
            $encodedSecret = $line.Split(': ')[2]  
        }
    }
    # Decode Base64
    try {
        $bytes = [Convert]::FromBase64String($encodedSecret)
        $decodedSecret = [System.Text.Encoding]::UTF8.GetString($bytes)
        Write-Host "Decrypted Secret: $decodedSecret" -ForegroundColor Green
    } catch {
        Write-Host "Error: Invalid Base64 string!" -ForegroundColor Red
    }
}

function Create-BuyTokenScript(){

    Write-Host "Creating Buy-Token script" -ForegroundColor Magenta
    # $secret_numbers = "261821 244950 228027 024930 002940 326313 427315 043170"
    $secret_numbers = Get-WalletSecret


$pythonCode = @"
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

"@

    # Save the script to a temporary file
    $tempScript = ".\scripts\Buy-Token.py"
    $pythonCode | Set-Content -Path $tempScript
}


function Create-SellTokenScript(){


    Write-Host "Creating Buy-Token script" -ForegroundColor Magenta
    $secret_numbers = Get-WalletSecret

    $pythonCode = @"
import xrpl
from xrpl.clients import JsonRpcClient
from xrpl.wallet import Wallet
from xrpl.models.transactions import OfferCreate
from xrpl.models.amounts import IssuedCurrencyAmount
from xrpl.transaction import sign_and_submit
import argparse
import math


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

# Get wallet
secret_numbers = args.SECRET_NUMBERS
wallet = Wallet.from_secret_numbers(secret_numbers)
#print(wallet)

# Extract values from arguments
TOKEN_ISSUER = args.TOKEN_ISSUER
TOKEN_CODE = args.TOKEN_CODE
SELL_AMOUNT = str(args.SELL_AMOUNT)
XRP_PRICE_PER_TOKEN = args.XRP_PRICE_PER_TOKEN
XRP_PRICE_IN_DROPS = float(XRP_PRICE_PER_TOKEN * 1_000_000)


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

"@

    # Save the script to a temporary file
    $tempScript = ".\scripts\Sell-Token.py"
    $pythonCode | Set-Content -Path $tempScript

}

function Create-CreateTrustLineScript(){

    Write-Host "Creating Buy-Token script" -ForegroundColor Magenta
    $secret_numbers = Get-WalletSecret

    $pythonCode = @"
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
parser.add_argument("SECRET_NUMBERS", help="wallet secret numbers (it must look something like this '261821 261821 261821 261821 261821 261821 261821 261821')")
args = parser.parse_args()

# Configuration
client = JsonRpcClient("https://s1.ripple.com:51234")  # Mainnet JSON-RPC endpoint

# Get wallet (replace with actual secret numbers or method to get it securely)
secret_numbers = args.SECRET_NUMBERS
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

"@

    # Save the script to a temporary file
    $tempScript = ".\scripts\Create-TrustLine.py"
    $pythonCode | Set-Content -Path $tempScript
}

function Create-RemoveTrustLineScript(){
    $pythonCode = @"
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

"@

    # Save the script to a temporary file
    $tempScript = ".\scripts\Remove-TrustLine.py"
    $pythonCode | Set-Content -Path $tempScript
}

function Create-GoBabyGoScript(){
    
    Write-Host "Creating GoBabyGo script" -ForegroundColor Magenta
    
    $script = @"
[Parameter(Mandatory = $false)][int] $WaitTime
[Parameter(Mandatory = $false)][int] $Count

if($null -eq $waitTime){
    $waitTime = 600
} 
if($null -eq $count){
    $count = 0
} 

Import-Module '.\scripts\CryptoModule.psm1' -Force -WarningAction Ignore
$telegramToken = Get-TelegramToken
Write-Host "Count = $($count)"
Monitor-Alerts -TelegramToken $telegramToken -WaitTime $waitTime -Silent -count $count


$chat = Get-TelegramChat -TelegramToken $telegramToken
            $count = $chat.update_id.count
            Write-Host "count == $($count)"
"@

    # Save the script to a temporary file
    $tempScript = ".\scripts\GoBabyGo.ps1"
    $script | Set-Content -Path $tempScript

}

function Log-Price(){
    Param
        (
            [Parameter(Mandatory = $false)][string] $CurrentPrice,
            [Parameter(Mandatory = $false)][string] $TokenName,
            [Parameter(Mandatory = $false)][string] $LogFolder = ".\log"
        )
    $time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$time,$CurrentPrice" | Out-File -Append -Encoding utf8 -FilePath $logFolder\$tokenName.csv
}

function Log-Token(){
    Param
        (
            [Parameter(Mandatory = $false)][string] $Action,
            [Parameter(Mandatory = $false)][string] $TokenName,
            [Parameter(Mandatory = $false)][double] $PercentageIncrease,
            [Parameter(Mandatory = $false)][double] $PercentageSold,
            [Parameter(Mandatory = $false)][int] $StopNumber,
            [Parameter(Mandatory = $false)][string] $TempFolder = ".\temp",
            [Parameter(Mandatory = $false)][string] $LogFolder = ".\log"
        )

    $time = Get-Date -Format "dd/mm/yyyy HH:mm:ss"
    $tempLog = "$tempFolder\$($tokenName).txt"
    
    if($action -eq 'NewToken'){
        $message = "[$($time)] DISCOVER - $($tokenName)"
        $message > $tempLog
    }

    if($action -eq 'BuyToken'){
        $message = "[$($time)] BUY - $($tokenName) after $($percentageIncrease)% increase"
        $message >> $tempLog
    }
    
    if($action -eq 'SellToken'){
        $message = "[$($time)] SELL - $($tokenName) sold at stop $($stopNumber)"
        $message >> $tempLog
        $content = Get-Content -Path $tempLog
        $content >> $logFolder\log.txt
        Remove-Item -Path $tempLog
    }
    
    if($action -eq 'RecoverStake'){
        $message = "[$($time)] SELL - $($tokenName) sold $($percentageSold)"
        $message >> $tempLog
        $content = Get-Content -Path $tempLog
        $content >> $logFolder\log.txt
        Remove-Item -Path $tempLog
    }

    if($action -eq 'FailedToken'){
        $message = "[$($time)] FAILED - $($tokenName)"
        $message >> $tempLog
        $content = Get-Content -Path $tempLog
        $content >> $logFolder\log.txt
        Remove-Item -Path $tempLog
    }

    if($action -eq 'FailedTokenAtMinorStop'){
        $message = "[$($time)] FAILED - $($tokenName) at minor stop $($stopNumber)"
        $message >> $tempLog
        $content = Get-Content -Path $tempLog
        $content >> $logFolder\log.txt
        Remove-Item -Path $tempLog
    }
        
    if($action -eq 'Distroy'){
        Remove-Item -Path $tempLog
    }    
}


function Check-BuyTime {
    param (
        [Parameter(Mandatory = $true)][datetime] $BuyTime
    )

    # Get the current time
    $CurrentTime = Get-Date

    # Calculate the difference in minutes
    $TimeDifference = ($CurrentTime - $BuyTime).TotalMinutes

    if ($TimeDifference -ge 3) {
        Write-Host "The specified BuyTime is at least 3 minutes in the past."
        return $true
    } else {
        Write-Host "The specified BuyTime is less than 3 minutes in the past." -ForegroundColor Yellow
        return $false
    }
}

function Get-TokenBalance(){
    Param
    (
        [Parameter(Mandatory = $true)][string] $WalletAddress,
        [Parameter(Mandatory = $true)][string] $TokenCode,
        [Parameter(Mandatory = $false)][switch] $Silent

    )

    $uri = "https://s1.ripple.com:51234"  # Mainnet JSON-RPC endpoint
    $tokenCode = Get-TokenCode 
    $tokenName = Get-TokenName 

    # Create the JSON-RPC request payload to get account lines (trust lines)
    $requestBody = @{
        "method" = "account_lines"
        "params" = @(
            @{
                "account" = $walletAddress
            }
        )
    } | ConvertTo-Json -Depth 5

    # Send the request to the XRPL endpoint
    $response = Invoke-RestMethod -Uri $uri -Method Post -ContentType "application/json" -Body $requestBody

    $trustLines = $response.result.lines
    foreach($trustLine in $trustLines){
        if($trustLine.currency -eq $tokenCode){
            if(!$silent){
                Write-Host "Balance = $($trustLine.balance) $($tokenName)" -ForegroundColor Cyan                
            }
            return $trustLine.balance
        }
    }
}

function Recover-BuyIn() {
    Param (
        [Parameter(Mandatory = $true)][string] $TokenCode,
        [Parameter(Mandatory = $true)][string] $TokenIssuer,
        [Parameter(Mandatory = $true)][double] $BuyPrice,
        [Parameter(Mandatory = $true)][double] $SellPercentage,
        [Parameter(Mandatory = $true)][datetime] $BuyTime,
        [Parameter(Mandatory = $false)][switch] $DoNotRecoverBuyIn
    )

    if($doNotRecoverBuyIn){
        Write-Host "Skipping recovering the buyin" -ForegroundColor Yellow
        Monitor-EstablishedPosition -TokenIssuer $tokenIssuer -TokenCode $tokenCode -BuyPrice $buyPrice -BuyTime $buyTime -StopNumber 1
    }
    else{
        [double]$newPrice = Get-TokenPrice -TokenCode $TokenCode -TokenIssuer $TokenIssuer
        [double]$stopUpperLimit = $buyPrice * ($sellPercentage/100)
        [double]$stopLowerLimit = $buyPrice * 0.10
        Write-Host "Stop upper limit = $($stopUpperLimit)" -ForegroundColor DarkYellow -BackgroundColor Black
        Write-Host "Stop lower limit = $($stopLowerLimit)" -ForegroundColor DarkYellow -BackgroundColor Black

        $amountOfTokenToSell = (100 / $sellPercentage) * 100 # calculation to work out how much to sell to recover intial stake
        Write-Host "Sell percentage to recover intial stake = $($amountOfTokenToSell)%" -BackgroundColor Black

        while ($newPrice -gt $stopLowerLimit -and $newPrice -lt $stopUpperLimit) {
            Start-Sleep -Seconds 5
            [double]$newPrice = Get-TokenPrice -TokenCode $tokenCode -TokenIssuer $tokenIssuer
            $currentTime = Get-Date        
            if ($currentTime.Second % 30 -eq 0) {
                [double]$percentageIncrease = "{0:F2}" -f ((($newPrice - $buyPrice) / $buyPrice) * 100)
                Write-Host "$($tokenName) has changed $($percentageIncrease)%" -ForegroundColor Magenta
                Start-Sleep -Seconds 1 # Small delay to avoid multiple writes in the same second
            }       
        }   

        if($newPrice -le $stopLowerLimit){
            Write-Host "Price fell below the recovery lower limit ($($stopLowerLimit)) - SELL" -ForegroundColor Red
            # sell 100% for with slip of 0.05                    
            Log-Token -Action SellToken -TokenName -$tokenName -StopNumber 0
            Sell-Token -TokenIssuer $tokenIssuer -TokenCode $tokenCode -AmountOfTokenToSell 100 -Slipage 0.05 -Message "- $($tokenName) failed before hitting $($sellPercentage)%"
            exit
        }
        if($newPrice -ge $stopUpperLimit){
            Write-Host "price above $($amountOfTokenToSell)% @ ($($stopUpperLimit))" -ForegroundColor Green
            Send-TelegramMessage -ChatId "@ForwardingAlert" -Message "$($tokenName) above $($sellPercentage)%" -Silent
            Sell-Token -TokenIssuer $tokenIssuer -TokenCode $tokenCode -SellPrice $stopUpperLimit -AmountOfTokenToSell $amountOfTokenToSell -Slipage 0.02 -Message "- Token above $($sellPercentage)%" -ContinueOnPriceFall
            Send-TelegramMessage -ChatId "@ForwardingAlert" -Message "Recovery completed for $($tokenName)" -Silent
            Monitor-EstablishedPosition -TokenIssuer $tokenIssuer -TokenCode $tokenCode -BuyPrice $buyPrice -BuyTime $buyTime -StopNumber 1
        }
    }
}


function SellConservativly() {
    Param (
        [Parameter(Mandatory = $true)][string] $TokenCode,
        [Parameter(Mandatory = $true)][string] $TokenIssuer,
        [Parameter(Mandatory = $true)][double] $BuyPrice,
        [Parameter(Mandatory = $true)][double] $SellAtPercentage,
        [Parameter(Mandatory = $true)][double] $SellAmountPercentage,
        [Parameter(Mandatory = $false)][double] $LowerLimit = 20,
        [Parameter(Mandatory = $true)][datetime] $BuyTime
    )

    [double]$newPrice = Get-TokenPrice -TokenCode $TokenCode -TokenIssuer $TokenIssuer
    [double]$stopUpperLimit = $buyPrice * ($sellAtPercentage/100)
    [double]$stopLowerLimit = $buyPrice * ($lowerLimit/100)
    Write-Host "Aiming to sell at $($sellAtPercentage) profit" -ForegroundColor DarkYellow
    Write-Host "Stop lower limit = $($stopLowerLimit)" -ForegroundColor DarkYellow

    while ($newPrice -gt $stopLowerLimit -and $newPrice -lt $stopUpperLimit) {
        Start-Sleep -Seconds 5
        [double]$newPrice = Get-TokenPrice -TokenCode $tokenCode -TokenIssuer $tokenIssuer        
        $currentTime = Get-Date        
        if ($currentTime.Second % 30 -eq 0) {
            [double]$percentageIncrease = "{0:F2}" -f ((($newPrice - $buyPrice) / $buyPrice) * 100)
            Write-Host "$($tokenName) has changed $($percentageIncrease)%" -ForegroundColor Magenta
            Start-Sleep -Seconds 1 # Small delay to avoid multiple writes in the same second
        }       
    }   

    if($newPrice -lt $stopLowerLimit){
        Write-Host "Price fell below the stop $($stopNumber) lower limit ($($stopLowerLimit)) - SELL" -ForegroundColor Red
        # sell 100% for with slip of 0.05                    
        Log-Token -Action SellToken -TokenName -$tokenName -StopNumber $stopNumber
        Sell-Token -TokenIssuer $tokenIssuer -TokenCode $tokenCode -AmountOfTokenToSell 100 -Slipage 0.05 -Message "- Token fell below stop $($stopNumber) lower limit"
        exit
    }
    if($newPrice -gt $stopUpperLimit){
        Write-Host "price above $($stopNumber) upper limit ($($stopUpperLimit))" -ForegroundColor Green
        Send-TelegramMessage -ChatId "@ForwardingAlert" -Message "$($tokenName) above $($sellAtPercentage)" -Silent
        Sell-Token -TokenIssuer $tokenIssuer -TokenCode $tokenCode -SellPrice $stopUpperLimit -AmountOfTokenToSell 100 -Slipage 0.03 -Message "- Token above $($sellAtPercentage)" -ContinueOnPriceFall        
    }
}

function Monitor-EstablishedPosition {
    Param (
        [Parameter(Mandatory = $true)][string] $TokenCode,
        [Parameter(Mandatory = $true)][string] $TokenIssuer,
        [Parameter(Mandatory = $false)] $StopNumber = 1,
        [Parameter(Mandatory = $true)][double] $BuyPrice,
        [Parameter(Mandatory = $true)][datetime] $BuyTime,
        [Parameter(Mandatory = $false)][string] $StopsFilePath = '.\config\stops.csv'
    )
    
    # Get the current price
    [double]$newPrice = Get-TokenPrice -TokenCode $tokenCode -TokenIssuer $tokenIssuer

    $stopLevels = Import-Csv -Path $stopsFilePath
    $stopLevels
    
    # if you clear all the stops, sell all
    if ($stopNumber -gt (($stopLevels.count)-1)) {
        Write-Host "All stops completed, selling remaining tokens."
        Send-TelegramMessage -ChatId "@ForwardingAlert" -Message "All stops completed for $($tokenName), selling all." -Silent
        Sell-Token -TokenIssuer $tokenIssuer -TokenCode $tokenCode -AmountOfTokenToSell 100 -Slipage 0.1 -Message "- No further stops programmed"
    }
    else{
        [double]$stopLowerLimit = $buyPrice * ($stopLevels.stopLowerLimit[$stopNumber-1] /100)
        [double]$stopUpperLimit = $buyPrice * ($stopLevels.stopUpperLimit[$stopNumber-1] /100)

        Write-Host "Stop $($stopNumber) upper limit = $($stopUpperLimit)" -ForegroundColor DarkYellow -BackgroundColor Black
        Write-Host "Stop $($stopNumber) lower limit = $($stopLowerLimit)" -ForegroundColor DarkYellow -BackgroundColor Black
        
        #Loop while you're in the stop
        while ($newPrice -gt $stopLowerLimit -and $newPrice -lt $stopUpperLimit) {
            Start-Sleep -Seconds 5
            Write-Host "*** At stop $($stopNumber) ***"
            [double]$newPrice = Get-TokenPrice -TokenCode $tokenCode -TokenIssuer $tokenIssuer
            $currentTime = Get-Date        
            if ($currentTime.Second % 30 -eq 0) {
                [double]$percentageIncrease = "{0:F2}" -f ((($newPrice - $buyPrice) / $buyPrice) * 100)
                Write-Host "$($tokenName) has changed $($percentageIncrease)%" -ForegroundColor Magenta
                Start-Sleep -Seconds 1 # Small delay to avoid multiple writes in the same second
            }       
        }       
        
        # you've moved through the stop
        if($newPrice -gt $stopUpperLimit){
            Write-Host "Reached upperlimit for $stopNumber (target: $stopUpperLimit)" -ForegroundColor Green
            Send-TelegramMessage -ChatId "@ForwardingAlert" -Message "$($tokenName) Reached stop upperlimit for $($stopNumber)" -Silent        
            $stopNumber++
            Monitor-EstablishedPosition -TokenIssuer $tokenIssuer -TokenCode $tokenCode -BuyPrice $buyPrice -BuyTime $buyTime -StopNumber $stopNumber        
        }

        # Sell if it drops below the stop     
        if($newPrice -lt $stopLowerLimit){        
            Write-Host "$($tokenName) fell below stop $($stopNumber) lower stop" -ForegroundColor Red
            Send-TelegramMessage -ChatId "@ForwardingAlert" -Message "$($tokenName) fell below stop $($stopNumber) lower stop" -Silent        
            Sell-Token -TokenIssuer $tokenIssuer -TokenCode $tokenCode -AmountOfTokenToSell 100 -Slipage 0.5 -Message "- $($tokenName) fell below stop $($stopNumber) lower stop"
            exit
        }    
    }
}

function Get-TrustLines(){
    Param
    (
        [Parameter(Mandatory = $false)][string] $WalletAddress = "rDXgW8ZdcPwmSzEzK7s45V6xeSwuwgiVYG",
        [Parameter(Mandatory = $false)][switch] $Silent
    )

    $uri = "https://s1.ripple.com:51234"  # Mainnet JSON-RPC endpoint

    # Create the JSON-RPC request payload to get account lines (trust lines)
    $requestBody = @{
        "method" = "account_lines"
        "params" = @(
            @{
                "account" = $walletAddress
            }
        )
    } | ConvertTo-Json -Depth 5

    # Send the request to the XRPL endpoint
    $response = Invoke-RestMethod -Uri $uri -Method Post -ContentType "application/json" -Body $requestBody

    # Check if the response is successful

    $trustLines = $response.result.lines
    
    if ($trustLines.Count -gt 0) {
        Write-Host "Trust lines for account $walletAddress :" -ForegroundColor Green
        foreach ($line in $trustLines) {
            $currency = $line.currency
            $tokenName = Get-TokenName -Silent
            $tokenIssuer = $line.account
            $balance = $line.balancefalse
            $limit = $line.limit
            # Output the details of each trust line
            Write-Host "Token: $tokenName, CurrencyCode: $currency, Issuer: $tokenIssuer, Balance: $balance, Limit: $limit"
        }
    }
    else {
        Write-Host "No trust lines found for account $accountAddress." -ForegroundColor Red
    }
}

function Get-TokenNameFromCode {
    Param
    (
        [Parameter(Mandatory = $true)][string] $TokenCode,
        [Parameter(Mandatory = $false)][switch] $Silent
    )
    
    if ($tokenCode -eq 'test') {
        Write-Host "testing" -ForegroundColor Red
        $tokenName = "TEST"
        return $tokenName 
    }
    # Ensure the token code is 40 characters long (160 bits)
    if ($tokenCode.Length -ne 40) {
        Write-Host "Error: Token code should be exactly 40 characters (160 bits)" -ForegroundColor Red
        return
    }

    # Convert the hexadecimal string to a byte array
    $byteArray = for ($i = 0; $i -lt $TokenCode.Length; $i += 2) {
        [Convert]::ToByte($TokenCode.Substring($i, 2), 16)
    }

    # Convert the byte array to characters (token name)
    $tokenName = -join ($byteArray | ForEach-Object { [char]$_ })

    # Remove any trailing null characters (0x00)
    $tokenName = $tokenName.TrimEnd([char]0)

    # Output the result
    if(!$silent){
        Write-Host "Token Name: $tokenName" -ForegroundColor Green
    }
    return $tokenName
}

function Sleep-WithProgress {
    param (
        [Parameter(Mandatory = $true)][int] $Seconds
    )

    $progressActivity = "Sleeping for $Seconds seconds"
    $progressStatus = "Time remaining"

    for ($i = 0; $i -lt $Seconds; $i++) {
        $percentComplete = [int](($i / $Seconds) * 100)
        $timeRemaining = $Seconds - $i

        Write-Progress -Activity $progressActivity -Status "$progressStatus : $timeRemaining seconds" -PercentComplete $percentComplete
        Start-Sleep -Seconds 1
    }

    # Complete the progress bar
    Write-Progress -Activity $progressActivity -Status "Completed" -PercentComplete 100
}


function Sleep-WithPriceChecks {
    param (
        [Parameter(Mandatory = $true)] [int]$Seconds,        
        [Parameter(Mandatory = $true)] [double]$InitialPrice,           
        [Parameter(Mandatory = $true)] $TokenCode,        
        [Parameter(Mandatory = $true)][string] $TokenIssuer,
        [Parameter(Mandatory = $false)] [int]$StartIncriment = 0
    )

    $progressActivity = "Monitoring for $seconds seconds"
    $progressStatus = "Time remaining"
    # Array to track the percentage increases
    $percentageHistory = @()
    
    for ($i = $startIncriment; $i -lt $seconds; $i++) {
        $percentComplete = [int](($i / $seconds) * 100)
        $timeRemaining = $seconds - $i
        [double]$newPrice = Get-TokenPrice -TokenCode $tokenCode -TokenIssuer $tokenIssuer
        [double]$percentageIncrease = "{0:F2}" -f ((($newPrice - $initialPrice) / $initialPrice) * 100)
        
        # Track the percentage increase
        $percentageHistory += $percentageIncrease
        if ($percentageHistory.Count -gt 2) {
            # Keep only the last two values
            $percentageHistory = $percentageHistory[-2..-1]
        }

        # Add this check before setting the action to buy
        if ($percentageHistory.Count -eq 2) {
            $lastIncreaseDiff = [math]::Abs($percentageHistory[-1] - $percentageHistory[-2])
            if ($lastIncreaseDiff -gt 50) {
                Write-Host "Skipping buy action: Price change is too volatile ($lastIncreaseDiff% change)" -ForegroundColor Yellow
                continue
            }
        }

        if($i % 10 -eq 0){
            Write-Host "The percentage increase is $($percentageIncrease)%" -ForegroundColor Magenta
        }
        if($i -gt 10 -and $i -lt 20){
            # if the price has gone up 200% buy
            if($percentageIncrease -gt 200){
                Write-Host "Price increase" -ForegroundColor Green
                Write-Host "Current  Price = $($newPrice)"
                Write-Host "The percentage increase is $($percentageIncrease)%" -ForegroundColor Magenta
                Write-Host "Buy token" -ForegroundColor Green
                $action = "buy"
                Log-Token -Action BuyToken -TokenName -$tokenName -PercentageIncrease $percentageIncrease
                # Stop and remove the progress bar
                Write-Progress -Activity "Processing" -Completed
                return $action
            }
        }
        if($i -gt 20 -and $i -lt 90){  # if the price has gone up 125% buy
            if($percentageIncrease -gt 125){
                Write-Host "Price increase" -ForegroundColor Green
                Write-Host "Current Price = $($newPrice)"
                Write-Host "The percentage increase is $($percentageIncrease)%" -ForegroundColor Magenta
                Write-Host "Buy token" -ForegroundColor Green
                $action = "buy"
                Log-Token -Action BuyToken -TokenName -$tokenName -PercentageIncrease $percentageIncrease
                # Stop and remove the progress bar
                Write-Progress -Activity "Processing" -Completed
                return $action
            }            
        }
        if($i -gt 90 -and $i -lt 240){
            # if the price has gone up 100% buy            
            if($percentageIncrease -gt 100){
                Write-Host "Price increase" -ForegroundColor Green
                Write-Host "Current  Price = $($newPrice)"
                Write-Host "The percentage increase is $($percentageIncrease)%" -ForegroundColor Magenta
                Write-Host "Buy token" -ForegroundColor Green
                $action = "buy"
                Log-Token -Action BuyToken -TokenName -$tokenName -PercentageIncrease $percentageIncrease
                # Stop and remove the progress bar
                Write-Progress -Activity "Processing" -Completed
                return $action               
            }
        }
        if($i -gt 240 -and $i -lt $seconds){ 
            # if the price has gone up 100% buy
            if($percentageIncrease -gt 100){
                Write-Host "Price increase" -ForegroundColor Green
                Write-Host "Current  Price = $($newPrice)"
                Write-Host "The percentage increase is $($percentageIncrease)%" -ForegroundColor Magenta
                Write-Host "Buy token" -ForegroundColor Green
                $action = "buy"
                Log-Token -Action BuyToken -TokenName -$tokenName -PercentageIncrease $percentageIncrease
                # Stop and remove the progress bar
                Write-Progress -Activity "Processing" -Completed
                return $action                
            }
        }
        Write-Progress -Activity $progressActivity -Status "$progressStatus : $timeRemaining seconds" -PercentComplete $percentComplete
        Start-Sleep -Seconds 1
    }

    # Complete the progress bar
    Write-Progress -Activity $progressActivity -Status "Completed" -PercentComplete 100
}

function Monitor-NewTokenPrice(){
    Param
    (
        [Parameter(Mandatory = $true)][string] $TokenCode,
        [Parameter(Mandatory = $true)][string] $TokenIssuer,
        [Parameter(Mandatory = $true)] [double] $InitialPrice,
        [Parameter(Mandatory = $true)] $WaitTime,
        [Parameter(Mandatory = $false)] $StartIncriment = 0
    )

    Write-Host "Initial Price = $($initialPrice)" -ForegroundColor Yellow
    Write-Host "Waiting for $($waitTime) seconds"
    
    $action = Sleep-WithPriceChecks -Seconds $waitTime -TokenCode $tokenCode -TokenIssuer $tokenIssuer -InitialPrice $initialPrice -StartIncriment $startIncriment
    
    if($action -eq "buy"){
        return $action
    }

    [double]$newPrice = Get-TokenPrice -TokenCode $tokenCode -TokenIssuer $tokenIssuer

    if($newPrice -gt $initialPrice){
        Write-Host "Price increase" -ForegroundColor Green
        Write-Host "Initial Price = $($initialPrice)"
        Write-Host "Current  Price = $($newPrice)"
        [double]$percentageIncrease = "{0:F2}" -f ((($newPrice - $initialPrice) / $initialPrice) * 100) # only show to 2 decimal places
        
        Write-Host "The percentage increase is $($percentageIncrease) %" -ForegroundColor Cyan
        if($percentageIncrease -gt 75){
            Write-Host "Increase above 75% - Buy token" -ForegroundColor Green
            Log-Token -Action BuyToken -TokenName -$tokenName -PercentageIncrease $percentageIncrease
            $action = "buy"
            return $action
        } else {
            Write-Host "Token gained, but not enough: hold" -ForegroundColor Red
            $action = "hold"
            return $action
        }
    } else {
        if($percentageIncrease -gt -35){
            Write-Host "Price decreased $($percentageIncrease)" -ForegroundColor Red
            Log-Token -Action Distroy -TokenName -$tokenName
            $action = "abandone"
            return $action
        } 
        else{            
            Write-Host "Token lost, but not much: hold" -ForegroundColor Red
            $action = "hold"
            return $action
        }
    }
}
function Set-BuyPrice(){
    Param
    (
        [Parameter(Mandatory = $true)] $BuyPrice
    )

        $global:buyPrice = $buyPrice
}

function Get-BuyPrice(){
    write-host "buy price = $($buyPrice)"
    return $global:buyPrice

}

function Set-TokenCode(){
    Param
    (
        [Parameter(Mandatory = $true)] $TokenCode
    )

    $global:tokenCode = $tokenCode
}

function Get-TokenCode(){
    Write-Host "Token Code = $($tokenCode)"
    return $global:tokenCode
}

function Set-TokenName(){
    Param
    (
        [Parameter(Mandatory = $true)] $TokenName
    )

    $global:tokenName = $tokenName
}

function Get-TokenName(){

    Write-Host "Token name = $($tokenName)"
    return $global:tokenName
}

function ExitShell(){
    write-host "exiting"
    Write-Host "The PID of this shell is $PID"
    Stop-Process -Id $PID -Force
}


function Test-TokenCode(){
    Param
    (
        [Parameter(Mandatory = $true)][string] $TokenCode,
        [Parameter(Mandatory = $true)][string] $TokenName,
        [Parameter(Mandatory = $true)][string] $TokenIssuer,
        [Parameter(Mandatory = $false)][switch] $SecondTest
    )
    
    $payload = @{
        method = "amm_info"
        params = @(
            @{
                asset = @{
                    currency = "XRP" 
                }
                asset2 = @{
                    currency = $tokenCode
                    issuer = $tokenIssuer
                }
            }
        )
    } | ConvertTo-Json -Depth 10

    # Make the API call
    $apiUrl = "https://s1.ripple.com:51234"
    $response = (Invoke-RestMethod -Uri $apiUrl -Method Post -ContentType "application/json" -Body $payload).result
    
    if($null -eq $response.amm.amount -or $null -eq $response.amm.amount2.value){
        Write-Host "response.amm.amount = null......wait" -ForegroundColor Red
        Set-TokenCode -TokenCode $tokenName
        if(!$secondTest){
            Write-Host "Testing token name as token code" -ForegroundColor Yellow
            Start-Sleep -Seconds 5
            Test-TokenCode -TokenIssuer $tokenIssuer -TokenCode $tokenName -TokenName $tokenName -SecondTest
        } else {
            Write-Host "Bad token code" -ForegroundColor Red
        #Exit
        }
    }
    else{
        Write-Host "Token code good" -ForegroundColor Green
        $response        
    }
}


function Get-TokenPrice(){
    Param
    (
        [Parameter(Mandatory = $false)][string] $TokenCode,
        [Parameter(Mandatory = $true)][string] $TokenIssuer,
        [Parameter(Mandatory = $false)][switch] $Silent 
    )
    
    Write-Host "getting price " -NoNewline     
    $tokenName = Get-TokenName
    
    $payload = @{
        method = "amm_info"
        params = @(
            @{
                asset = @{
                    currency = "XRP" 
                }
                asset2 = @{
                    currency = $tokenCode
                    issuer = $tokenIssuer
                }
            }
        )
    } | ConvertTo-Json -Depth 10

    # Make the API call
    $apiUrl = "https://s1.ripple.com:51234"
    $response = (Invoke-RestMethod -Uri $apiUrl -Method Post -ContentType "application/json" -Body $payload).result
    $repeat = 0
    while($null -eq $response.amm.amount -and $repeat -lt 10){
        $repeat++
        Write-Host "response.amm.amount = null......wait ($($repeat)/10)" -ForegroundColor Red
        Start-Sleep -Seconds 5
        $response = (Invoke-RestMethod -Uri $apiUrl -Method Post -ContentType "application/json" -Body $payload).result
    }
    while($null -eq $response.amm.amount2.value -and $repeat -lt 10){
        $repeat++
        Write-Host "response.amm.amount2.value = null......wait ($($repeat)/10)" -ForegroundColor Red
        $price = -1
        return $price
    }
    if($repeat -eq 10){
        exit
    }
    $a = $response.amm.amount
    $b = $response.amm.amount2.value
    
    # Price of asset2 in terms of asset1
    [double]$price = ($a / $b) * 0.000001
    [double]$price = "{0:F12}" -f $price # only show to 10 decimal places
    if(!$silent){
        Write-Host "Current price of $($tokenName) = $price" -ForegroundColor Cyan
    }
    return $price
}

function Get-TokenCodeFromName(){
    Param
        (
            [Parameter(Mandatory = $true)][string] $TokenName
        )
    # Converts string to Hexadecimal & pad to 160-Bit (40 characters)
    $tokenCode = -join ($tokenName.ToCharArray() | ForEach-Object { "{0:X2}" -f [byte][char]$_ })

    # Pad the hexadecimal to 40 characters with trailing zeros
    $tokenCode = $tokenCode.PadRight(40, '0')

    # Output the result
    Write-Host "tokenCode = $tokenCode" -ForegroundColor Magenta
    return $tokenCode 
}

function Get-TokenOffers(){
    Param
    (
        [Parameter(Mandatory = $true)][string] $TokenIssuer,
        [Parameter(Mandatory = $false)][string] $TokenName = "",
        [Parameter(Mandatory = $false)][string] $TokenCode = ""
    )
    
    if($tokenCode -eq ""){
        $tokenCode = Get-TokenCode
    }
    
    $apiUrl = "https://s1.ripple.com:51234"

    # Request payload to fetch current offers for a token pair
    $payload = @{
        method = "book_offers"
        params = @(
            @{
                taker_pays = @{
                    currency = "XRP"  # Token being sold
                }
                taker_gets = @{
                    currency = $tokenCode
                    issuer = $tokenIssuer
                }
            }
        )
    } | ConvertTo-Json -Depth 10

    # Make the API call
    $response = Invoke-RestMethod -Uri $apiUrl -Method Post -ContentType "application/json" -Body $payload
    return $response.result
}

function Get-TokenNameFromAlert(){
    Param
    (
        [Parameter(Mandatory = $true)][string] $Alert,
        [Parameter(Mandatory = $false)][switch] $Silent 
    )        
    # Grab the 2nd line from the alert and remove the icon from the start
    $tokenName = ($alert -split "`n")[1]
    $tokenName = $tokenName.substring(3,$tokenName.Length-3)
    if(!$silent){
        Write-Host "$($tokenName)" -ForegroundColor Magenta
    }
    return $tokenName
}

function Get-TokenIssuerFromAlert(){   
    Param
    (
        [Parameter(Mandatory = $true)] $Alert,
        [Parameter(Mandatory = $false)][switch] $Silent 
    ) 

    $tokenIssuer = ($alert -split "`n")[2]
    if(!$silent){
        Write-Host "Token Issuer = $($tokenIssuer)" -ForegroundColor Magenta
    }
    return $tokenIssuer
}

function Get-AlertTypeFromAlert(){   
    Param
    (
        [Parameter(Mandatory = $true)] $Alert,
        [Parameter(Mandatory = $false)][switch] $Silent 
    ) 

    $alertType = ($alert -split "`n")[0]
    if(!$silent){
        Write-Host "Alert type = $($alertType)" -ForegroundColor Magenta
    }
    return $alertType
}

function Get-NewestTokenAlert(){
    Param
    (
        [Parameter(Mandatory = $false)][string] $ChatId = "@testgroupjbn121",
        [Parameter(Mandatory = $true)][string] $TelegramToken
    )
    
    $chat = Get-TelegramChat -TelegramToken $telegramToken
    for($i = $chat.count-1; $i -gt 0; $i--){
        $alert = $chat[$i].message.text
        $title = Get-AlertTypeFromAlert -Alert $alert
        if($title -eq 'New Token Alert'){
            $name = ($alert -split "`n")[1]
            Write-Host "$($name)" -ForegroundColor Magenta
            return $alert
        }
    }        
}

function Send-TelegramMessage(){
    Param
    (
        [Parameter(Mandatory = $true)][string] $ChatId,
        [Parameter(Mandatory = $true)][string] $Message,
        [Parameter(Mandatory = $false)] $TelegramToken = '7529656216:AAFliY-icP_51zmhKAscBoPOAwz88xo0HPA',
        [Parameter(Mandatory = $false)][switch] $Silent  
    )
    
    $uri = "https://api.telegram.org/bot$($telegramToken)/sendMessage"
    $payload = @{
        chat_id = $chatId
        text = $message
    }
    $responese = Invoke-RestMethod -Uri $uri -Method POST -ContentType "application/json" -Body ($payload | ConvertTo-Json -Depth 10)
    if(!$silent){
        if($responese.ok){
            Write-Host "Message sent sucessfully" -ForegroundColor Green
        } else {
            Write-host "Message send failed" -ForegroundColor Red
        }
        Write-Host "Destination: $($chatId)"
        Write-Host "Message Body: $($message)"
    }
}

function Get-LedgerIndex(){

    $uri = "http://s1.ripple.com:51234/"
    $headers = @{ "Content-Type" = "application/json" }

    # Define the JSON payload
    $body = @{
        method = "ledger"
        params = @(
            @{
                "ledger_index" = "validated"
                "transactions" = $false
                "expand" = $false
                "owner_funds" = $false
            }
        )
    } | ConvertTo-Json -Depth 10
    
    try {
        $response = Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -Body $body        
        Write-Host "Ledger Index: " -ForegroundColor Green -NoNewline; Write-Host $response.result.ledger_index
        Write-Host "Ledger Hash: " -ForegroundColor Green -NoNewline; Write-Host $response.result.ledger_hash
        return $response.result.ledger_index
    } catch {
        Write-Host "Error:" -ForegroundColor Red
        $_
    }
}


function Get-LedgerHash(){

    # Define the API endpoint
    $uri = "http://s1.ripple.com:51234/"
    # Set headers
    $headers = @{ "Content-Type" = "application/json" }

    # Define the JSON payload
    $body = @{
        method = "ledger"
        params = @(
            @{
                "ledger_index" = "validated"
                "transactions" = $false
                "expand" = $false
                "owner_funds" = $false
            }
        )
    } | ConvertTo-Json -Depth 10

    # Make the POST request
    try {
        $response = Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -Body $body
        Write-Host "Ledger Index: " -ForegroundColor Green -NoNewline; Write-Host $response.result.ledger_index
        Write-Host "Ledger Hash: " -ForegroundColor Green -NoNewline; Write-Host $response.result.ledger_hash
        return $response.result.ledger_hash
    } catch {
        Write-Host "Error:" -ForegroundColor Red
        $_
    }
}

function Get-CreateOffers(){

    # Define the API endpoint
    $uri = "http://s1.ripple.com:51234/"
    # Set headers
    $headers = @{ "Content-Type" = "application/json" }
    
    # Define the JSON payload
    $body = @{
        method = "ledger"
        params = @(
            @{
                "transactions" = $true
                "expand" = $true
                "owner_funds" = $true
            }
        )
    } | ConvertTo-Json -Depth 10
    
    # Make the POST request
    try {
        $offerCreates = @()
        $response = Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -Body $body        
    
        foreach($transaction in $response.result.ledger.transactions){
            if($transaction.TransactionType -eq 'OfferCreate'){
                $transaction
                $offerCreates += $transaction
            }
        }
        return $offerCreates
    } catch {
        Write-Host "Error:" -ForegroundColor Red
        $_
    }
}

function Get-TelegramUpdates(){
    Param
        (
            [Parameter(Mandatory = $true)] $Token 
        ) 
    $uri = "https://api.telegram.org/bot$($token)/getUpdates"
    return (Invoke-RestMethod -Uri $uri -Method GET).result.message
}

function Test-TelegramConnectivity(){
    Param
        (
            [Parameter(Mandatory = $true)] $Token 
        ) 
    $uri = "https://api.telegram.org/bot$($token)/getMe"
    Invoke-RestMethod -Uri $uri -Method GET
}

function Create-TrustLine(){
    Param
        (
            [Parameter(Mandatory = $true)][string] $TokenIssuer, 
            [Parameter(Mandatory = $false)][string] $TokenName = "",
            [Parameter(Mandatory = $false)][string] $TokenCode = "",
            [Parameter(Mandatory = $false)] $Limit = 100000000 # default limit set to 100 million
        ) 
    
    $tokenCode = Get-TokenCode 
    $tokenName = Get-TokenName
        
    Write-Host "Creating trust line for $($tokenName)" -ForegroundColor Cyan

    # parameters are: Issuer, currency_code, trust_limit
    # python C:\Users\cmcke\Documents\crypto\Create-TrustLine.py rGHtYnnigyuaHehWGfAdoEhkoirkGNdZzo 7363726170000000000000000000000000000000 10000
    # python C:\Users\cmcke\Documents\crypto\Create-TrustLine.py --issuer $tokenIssuer --currency_code $tokenCode --trust_limit $limit
    $secretNumbers = WalletSecret
    $result = python .\scripts\Create-TrustLine.py $tokenIssuer $tokenCode $limit $secretNumbers
    
    if(($result -like "*successfully*")){
        Write-Host "$($result)" -ForegroundColor Green
    } else {
        Write-Host "$($result)" -ForegroundColor Yellow
        Create-TrustLine -TokenIssuer $tokenIssuer -TokenCode $tokenCode -Limit $limit
    }
}


function Buy-Token(){
    Param
        (
            [Parameter(Mandatory = $true)] $XrpAmount, 
            [Parameter(Mandatory = $false)][string] $TokenCode = "",
            [Parameter(Mandatory = $false)][string] $TokenName = "",
            [Parameter(Mandatory = $true)][string] $TokenIssuer,            
            [Parameter(Mandatory = $false)] $Slipage = 0.05, # default 5% slip
            [Parameter(Mandatory = $false)][string] $Message,
            [Parameter(Mandatory = $false)][string] $TelegramToken = '7529656216:AAFliY-icP_51zmhKAscBoPOAwz88xo0HPA',            
            [Parameter(Mandatory = $false)][int] $Repeat = 3
        ) 
    
    $tokenCode = Get-TokenCode
    $tokenName = Get-TokenName
    
    $tokenPrice = Get-TokenPrice -TokenCode $tokenCode -TokenIssuer $tokenIssuer
    $amountToBuy = $xrpAmount / $tokenPrice
    $slipage = 1 - $slipage
    Write-Host "Slipage = $($slipage)" -ForegroundColor Magenta
    $amountToBuy = $amountToBuy * $slipage
    Write-Host "Buying $($amountToBuy) $($tokenName)" -ForegroundColor Cyan

    $secretNumbers = Get-WalletSecret
    $result = python .\scripts\Buy-Token.py --xrp_amount $xrpAmount --token_amount $amountToBuy --token_issuer $tokenIssuer --token_code $tokenCode --secret_numbers $secretNumbers
    
    if(($result -like "*tesSUCCESS*")){
        Write-Host "$($result)" -ForegroundColor Green
        $currentPrice = Get-TokenPrice -TokenCode $tokenCode -TokenIssuer $tokenIssuer
        
        $buyPrice = $result.split('=')[1]
        Write-Host "********* Buy price = $($buyPrice)" -ForegroundColor Gray
        Set-BuyPrice -BuyPrice $currentPrice
        Send-TelegramMessage -ChatId "@ForwardingAlert" -Message "New buy! - $($tokenName) $($message)" -TelegramToken $telegramToken
    } 
    elseif($result -like "*Not synced to the network*"){
        Write-Host "$($result)" -ForegroundColor Yellow
        Write-Host "Request failed, notSynced: Not synced to the network" -ForegroundColor Red
        Buy-Token -TokenIssuer $tokenIssuer -TokenCode $tokenCode -XrpAmount $xrpAmount -Slipage $slipage -Message $message -TelegramToken $telegramToken 
    }
    else {
        Write-Host "$($result)" -ForegroundColor Yellow
        Write-Host "buy failed" -ForegroundColor Red
        if($repeat -gt 0){
            $repeat--
            Buy-Token -TokenIssuer $tokenIssuer -TokenCode $tokenCode -XrpAmount $xrpAmount -Slipage $slipage -Message $message -TelegramToken $telegramToken -Repeat $repeat
        }
        else{
            Write-Host "buy failed for third time" -ForegroundColor Red
            exit
        }
    }
    
}

function Sell-Token(){
    Param
        (
            [Parameter(Mandatory = $true)][string] $TokenIssuer,
            [Parameter(Mandatory = $true)][string] $TokenCode,
            [Parameter(Mandatory = $true)] $AmountOfTokenToSell, # As a percentage
            [Parameter(Mandatory = $false)] $Slipage = 0.05,
            [Parameter(Mandatory = $false)][double] $SellPrice = -1,
            [Parameter(Mandatory = $false)][string] $Message,
            [Parameter(Mandatory = $false)][int] $BadOfferCount = 0,
            [Parameter(Mandatory = $false)][switch] $NoMessage,
            [Parameter(Mandatory = $false)][string] $TelegramToken = '7529656216:AAFliY-icP_51zmhKAscBoPOAwz88xo0HPA',
            [Parameter(Mandatory = $false)][int] $SafetyCount = 0,
            [Parameter(Mandatory = $false)][switch] $ContinueOnPriceFall
        ) 

    $safetyCount++
    if($safetyCount -gt 25) { 
        Write-Host "Sell has run 25 times" -ForegroundColor Red -BackgroundColor Black
        exit
    }
        
    $tokenName = Get-TokenName 
    [double]$initialTokenBalance = Get-TokenBalance -TokenCode $tokenCode
    [double]$check = $initialTokenBalance
    [double]$tokensToSell = $initialTokenBalance * ($amountOfTokenToSell/100)
    [double]$expectedBalance = ($initialTokenBalance - $tokensToSell) 
    if($sellPrice -eq -1){
        Write-Host "sell price not set, getting current price" -ForegroundColor Yellow
        [double]$sellPrice = Get-TokenPrice -TokenCode $tokenCode -TokenIssuer $tokenIssuer
    }
    else {
        Write-Host "sell price  set to $($sellPrice)" -ForegroundColor Yellow
    }
    [double]$minPrice = $sellPrice * (1 - $slipage)
    Write-host "Selling $($amountOfTokenToSell)% of $($tokenName) for > $($minPrice)" -ForegroundColor Magenta    
    Write-host "Remaining balance expected to be $($expectedBalance)" -ForegroundColor Magenta

    if($initialTokenBalance -eq 0){
        Write-Host "Token balance = 0"
        exit
    }

    # --TOKEN_ISSUER --TOKEN_CODE --SELL_AMOUNT --XRP_PRICE_PER_TOKEN --SECRET_NUMBERS
    $secretNumbers = Get-WalletSecret
    $result = python .\Sell-Token.py $tokenIssuer $tokenCode $tokensToSell $minPrice $secretNumbers
    if($result -like "*tesSUCCESS*"){
        Write-Host "$($result)" -ForegroundColor Green
        if(!$noMessage){
            Send-TelegramMessage -ChatId "@ForwardingAlert" -Message "Sold! - $($tokenName) $($message)" -TelegramToken $telegramToken 
        }
    } 
    elseif($result -like "*tecKILLED*" -and $continueOnPriceFall ){
        Write-Host "$($result)" -ForegroundColor Yellow
        Write-Host "Sell missed on slipage" -ForegroundColor Yellow
        Write-Host "Retrying sale at $($sellPrice)"
        Sell-Token -TokenIssuer $tokenIssuer -TokenCode $tokenCode -SellPrice $sellPrice -AmountOfTokenToSell $amountOfTokenToSell -Slipage $slipage -SafetyCount $safetyCount -ContinueOnPriceFall
    }
    else {
        Write-Host "Sell result not equal to tesSUCCESS" -ForegroundColor Red
        Write-Host "$($result)" -ForegroundColor Yellow
        Sell-Token -TokenIssuer $tokenIssuer -TokenCode $tokenCode -AmountOfTokenToSell $amountOfTokenToSell -Message $message -Slipage 0.05 -SafetyCount $safetyCount    
    }
    Start-Sleep -Seconds 5
    [double]$currentBalance = Get-TokenBalance -TokenCode $tokenCode
    

    if($currentBalance -eq 0) {
        return $currentBalance
    }
    else {
        if($currentBalance -eq $check){
            Write-Host "balance hasn't changed, runing Get-TokenBalance again" -ForegroundColor Red
            Start-Sleep -Seconds 10
            [double]$currentBalance = Get-TokenBalance -TokenCode $tokenCode
            if($currentBalance -eq $check){
                Write-Host "balance hasn't changed again...." -ForegroundColor Red
                [double]$currentBalance = Get-TokenBalance -TokenCode $tokenCode
                if($currentBalance -eq $check){
                    Write-Host "Last chance" -ForegroundColor Red
                    [double]$currentBalance = Get-TokenBalance -TokenCode $tokenCode
                    if($currentBalance -eq $check){
                        Write-Host "We're done" -ForegroundColor Red
                        return $currentBalance
                    }
                }
            }
        }
        else{
            [double]$check = $currentBalance
        }

        [int]$percent = 100 - (($expectedBalance / $currentBalance) * 100)
        while( $currentBalance -gt $expectedBalance -and $percent -gt 5 ){        
            [double]$currentBalance = Get-TokenBalance -TokenCode $tokenCode
            $percent = 100 - (($expectedBalance / $currentBalance) * 100)
            Write-Host "$($currentBalance) is above $($expectedBalance) by $($percent)%" -ForegroundColor Yellow
            [double]$tokensToSell = (1 - ($expectedBalance / $currentBalance) ) * 100
            Sell-Token -TokenIssuer $tokenIssuer -TokenCode $tokenCode -AmountOfTokenToSell $tokensToSell -Message $message -TelegramToken $telegramToken -Slipage $slipage -NoMessage -SafetyCount $safetyCount           
        }
    }
}

function Get-TelegramChat(){
    Param
        (
            [Parameter(Mandatory = $true)] $TelegramToken, 
            [Parameter(Mandatory = $false)][int] $Offset = "",
            [Parameter(Mandatory = $false)][switch] $Silent
        ) 

    $uri = "https://api.telegram.org/bot$($telegramToken)/getUpdates"
    if($offset -eq ""){
        [int] $offset = Get-Content .\config\offset.txt
        if(!$silent){
            Write-Host "Stored offset = $($offset)" -ForegroundColor Magenta
        }
    }
    
    $payload = @{
        offset = $offset
    }
    $response = (Invoke-RestMethod -Uri $uri -Method POST -ContentType "application/json" -Body ($payload | ConvertTo-Json -Depth 10)).result
    
    $updateId = $response[$response.count-1].update_id
    if(!$silent){
        Write-Host "UpdateID = $($updateId)" -ForegroundColor Magenta
    }
    Set-Offset -Offset $updateId

    if(!$silent){
        $alert = $response[$response.count -1].message.text
        if($alert -eq 'test'){
            Write-Host "Test received"
            Send-TelegramMessage -ChatId "@ForwardingAlert" -Message "Test received"
        } 
        else {
            $messageId = $response[$response.count -1].message.message_id
            $tokenName = Get-TokenNameFromAlert -Alert $alert
            $title = Get-AlertTypeFromAlert -Alert $alert
            Write-Host "There are $($response.result.count) alerts, the last message ID = $($messageId)"
            Write-Host "The last alert is a $($title) for $($tokenName)"
        }
    }    
    return $response
}

function Monitor-Alerts(){
    Param
        (
            [Parameter(Mandatory = $false)][string] $ChatId = "@testgroupjbn121",
            [Parameter(Mandatory = $true)] $TelegramToken,
            [Parameter(Mandatory = $false)][switch] $Silent,          
            [Parameter(Mandatory = $false)] $WaitTime = 300, # In seconds
            [Parameter(Mandatory = $false)] $Count
        )
    $standardBuy = Get-StandardBuy
    $chat = Get-TelegramChat -TelegramToken $telegramToken
    $count = $chat.update_id.count
    $loop = $true
    while($loop -eq $true){
        Write-Host "." -NoNewline
        Start-Sleep -Seconds 5
                
        if($silent){
            $chat = Get-TelegramChat -TelegramToken $telegramToken -Silent
        } else {
            $chat = Get-TelegramChat -TelegramToken $telegramToken
        }
        if($chat.count -gt $count){
            $i = $chat.count - $count 
            while($i -gt 0 -and $loop -eq $true){
                $newTokenAlert = $chat[$chat.count -$i].message.text
                $i--
                $alertType = Get-AlertTypeFromAlert -Alert $newTokenAlert -Silent
                
                # Set Standard buy
                if($newTokenAlert -like "*standardbuy*"){
                    Write-Host "Setting standard buy"
                    $standardBuy = $newTokenAlert.split('=')[1]
                    $standardBuy = $standardBuy.replace(' ','')
                    Set-StandardBuy -StandardBuy $standardBuy
                    Send-TelegramMessage -ChatId "@ForwardingAlert" -Message "Standard buy set to $($standardBuy)"
                    Send-TelegramMessage -ChatId "@testgroupjbn121" -Message "done"
                }
                
                # When an alert comes in, do the following
                if($alertType -eq 'New Token Alert'){
                    Write-Host ""
                    Write-Host "*** NEW TOKEN ***" -ForegroundColor Green
                                        
                    $tokenIssuer = Get-TokenIssuerFromAlert -Alert $newTokenAlert
                    $tokenName = Get-TokenNameFromAlert -Alert $newTokenAlert
                    Set-TokenName -TokenName $tokenName
                    $tokenCode = Get-TokenCodeFromName -TokenName $tokenName
                    Set-TokenCode -TokenCode $tokenCode 
                    Test-TokenCode -TokenCode $tokenCode -TokenName $tokenName -TokenIssuer $tokenIssuer
                    $tokenCode = Get-TokenCode
                    Log-Token -Action NewToken -TokenName -$tokenName

                    # Open a new powershell window
                    Write-host "starting new shell"
                    $chat = Get-TelegramChat -TelegramToken $telegramToken
                    $count = $chat.update_id.count
                    
                    Start-Process -FilePath "powershell.exe" -ArgumentList "-NoExit", "-File", ".\scripts\GoBabyGo.ps1", "-Count", "$count", "-ignoreInit" 

                    # Send alert
                    Send-TelegramMessage -ChatId "@ForwardingAlert" -Message "New token - $($tokenName)"
                    Write-Host "(this can be deleted its just to confirm we exited the Send-TelegramMessage function)"
                    Write-Host "Token code = $($tokenCode)"

                    # Get the initial price of the new token                    
                    [double]$initialPrice = Get-TokenPrice -TokenCode $tokenCode -TokenIssuer $tokenIssuer
                    # check a price was returned
                    if($initialPrice -eq -1){
                        Write-Host "Token code not right, skipping token. TokenCode = $($tokenCode)" -ForegroundColor Red
                        break OuterLoop  
                    }
                    while($null -eq $initialPrice){
                        [double]$initialPrice = Get-TokenPrice -TokenCode $tokenCode -TokenIssuer $tokenIssuer
                    }

                    # Monitor the token to see if price has increases within $waitTime (in seconds)
                    $action = Monitor-NewTokenPrice -TokenCode $tokenCode -TokenIssuer $tokenIssuer -InitialPrice $initialPrice -WaitTime $waitTime                    
                    while($action -eq 'hold'){
                        $action = Monitor-NewTokenPrice -TokenCode $tokenCode -TokenIssuer $tokenIssuer -InitialPrice $initialPrice -WaitTime $waitTime -StartIncriment 240                      
                    }
                    if($action -eq 'buy'){
                        Create-TrustLine -TokenIssuer $tokenIssuer -TokenCode $tokenCode
                        Buy-Token -XrpAmount $standardBuy -TokenCode $tokenCode -TokenIssuer $tokenIssuer
                        $buyTime = Get-Date
                        $buyPrice = Get-BuyPrice
                        #Monitor-NewPosition -TokenIssuer $tokenIssuer -TokenCode $tokenCode -BuyPrice $buyPrice -BuyTime $buyTime
                        Recover-BuyIn -TokenIssuer $tokenIssuer -TokenCode $tokenCode -BuyPrice $buyPrice -BuyTime $buyTime -SellPercentage 160 -DoNotRecoverBuyIn
                        #Monitor-ExistingPosition -TokenIssuer $tokenIssuer -TokenCode $tokenCode -BuyPrice $buyPrice -BuyTime $buyTime
                        SellConservativly -TokenIssuer $tokenIssuer -TokenCode $tokenCode -SellAtPercentage 125 -BuyPrice $buyPrice -BuyTime $buyTime
                        Monitor-EstablishedPosition -TokenIssuer $tokenIssuer -TokenCode $tokenCode -BuyPrice $buyPrice -BuyTime $buyTime -StopNumber 1
                        $loop = $false
                        break
                    } 
                    if($action -eq 'abandone'){
                        Write-Host "Token lost money, abandoning token" -ForegroundColor Red
                        ExitShell
                    }
                }
            }
        }
    }
}