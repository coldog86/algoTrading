[Parameter(Mandatory = $false)][int] $WaitTime
[Parameter(Mandatory = $false)][int] $Count

if($null -eq $waitTime){
    $waitTime = 600
} 
if($null -eq $count){
    $count = 0
} 

Import-Module 'E:\cmcke\Documents\Crypto\CryptoModule.psm1' -Force -WarningAction Ignore
$telegramToken = Get-TelegramToken
Write-Host "Count = $($count)"
Monitor-Alerts -TelegramToken $telegramToken -WaitTime $waitTime -Silent -count $count


$chat = Get-TelegramChat -TelegramToken $telegramToken
            $count = $chat.update_id.count
            Write-Host "count == $($count)"