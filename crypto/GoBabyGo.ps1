[Parameter(Mandatory = $false)][int] $WaitTime
[Parameter(Mandatory = $false)][int] $Count
[Parameter(Mandatory = $false)][string] $Username = "coldog86"
[Parameter(Mandatory = $false)][string] $Repo = 'algoTrading'
[Parameter(Mandatory = $false)][string] $Branch = 'Beta'
[Parameter(Mandatory = $false)][string] $Folder = 'crypto'
[Parameter(Mandatory = $false)][string] $FileName = 'CryptoModule.psm1'

if($null -eq $waitTime){
    $waitTime = 600
} 
if($null -eq $count){
    $count = 0
} 

Invoke-WebRequest -Uri "https://raw.githubusercontent.com/$($username)/$($repo)/refs/heads/$($branch)/$($folder)/$($fileName)" -OutFile $fileName
Import-Module .\$fileName -Force -WarningAction Ignore


Import-Module 'E:\cmcke\Documents\Crypto\CryptoModule.psm1' -Force -WarningAction Ignore
$telegramToken = Get-TelegramToken
Write-Host "Count = $($count)"
Monitor-Alerts -TelegramToken $telegramToken -WaitTime $waitTime -Silent -count $count


$chat = Get-TelegramChat -TelegramToken $telegramToken
            $count = $chat.update_id.count
            Write-Host "count == $($count)"
