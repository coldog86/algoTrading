param(
    [Parameter(Mandatory = $false)][string] $Branch = 'Beta',
    [Parameter(Mandatory = $false)][switch] $UseDefaultConfig,
    [Parameter(Mandatory = $false)][bool] $CollectDataOnly = $false,
    [Parameter(Mandatory = $false)][bool] $Silent = $true,
    [Parameter(Mandatory = $false)][switch] $PullRepoOnly,
    [Parameter(Mandatory = $false)][switch] $NoWriteBack,
    [Parameter(Mandatory = $false)][switch] $NoClip,
    [Parameter(Mandatory = $false)][string[]] $FileNames = "'CryptoModule.psm1', 'StrategyModule.psm1'",
    [Parameter(Mandatory = $false)][switch] $IgnoreInit
)

Write-Host "Accessing branch: " -NoNewline; Write-Host "$($branch)" -ForegroundColor Green -BackgroundColor Black
if($pullRepoOnly){
    Write-Host "Updating local files only" -ForegroundColor Yellow
}
# Import modules
$bytes = [Convert]::FromBase64String("aHR0cHM6Ly9yYXcuZ2l0aHVidXNlcmNvbnRlbnQuY29tL2NvbGRvZzg2L2FsZ29UcmFkaW5nL3JlZnMvaGVhZHMvPGJyYW5jaD4vY3J5cHRvL1NjcmlwdHMvPGZpbGVOYW1lPg==")
$uri = [System.Text.Encoding]::UTF8.GetString($bytes)
foreach($fileName in $fileNames){
    $uri = $uri.replace('<fileName>', $fileName)
    $uri = $uri.replace('<branch>', $branch)
    Invoke-WebRequest -Uri $uri -OutFile "scripts\$fileName"
    Import-Module .\scripts\$fileName -Force -WarningAction Ignore
    Remove-Item -Path .\scripts\$fileName
}

if($ignoreInit){
    Write-Host "Skipping init"
} else {
    Init -Branch $branch
}
if(!$pullRepoOnly){
    $telegramToken = Get-TelegramToken -Silent $silent
    Monitor-Alerts -TelegramToken $telegramToken -Silent $silent -CollectDataOnly $collectDataOnly
}




     