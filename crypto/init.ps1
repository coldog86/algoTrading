function setupBot(){
    cd\
    mkdir crypto\scripts
    cd crypto
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/coldog86/algoTrading/refs/heads/Beta/crypto/Scripts/CryptoModule.psm1" -OutFile ".\scripts\CryptoModule.psm1"
    Import-Module .\CryptoModule.psm1 -Force -WarningAction Ignore

    # Create folders
    Create-FolderStructure

    # Create default running config
    Create-DefaultConfigs -Branch 'Beta' -FileName 'stops.csv'
    Create-DefaultConfigs -Branch 'Beta' -FileName 'buyCondition.csv'
    Create-Doco -Branch 'Beta' -FileName 'ReadMe.txt'
    Create-Doco -Branch 'Beta' -FileName 'RoadMap.txt'
    $useDefaultConfigs = Read-Host "Use default stops and buy conditions as active config (this will over write any custom config) (y/n)"
    if($useDefaultConfigs -eq 'y'){
        Get-ChildItem -Path .\config\default | Copy-Item -Destination .\config
    }
    # Set up config file    
    New-Item -Path .\config -Name config.txt # create blank config file    
    $walletAddress = Read-Host "Please enter wallet address (it will look something like this 'rDXgW8ZdcPwmSzEzK7s45V6xeSwuwgiVYG')"
    Set-WalletAddress -WalletAddress $walletAddress
    $secretNumbers = Read-Host "Please enter wallet secret numbers (it must look something like this '261821 261821 261821 261821 261821 261821 261821 261821')"
    Set-WalletSecret -SecretNumbers $secretNumbers
    $userTelegramGroup = Read-Host "Please enter the name of the Telegram group you added the bot to" 
    Set-UserTelegramGroup -UserTelegramGroup $userTelegramGroup
    $adminTelegramGroup = Read-Host "Use default for admin telegram group? (y/n)"
    if($adminTelegramGroup -eq 'n'){
        $adminTelegramGroup = Read-Host "Please enter the name of the admin Telegram group"
        Set-UserTelegramGroup -UserTelegramGroup $userTelegramGroup
    } else {
        Set-UserTelegramGroup -UserTelegramGroup @testgroupjbn121
    }    

    # create scripts
    Create-PythonScripts
    Create-GoBabyGoScript
}