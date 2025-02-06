


function init(){
    param (
        [Parameter(Mandatory = $true)][string] $Branch
    )
    # Create folders and files
    Create-FolderStructure -Folders "config", "config\default", "Doco", "Log", "Log\Historic Data", "Scripts", "temp"
    Create-Script -Branch $branch -FileNames "Buy-Token.py", "Create-TrustLine.py", "Remove-TrustLine.py", "Sell-Token.py" -Folder '.\Scripts'
    Create-Script -Branch $branch -FileNames "GoBabyGo.ps1" -Folder '.'
    #Create-PythonScripts
    #Create-GoBabyGoScript
    Create-DefaultConfigs -Branch $branch -FileNames 'stops.csv', 'buyConditions.csv'
    Create-Doco -Branch $branch -FileNames 'ReadMe.txt', 'RoadMap.txt'
}

function Log-Price(){
    Param
        (
            [Parameter(Mandatory = $false)][string] $CurrentPrice,
            [Parameter(Mandatory = $false)][string] $TokenName,
            [Parameter(Mandatory = $false)][string] $LogFolder = ".\log\Historic Data"
        )
    $time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$time,$CurrentPrice" | Out-File -Append -Encoding utf8 -FilePath $logFolder\$tokenName.csv
}


function Create-DefaultConfigs(){
    param (
        [Parameter(Mandatory = $true)][string] $Branch,
        [Parameter(Mandatory = $true)][string[]] $FileNames
    )

    foreach ($fileName in $fileNames){
        Write-Host "Creating default configs ($($fileName))"
        $configFilePath = ".\config\$($fileName)"
        $defaultFilePath = ".\config\default\$($fileName)"
        Invoke-WebRequest -Uri "https://raw.githubusercontent.com/coldog86/algoTrading/refs/heads/$($branch)/crypto/config/$($fileName)" -OutFile $defaultFilePath   


        # Check if the file exists in config folder, copy if not present
        if (!(Test-Path -Path $configFilePath)) {        
            Copy-Item -Path $defaultFilePath -Destination $configFilePath
            Write-Output "File copied from default to active config: $fileName"        
        } else {
            Write-Output "File already exists in config folder: $configFilePath"
        }
    }
}

function Create-Doco(){
    param (
        [Parameter(Mandatory = $false)][string] $Branch = 'main',
        [Parameter(Mandatory = $true)][string[]] $FileNames
    )
    foreach ($fileName in $fileNames){
        Write-Host "Creating $($fileName) file"
        Invoke-WebRequest -Uri "https://raw.githubusercontent.com/coldog86/algoTrading/refs/heads/$($branch)/crypto/Doco/$($fileName)" -OutFile "Doco\$($fileName)"   
    }
}

function Create-FolderStructure(){
    param (        
        [Parameter(Mandatory = $true)][string[]] $Folders
    )
    
    foreach ($folder in $folders){
        $folderPath = ".\$folder"
        # Check if the folder exists
        if (!(Test-Path -Path $folderPath)) {
            # Create the folder if it does not exist
            New-Item -ItemType Directory -Path $folderPath -Force
            Write-Output "Folder created: $folderPath"
        } else {
            Write-Output "Folder already exists: $folderPath"
        }
    }    
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

function Set-Configuration(){
    param (
        [Parameter(Mandatory = $true)] $ConfigValue,
        [Parameter(Mandatory = $true)][string] $ConfigName,
        [Parameter(Mandatory = $false)][string] $FilePath = "./config/config.txt",
        [Parameter(Mandatory = $false)][switch] $Silent
    )

    $configContent = Get-Content -Path $filePath -Raw

    # Check if offset exists using regex
    if ($configContent -match "(?m)^\s*$($configName):\s*\d+") { 
        # Replace existing offset
        if(!$silent){
           Write-Host "Updating ($($configName))"
        }
        $configContent = $configContent -replace "(?m)^\s*$($configName):\s*\d+", "$($configName): $configValue"
    } else {
        # Append offset with a new line
        if(!$silent){
            Write-Host "Appending $($configName)"
        }
        $configContent += "`n$($configName): $configValue"
    }
    # Save config
    Set-Content -Path $filePath -Value $configContent
}
function Set-Offset(){
    param (
        [Parameter(Mandatory = $true)][string] $Offset,
        [Parameter(Mandatory = $false)][string] $FilePath = "./config/config.txt",
        [Parameter(Mandatory = $true)][switch] $Silent
    )

    $configContent = Get-Content -Path $filePath -Raw

    # Check if offset exists using regex
    if ($configContent -match "(?m)^\s*offset:\s*\d+") { 
        # Replace existing offset
        if(!$silent){
           Write-Host "Updating offset"
        }
        $configContent = $configContent -replace "(?m)^\s*offset:\s*\d+", "offset: $offset"
    } else {
        # Append offset with a new line
        if(!$silent){
            Write-Host "Appending offset"
        }
        $configContent += "`noffset: $offset"
    }
    # Save config
    Set-Content -Path $filePath -Value $configContent
}

function Get-Offset() {
    param (
        [Parameter(Mandatory = $false)][string] $FilePath = "./config/config.txt",
        [Parameter(Mandatory = $false)][switch] $Silent
    )
        
    $config = Get-Content -Path $filePath
    foreach($line in $config){
        if($line -like "offset:*"){
            $offset = $line.Split(': ')[2]
            if(!$silent){
                Write-Host "Offset = $($offset)" -ForegroundColor Green
            }
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
        [Parameter(Mandatory = $false)][string] $FilePath = "./config/config.txt",
        [Parameter(Mandatory = $false)][switch] $Silent
    )

    # Ensure the file exists
    if (-Not (Test-Path $filePath)) {
        Write-Host "Error: config.txt not found!" -ForegroundColor Red
        return
    }

     
    $config = Get-Content -Path $filePath
    foreach($line in $config){
        if($line -like "walletSecret:*"){ 
            if(!$silent){
                Write-Host $line -ForegroundColor cyan
            }
            $encodedSecret = $line.Split(': ')[2]  
        }
    }
    # Decode Base64
    try {
        $bytes = [Convert]::FromBase64String($encodedSecret)
        $decodedSecret = [System.Text.Encoding]::UTF8.GetString($bytes)
        return $decodedSecret
    } catch {
        Write-Host "Error: Invalid Base64 string!" -ForegroundColor Red
    }
}



function Set-TelegramToken {
    param (
        [Parameter(Mandatory = $false)][string] $TelegramToken = '7529656216:AAFliY-icP_51zmhKAscBoPOAwz88xo0HPA',
        [Parameter(Mandatory = $false)][string] $FilePath = "./config/config.txt"
    )

    # Convert to Base64
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($telegramToken)
    $encodedSecret = [Convert]::ToBase64String($bytes)
    
    Set-Configuration -ConfigName TelegramToken -ConfigValue $encodedSecret
}

function Get-TelegramToken {
    param (
        [Parameter(Mandatory = $false)][string] $FilePath = "./config/config.txt",
        [Parameter(Mandatory = $false)][switch] $Silent
    )

    # Ensure the file exists
    if (-Not (Test-Path $filePath)) {
        Write-Host "Error: config.txt not found!" -ForegroundColor Red
        return
    }
     
    $config = Get-Content -Path $filePath
    foreach($line in $config){
        if($line -like "telegramToken:*"){ 
            if(!$silent){
                write-host $line -ForegroundColor cyan
            }
            $encodedSecret = $line.Split(': ')[2]  
        }
    }
    # Decode Base64
    try {
        $bytes = [Convert]::FromBase64String($encodedSecret)
        $decodedSecret = [System.Text.Encoding]::UTF8.GetString($bytes)
        #Write-Host "Decrypted Secret: $decodedSecret" -ForegroundColor Green
        return $decodedSecret
    } catch {
        Write-Host "Error: Invalid Base64 string!" -ForegroundColor Red
    }
}


function Create-Script(){
    param (
        [Parameter(Mandatory = $false)][string] $Folder = ".",
        [Parameter(Mandatory = $true)][string[]] $FileNames,
        [Parameter(Mandatory = $false)][string] $Branch = 'main'
    )

    foreach ($fileName in $fileNames){
        Write-Host "Creating $($fileName) script" -ForegroundColor Magenta
        $uri = "https://raw.githubusercontent.com/coldog86/algoTrading/refs/heads/<branch>/crypto/Scripts/<fileName>"
        $uri = $uri.replace('<fileName>', $fileName); $uri = $uri.replace('<branch>', $branch)
        if($fileName -eq 'GoBabyGo.ps1'){
            $uri = $uri.Replace('Scripts/','')
        }
        Invoke-WebRequest -Uri $uri -OutFile "$folder\$fileName"
    }
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
        [Parameter(Mandatory = $true)][string] $WalletAddress,
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
        [Parameter(Mandatory = $true)][double] $InitialPrice,           
        [Parameter(Mandatory = $true)] $TokenCode,        
        [Parameter(Mandatory = $true)][string] $TokenIssuer,
        [Parameter(Mandatory = $false)][int] $StartIncriment = 0,
        [Parameter(Mandatory = $false)][string] $BuyConditionsFilePath = '.\config\buyConditions.csv'
    )

    
    $buyConditions = Import-Csv -Path $buyConditionsFilePath
    $buyConditions
    $number = $buyConditions.count-1
    $seconds = $buyConditions.Seconds[$number]

    Write-Host "Monitoring for $($seconds) seconds"
    $progressActivity = "Monitoring for $seconds seconds"
    $progressStatus = "Time remaining"
    # Array to track the percentage increases
    $percentageHistory = @()

    for ($i = $startIncriment; $i -lt $seconds; $i++) {   
        Log-Price -TokenName $tokenName -CurrentPrice $newPrice # log all the price data for a token with the intention of using AI to create a stratergy

        $percentComplete = [int](($i / $seconds) * 100)
        $timeRemaining = $seconds - $i
        [double]$newPrice = Get-TokenPrice -TokenCode $tokenCode -TokenIssuer $tokenIssuer
        [double]$percentageIncrease = "{0:F2}" -f ((($newPrice - $initialPrice) / $initialPrice) * 100)
        
        # Track the percentage increase for last 2 iterations
        $percentageHistory += $percentageIncrease
        if ($percentageHistory.Count -gt 2) {
            $percentageHistory = $percentageHistory[-2..-1]
        }

        # Add this check to only buy if price has not jumped +50% in the last 2 iterations
        if ($percentageHistory.Count -eq 2) {
            $lastIncreaseDiff = [math]::Abs($percentageHistory[-1] - $percentageHistory[-2])
            if ($lastIncreaseDiff -gt 50) {
                Write-Host "Skipping buy action: Price change is too volatile ($lastIncreaseDiff% change)" -ForegroundColor Yellow
                continue
            }
        }

        # Every 10 iterations show total percentage change
        if($i % 10 -eq 0){
            Write-Host "The percentage increase is $($percentageIncrease)%" -ForegroundColor Magenta
        }

        # Work out the required percentage increase as per buy conditions CSV
        $percentageIncreaseRequired = 250
        foreach ($buyCondition in $buyConditions){
            if($i -lt $buyCondition.Seconds){
                $percentageIncreaseRequired = $buyCondition.BuyCondition
                Write-Host "percentageIncreaseRequired = $($percentageIncreaseRequired)"
                break
            }
        }

        # Buy logic
        if($percentageIncrease -gt $percentageIncreaseRequired){
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
        [Parameter(Mandatory = $false)] $StartIncriment = 0
    )

    Write-Host "Initial Price = $($initialPrice)" -ForegroundColor Yellow
    Write-Host "Waiting for $($waitTime) seconds"
    
    $action = Sleep-WithPriceChecks -TokenCode $tokenCode -TokenIssuer $tokenIssuer -InitialPrice $initialPrice -StartIncriment $startIncriment
    
    if($action -eq "buy"){
        return $action
    }

    write-host "******** DOES THIS CODE EVER RUN ????????????????????"
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
        [Parameter(Mandatory = $true)][string] $TokenCode
    )
    
    $tokenName = Get-TokenName    
    
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
        [Parameter(Mandatory = $false)][string] $ChatId,
        [Parameter(Mandatory = $true)][string] $TelegramToken
    )
    
    $chat = Get-TelegramChat -TelegramToken $telegramToken -TelegramGroup $chatId
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
            [Parameter(Mandatory = $true)][string] $TokenCode,
            [Parameter(Mandatory = $false)] $Limit = 100000000 # default limit set to 100 million
        ) 
    
    $tokenName = Get-TokenName        
    Write-Host "Creating trust line for $($tokenName)" -ForegroundColor Cyan

    # parameters are: Issuer, currency_code, trust_limit
    # python C:\Users\cmcke\Documents\crypto\Create-TrustLine.py rGHtYnnigyuaHehWGfAdoEhkoirkGNdZzo 7363726170000000000000000000000000000000 10000
    # python C:\Users\cmcke\Documents\crypto\Create-TrustLine.py --issuer $tokenIssuer --currency_code $tokenCode --trust_limit $limit
    $secretNumbers = Get-WalletSecret
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
            [Parameter(Mandatory = $false)][string] $TokenCode,
            [Parameter(Mandatory = $true)][string] $TokenIssuer,            
            [Parameter(Mandatory = $false)] $Slipage = 0.05, # default 5% slip
            [Parameter(Mandatory = $false)][string] $Message,
            [Parameter(Mandatory = $false)][string] $TelegramToken = '7529656216:AAFliY-icP_51zmhKAscBoPOAwz88xo0HPA',            
            [Parameter(Mandatory = $false)][int] $Repeat = 3
        ) 
    
    $tokenName = Get-TokenName
    
    $tokenPrice = Get-TokenPrice -TokenCode $tokenCode -TokenIssuer $tokenIssuer
    $quantity = $xrpAmount / $tokenPrice
    $slipage = 1 - $slipage
    Write-Host "Slipage = $($slipage)" -ForegroundColor Magenta
    $amountToBuy = $quantity * $slipage
    $commission = $quantity - $amountToBuy
    
    Write-Host "Commision on this sale would be = $($commission)" -ForegroundColor Green -BackgroundColor Black

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
    $walletAddress = Get-WalletAddress
    [double]$initialTokenBalance = Get-TokenBalance -TokenCode $tokenCode -WalletAddress $walletAddress
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
    $result = python .\Scripts\Sell-Token.py $tokenIssuer $tokenCode $tokensToSell $minPrice $secretNumbers
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
    [double]$currentBalance = Get-TokenBalance -TokenCode $tokenCode -WalletAddress $walletAddress

    if($currentBalance -eq 0) {
        return $currentBalance
    }
    else {
        if($currentBalance -eq $check){
            Write-Host "balance hasn't changed, runing Get-TokenBalance again" -ForegroundColor Red
            Start-Sleep -Seconds 10
            [double]$currentBalance = Get-TokenBalance -TokenCode $tokenCode -WalletAddress $walletAddress
            if($currentBalance -eq $check){
                Write-Host "balance hasn't changed again...." -ForegroundColor Red
                [double]$currentBalance = Get-TokenBalance -TokenCode $tokenCode -WalletAddress $walletAddress
                if($currentBalance -eq $check){
                    Write-Host "Last chance" -ForegroundColor Red
                    [double]$currentBalance = Get-TokenBalance -TokenCode $tokenCode -WalletAddress $walletAddress
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
            [double]$currentBalance = Get-TokenBalance -TokenCode $tokenCode -WalletAddress $walletAddress
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
            [Parameter(Mandatory = $true)][string] $TelegramGroup, 
            [Parameter(Mandatory = $false)][int] $Offset = "",
            [Parameter(Mandatory = $false)][switch] $Silent
        ) 

    $uri = "https://api.telegram.org/bot$($telegramToken)/getUpdates"
    if($offset -eq ""){
        [int] $offset = Get-Offset -Silent
        if(!$silent){
            Write-Host "Stored offset = $($offset)" -ForegroundColor Magenta
        }
    }
    
    $payload = @{
        offset = $offset
    }
    $response = (Invoke-RestMethod -Uri $uri -Method POST -ContentType "application/json" -Body ($payload | ConvertTo-Json -Depth 10)).result
    $response = $response | ?{$_.message.text -like "*NEW TOKEN*"}

    $updateId = $response[$response.count-1].update_id
    if(!$silent){
        Write-Host "UpdateID = $($updateId)" -ForegroundColor Magenta
    }
    Set-Configuration -ConfigName 'offset' -ConfigValue $updateId -Silent

    if(!$silent){
        $alert = $response[$response.count -1].message.text
        if($alert -eq 'test'){
            Write-Host "Test received"
            Send-TelegramMessage -ChatId $telegramGroup -Message "Test received"
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
            [Parameter(Mandatory = $true)] $TelegramToken,
            [Parameter(Mandatory = $false)][switch] $Silent,          
            [Parameter(Mandatory = $false)] $WaitTime = 600 # In seconds
        )
    $standardBuy = Get-StandardBuy
    $userTelegramGroup = Get-UserTelegramGroup
    $adminTelegramGroup = Get-AdminTelegramGroup
    $chat = Get-TelegramChat -TelegramToken $telegramToken -TelegramGroup $adminTelegramGroup 
    Write-Host "Chat count = $($chat.update_id.count)" -ForegroundColor Yellow -BackgroundColor Black
    $count = $chat.update_id.count
    $loop = $true
    while($loop -eq $true){
        Write-Host "." -NoNewline
        Start-Sleep -Seconds 5
        $chat = Get-TelegramChat -TelegramToken $telegramToken -TelegramGroup $adminTelegramGroup -Silent 
        
        if($chat.count -gt $count){
            $i = $chat.count - $count 
            #while($i -gt 0 -and $loop -eq $true){
                $newTokenAlert = $chat[$chat.count -$i].message.text
                $i--
                $alertType = Get-AlertTypeFromAlert -Alert $newTokenAlert -Silent
                
                # Set Standard buy
                if($newTokenAlert -like "*standardbuy*"){
                    Write-Host "Setting standard buy"
                    $standardBuy = $newTokenAlert.split('=')[1]
                    $standardBuy = $standardBuy.replace(' ','')
                    Set-StandardBuy -StandardBuy $standardBuy
                    Send-TelegramMessage -ChatId $userTelegramGroup -Message "Standard buy set to $($standardBuy)"
                    Send-TelegramMessage -ChatId $adminTelegramGroup -Message "done"
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
                    $chat = Get-TelegramChat -TelegramToken $telegramToken -TelegramGroup $adminTelegramGroup 
                    $count = $chat.update_id.count
                    
                    Start-Process -FilePath "powershell.exe" -ArgumentList "-NoExit", "-File", ".\GoBabyGo.ps1", "-Count", "$count"

                    # Send alert
                    Send-TelegramMessage -ChatId $userTelegramGroup -Message "New token - $($tokenName)"
                    Write-Host "(this can be deleted its just to confirm we exited the Send-TelegramMessage function)"
                    Write-Host "Token code = $($tokenCode)"

                    # Get the initial price of the new token                    
                    [double]$initialPrice = Get-TokenPrice -TokenCode $tokenCode -TokenIssuer $tokenIssuer
                    
                    while($null -eq $initialPrice){
                        [double]$initialPrice = Get-TokenPrice -TokenCode $tokenCode -TokenIssuer $tokenIssuer
                    }

                    # Monitor the token to see if price has increases within the time as defined in the BuyConditions CSV
                    $action = Monitor-NewTokenPrice -TokenCode $tokenCode -TokenIssuer $tokenIssuer -InitialPrice $initialPrice                  
                    while($action -eq 'hold'){
                        $action = Monitor-NewTokenPrice -TokenCode $tokenCode -TokenIssuer $tokenIssuer -InitialPrice $initialPrice -StartIncriment 240                      
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
                        #ExitShell
                    }
                }
            #}
        }
    }
}