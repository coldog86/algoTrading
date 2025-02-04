function setupBot(){
    param (
        [Parameter(Mandatory = $true)][string] $Branch
    )
    cd\
    mkdir crypto\scripts
    cd crypto
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/coldog86/algoTrading/refs/heads/$($branch)/crypto/Scripts/CryptoModule.psm1" -OutFile ".\scripts\CryptoModule.psm1"
    Import-Module .\CryptoModule.psm1 -Force -WarningAction Ignore

    # Create folders
    Create-FolderStructure

    # Create default running config
    Create-DefaultConfigs -Branch $branch -FileNames 'stops.csv', 'buyConditions.csv'
    Create-Doco -Branch $branch -FileNames 'ReadMe.txt', 'RoadMap.txt'
    
    # Set up config file    
    New-Item -Path .\config -Name config.txt # create blank config file    
    $walletAddress = Read-Host "Please enter wallet address (it will look something like this 'rDXgW8ZdcPwmSzEzK7s45V6xeSwuwgiVYG')"
    Set-WalletAddress -WalletAddress $walletAddress
    $secretNumbers = Read-Host "Please enter wallet secret numbers (it must look something like this '261821 261821 261821 261821 261821 261821 261821 261821')"
    Set-WalletSecret -SecretNumbers $secretNumbers
    $userTelegramGroup = Read-Host "Please enter the name of the Telegram group you added the bot to" 
    Set-UserTelegramGroup -UserTelegramGroup $userTelegramGroup
    Set-AdminTelegramGroup -UserTelegramGroup @testgroupjbn121
        
    # create scripts
    Create-PythonScripts
    Create-GoBabyGoScript
}

setupBot
