param(
    [Parameter(Mandatory = $false)][string] [ValidateSet('StopLoss', 'BolleringBands')] $Strategy = 'BolleringBands',    
    [Parameter(Mandatory = $false)][string] $Branch = 'Beta',
    [Parameter(Mandatory = $false)][switch] $UseDefaultConfig,
    [Parameter(Mandatory = $false)][bool] $CollectDataOnly = $false,
    [Parameter(Mandatory = $false)][bool] $Silent = $true,
    [Parameter(Mandatory = $false)][switch] $PullRepoOnly,
    [Parameter(Mandatory = $false)][switch] $NoWriteBack,
    [Parameter(Mandatory = $false)][switch] $NoClip,
    [Parameter(Mandatory = $false)][string[]] $FileNames = @('CryptoModule.psm1', 'StrategyModule.psm1'),
    [Parameter(Mandatory = $false)][switch] $IgnoreInit
)

Write-Host "Accessing branch: " -NoNewline; Write-Host "$($branch)" -ForegroundColor Green -BackgroundColor Black
$versionNumber = Get-VersionNumber
Write-Host "Version: $($versionNumber)" -ForegroundColor Green -BackgroundColor Black

if($pullRepoOnly){
    Write-Host "Updating local files only" -ForegroundColor Yellow
}
# Import modules
$bytes = [Convert]::FromBase64String("aHR0cHM6Ly9yYXcuZ2l0aHVidXNlcmNvbnRlbnQuY29tL2NvbGRvZzg2L2FsZ29UcmFkaW5nL3JlZnMvaGVhZHMvPGJyYW5jaD4vY3J5cHRvL1NjcmlwdHMvPGZpbGVOYW1lPg==")
$uri = [System.Text.Encoding]::UTF8.GetString($bytes)
foreach($fileName in $fileNames){
    $newUri = $uri.replace('<fileName>', $fileName)
    $newUri = $newUri.replace('<branch>', $branch)
    Invoke-WebRequest -Uri $newUri -OutFile "scripts\TEMP-$fileName"
    
    # compare new and old modules for differences
    # Get the hash of both files
    $hash1 = Get-FileHash "scripts\TEMP-$fileName" -Algorithm SHA256
    $hash2 = Get-FileHash "temp\$fileName" -Algorithm SHA256
    if ($hash1.Hash -ne $hash2.Hash) {
        Write-Host "New $($fileName) is different - Importing" -ForegroundColor Yellow
        Import-Module .\scripts\$fileName -Force -WarningAction Ignore
        $hash = Get-FileHash "scripts\$fileName" -Algorithm SHA256 
        $hash > "temp\$fileName"
    } else {
        Write-Host "New $($fileName) is identical to existing module" -ForegroundColor Green
    }
    Remove-Item -Path .\scripts\$fileName
}

if($ignoreInit){
    Write-Host "Skipping init"
} else {
    Init -Branch $branch
}
if(!$pullRepoOnly){
    $telegramToken = Get-TelegramToken -Silent $silent
    Write-Host "Running $($strategy) strategy" -ForegroundColor Magenta -BackgroundColor Black
    Monitor-Alerts -Strategy $strategy -TelegramToken $telegramToken -Silent $silent -CollectDataOnly $collectDataOnly
}




     