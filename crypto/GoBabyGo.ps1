[Parameter(Mandatory = $false)][int] $WaitTime = 600
[Parameter(Mandatory = $false)][int] $Count = 0
[Parameter(Mandatory = $false)][string] $Username = "coldog86"
[Parameter(Mandatory = $false)][string] $Repo = 'algoTrading'
[Parameter(Mandatory = $false)][string] $Branch = 'Beta'
[Parameter(Mandatory = $false)][string] $Folder = 'crypto/Scripts'
[Parameter(Mandatory = $false)][string] $FileName = 'CryptoModule.psm1'
[Parameter(Mandatory = $false)][switch] $ignoreInit

#Write-Host "https://raw.githubusercontent.com/$($username)/$($repo)/refs/heads/$($branch)/$($folder)/$($fileName)"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/$($username)/$($repo)/refs/heads/$($branch)/$($folder)/$($fileName)" -OutFile "scripts\$fileName"
Import-Module .\scripts\$fileName -Force -WarningAction Ignore

Write-Host "*** PROOF IT OVERWRITES ***"

$telegramToken = Get-TelegramToken
Monitor-Alerts -TelegramToken $telegramToken -WaitTime $waitTime -Silent -count $count

if(!$ignoreInit){
    init
}

$chat = Get-TelegramChat -TelegramToken $telegramToken
$count = $chat.update_id.count
Write-Host "count == $($count)"


<#     

$Username = "coldog86"
$Repo = 'algoTrading'
$Branch = 'Beta'
$Folder = 'crypto/Scripts'
$FileName = 'CryptoModule.psm1'
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/$($username)/$($repo)/refs/heads/$($branch)/$($folder)/$($fileName)" -OutFile "scripts\$fileName"
Import-Module .\scripts\$fileName -Force -WarningAction Ignore

$telegramToken = Get-TelegramToken
$telegramToken
Monitor-Alerts -TelegramToken $telegramToken -WaitTime $waitTime -Silent -count $count


#>