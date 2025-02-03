[Parameter(Mandatory = $false)][int] $WaitTime
[Parameter(Mandatory = $false)][int] $Count
[Parameter(Mandatory = $false)][string] $Username = "coldog86"
[Parameter(Mandatory = $false)][string] $Repo = 'algoTrading'
[Parameter(Mandatory = $false)][string] $Branch = 'Beta'
[Parameter(Mandatory = $false)][string] $Folder = 'crypto/scripts'
[Parameter(Mandatory = $false)][string] $FileName = 'CryptoModule.psm1'

if($null -eq $waitTime){
    $waitTime = 600
} 
if($null -eq $count){
    $count = 0
} 
Write-Host "https://raw.githubusercontent.com/$($username)/$($repo)/refs/heads/$($branch)/$($folder)/$($fileName)"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/$($username)/$($repo)/refs/heads/$($branch)/$($folder)/$($fileName)" -OutFile $fileName
Import-Module .\$fileName -Force -WarningAction Ignore


Import-Module 'E:\cmcke\Documents\Crypto\CryptoModule.psm1' -Force -WarningAction Ignore
$telegramToken = Get-TelegramToken
Write-Host "Count = $($count)"
Monitor-Alerts -TelegramToken $telegramToken -WaitTime $waitTime -Silent -count $count


$chat = Get-TelegramChat -TelegramToken $telegramToken
            $count = $chat.update_id.count
            Write-Host "count == $($count)"

# https://raw.githubusercontent.com/coldog86/algoTrading/refs/heads/Beta/crypto/Scripts/CryptoModule.psm1
# https://raw.githubusercontent.com/coldog86/algoTrading/refs/heads/Beta/crypto/CryptoModule.psm1