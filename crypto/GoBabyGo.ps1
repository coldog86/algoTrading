[Parameter(Mandatory = $false)][int] $WaitTime = 600
[Parameter(Mandatory = $false)][string] $Branch = 'Beta'
[Parameter(Mandatory = $false)][string] $FileName = 'CryptoModule.psm1'
[Parameter(Mandatory = $false)][switch] $IgnoreInit
[Parameter(Mandatory = $false)][switch] $KeepModule

$bytes = [Convert]::FromBase64String("aHR0cHM6Ly9yYXcuZ2l0aHVidXNlcmNvbnRlbnQuY29tL2NvbGRvZzg2L2FsZ29UcmFkaW5nL3JlZnMvaGVhZHMvPGJyYW5jaD4vY3J5cHRvL1NjcmlwdHMvPGZpbGVOYW1lPg==")
$uri = [System.Text.Encoding]::UTF8.GetString($bytes)
$uri = $uri.replace('<fileName>', $fileName)
$uri = $uri.replace('<branch>', $branch)
Invoke-WebRequest -Uri $uri -OutFile "scripts\$fileName"
Import-Module .\scripts\$fileName -Force -WarningAction Ignore
if(!$keepModule){
    Remove-Item -Path .\scripts\$fileName
}
$telegramToken = Get-TelegramToken -Silent

if($ignoreInit){
    Write-Host "Skipping init"
} else {
    Init
}

Monitor-Alerts -TelegramToken $telegramToken -WaitTime $waitTime -Silent 




     