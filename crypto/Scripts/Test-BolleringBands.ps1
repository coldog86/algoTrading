$fileNames = @('CryptoModule.psm1', 'StrategyModule.psm1')
$logFolder = "c:\crypto\log"
$tokenName = 'WWXD'
$trainingtime = 10


foreach ($fileName in $fileNames){  
    $moduleName = $filename.replace('.psm1','')
    Remove-Module -Name $moduleName -Force
    Import-Module c:\crypto\scripts -Force -WarningAction Ignore
}

# Get token CSV
$csvData = Import-Csv -Path "$logFolder\$tokenName.csv"
$earliestRecord = ($csvData | Sort-Object DateTime | Select-Object -First 1).DateTime

$trainingData = 