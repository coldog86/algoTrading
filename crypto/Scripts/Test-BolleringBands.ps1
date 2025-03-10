$fileNames = @('CryptoModule.psm1', 'StrategyModule.psm1')
$logFolder = "c:\crypto\log"
$tokenName = 'WWXD'
$trainingtime = 10 # in minutes


foreach ($fileName in $fileNames){  
    $moduleName = $filename.replace('.psm1','')
    Remove-Module -Name $moduleName -Force -WarningAction SilentlyContinue
    Import-Module c:\crypto\scripts\$fileName -Force -WarningAction Ignore
}

# Get token CSV
$csvData = Import-Csv -Path "$logFolder\$tokenName.csv"
$csvData = $csvData | ForEach-Object { $_ | Add-Member -PassThru -MemberType NoteProperty -Name DateTime -Value ([datetime]$_.Timestamp) }
$earliestRecord = ($csvData | Sort-Object DateTime | Select-Object -First 1).DateTime

# Get training data. 
$trainingData = $csvData | Where-Object { $_.DateTime -lt $earliestRecord.AddMinutes($trainingtime) }
Write-Host "Current training data times: " -NoNewline
Write-Host "$($trainingData[0].DateTime.Hour):$($trainingData[0].DateTime.minute)" -NoNewline
Write-Host " - " -NoNewline
Write-Host "$($trainingData[$trainingData.count -1].DateTime.Hour):$($trainingData[$trainingData.count -1].DateTime.minute)"

# Get the best paramaters for the Bollering bands strategy using the training data
$gridResults = Run-BollingerBandsGridSearch -CsvFile $trainingData -RollingWindows @(15, 20, 25, 30, 35, 40, 45, 50) -StdMultipliers @(1.5, 2.0, 2.5, 3, 3.5, 4) -Slippage 0.05 -Silent $true
$gridResults = $gridResults | Sort-Object -Descending TotalROI
$bollingerBandParameters = $gridResults[0]
Write-Host $bollingerBandParameters -ForegroundColor Magenta -BackgroundColor Black -NoNewline

$csvData | gm
$trainingData | gm
