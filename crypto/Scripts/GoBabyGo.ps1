[Parameter(Mandatory = False)][int] 
[Parameter(Mandatory = False)][int] 

if( -eq ){
     = 600
} 
if( -eq ){
     = 0
} 

Import-Module '.\scripts\CryptoModule.psm1' -Force -WarningAction Ignore
 = Get-TelegramToken
Write-Host "Count = "
Monitor-Alerts -TelegramToken  -WaitTime  -Silent -count 


 = Get-TelegramChat -TelegramToken 
             = .update_id.count
            Write-Host "count == "
