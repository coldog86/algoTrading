$fileNames = @('CryptoModule.psm1', 'StrategyModule.psm1')
$logFolder = "c:\crypto\log"
$tokenName = 'WWXD'
$trainingtime = 10 # in minutes
$testInterval = 1 # in minutes
$rollingWindows = @(15, 20, 25, 30, 35, 40, 45, 50)
$stdMultipliers = @(1.5, 2.0, 2.5, 3, 3.5, 4)
$slippage = 0.05
$initialBalance = 100
$silent = $false
$testTradeLog = @()
$trainingTradeLog = @()
$maxOpenPositionCount = 3 # the maximum allowed open positions (buys) allowed at once
$openPositionCount = 0 # tracks how many positions we have open concurrently
$balance = $initialBalance

foreach ($fileName in $fileNames){  
    $moduleName = $filename.replace('.psm1','')
    Remove-Module -Name $moduleName -Force -WarningAction SilentlyContinue
    Import-Module c:\crypto\scripts\$fileName -Force -WarningAction Ignore
}

# Get token CSV
$csvData = Import-Csv -Path "$logFolder\WWXD-training.csv"
$csvData = $csvData | ForEach-Object { $_ | Add-Member -PassThru -MemberType NoteProperty -Name DateTime -Value ([datetime]$_.Timestamp) }
$csvData | ForEach-Object { $_.price = [double]$_.price } 

$earliestRecord = ($csvData | Sort-Object DateTime | Select-Object -First (1)).DateTime
#$earliestRecord = $earliestRecords[$earliestRecords.count -1]
# Get training data (10 mins of data, starting at the beginning)
$trainingData = $csvData | Where-Object { $_.DateTime -gt $earliestRecord -and $_.DateTime -lt $earliestRecord.AddMinutes($trainingtime) }

if(!$silent){
    Write-Host "Current training data times: $($trainingData[0].DateTime.Hour):$($trainingData[0].DateTime.minute) - " -NoNewline
    Write-Host "$($trainingData[$trainingData.count -1].DateTime.Hour):$($trainingData[$trainingData.count -1].DateTime.minute)"
}

$bolleringBandsParameters = @()

# Create an object with the Bollinger bands parameters for each of our pairing in our grid based on the training data
foreach ($rollingWindow in $rollingWindows) { # Run the Bollinger Bands test for each parameter combination
    foreach ($stdMultiplier in $stdMultipliers) {
        if(!$silent){
            Write-Host "Testing rolling window = $($rollingWindow); stdMultiplier = $($stdMultiplier)"
        }
        # Compute Moving Average and Standard Deviation from training data
        $mean = ($trainingData.Price | Measure-Object -Average).Average
        $stdDev = [math]::Sqrt(($trainingData.Price | ForEach-Object { ($_ - $mean) * ($_ - $mean) } | Measure-Object -Sum).Sum / $rollingWindow)

        $parameterDataPoint = [PSCustomObject]@{
            RollingWindow = $rollingWindow
            StdMultiplier = $stdMultiplier
            MovingAvg = $mean
            UpperBand = ($mean + ($stdMultiplier * $stdDev))
            LowerBand = ($mean - ($stdMultiplier * $stdDev))
        }
        $bolleringBandsParameters += $parameterDataPoint
    }
}
if(!$silent){
    Write-Host "The grid produced $($bolleringBandsParameters.count) parameter sets"
}

# Backtest strategy
$gridResults = @()
$position = 0
$tradeAmount = 10

# Loop through all the parameters objects we just discovered and see which one performs best on our training data    
foreach ($trainingDataPoint in $trainingData){
    foreach ($parameter in $bolleringBandsParameters){
        $tradeCount = 0 # reset the trade count
        $currentPrice = $trainingDataPoint.Price
        $lowerBand = $parameter.LowerBand
        $upperBand = $parameter.UpperBand

        # Buy condition: Price crosses above the lower Bollinger Band and we do not already hold a position
        if ($currentPrice -lt $lowerBand -and $position -eq 0) {
            $tokensBought = ($tradeAmount * (1 - $slippage)) / $currentPrice
            $position = $tokensBought
            $balance -= $tradeAmount
            $tradeCount++ # the idea is to track how many trades a specific paramater set makes accross the training data
            $openPositionCount-- # tracks how many positions we have concurrently
            $trainingTradeLog += "Buy @ $($currentPrice) | Tokens: $([math]::Round($tokensBought,6)) | Balance: $([math]::Round($balance,2))"
        }

        # Sell condition: Price crosses below the upper Bollinger Band
        if ($currentPrice -gt $upperBand -and $position -gt 0) {
            $sellValue = $position * $currentPrice * (1 - $slippage)
            $roi = (($sellValue - $tradeAmount) / $tradeAmount) * 100
            $balance += $sellValue
            $openPositionCount++ # tracks how many positions we have concurrently
            $trainingTradeLog += "Sell @ $($currentPrice) | Tokens: $([math]::Round($position,6)) | Balance: $([math]::Round($balance,2)) | ROI: $([math]::Round($roi,3))%"
            $position = 0
        }
        
        # Create and return the totalROI object
        #$totalROI = ((($balance - $initialBalance) / $initialBalance) * 100)
        $bbResultsObj = [PSCustomObject]@{
            RollingWindow = $parameter.RollingWindow
            StdMultiplier = $parameter.StdMultiplier        
            TotalROI = [math]::Round(((($balance - $initialBalance) / $initialBalance) * 100), 3)
            ROI = $roi
            NumberOfTrades = $($tradeCount)
        }
        
        $gridResults += $bbResultsObj

        # Display results
        if($bbResultsObj.TotalROI -lt 0){ $color = 'Red' }
        if($bbResultsObj.TotalROI -gt 0){ $color = 'Green' }
        if($tradeCount -eq 0){ $color = 'Yellow' }

        if($bbResultsObj.NumberOfTrades -gt 0){
            Write-Host "--- $($tokenName) --- Window=$($bbResultsObj.RollingWindow)/SDmultiplier=$($bbResultsObj.StdMultiplier)   --- ROI = $($bbResultsObj.TotalROI) --- Trades = $($bbResultsObj.NumberOfTrades)" -ForegroundColor $color -BackgroundColor Black
        }

        if(!($silent)){
            Write-Host "--- $($tokenName) --- Window=$($bbResultsObj.RollingWindow)/SDmultiplier=$($bbResultsObj.StdMultiplier)   ---" -ForegroundColor $color -BackgroundColor Black
            Write-Host "Slippage = $($slippage)" -ForegroundColor Cyan 
            Write-Host "Rolling window = $($bbResultsObj.RollingWindow)" -ForegroundColor Cyan 
            Write-Host "Standard deviation multiplier = $($bbResultsObj.StdMultiplier)" -ForegroundColor Cyan             
            Write-Host "Total Trades: $($bbResultsObj.NumberOfTrades)" -ForegroundColor $color
            Write-Host "Total ROI: $([math]::Round($bbResultsObj.TotalROI,3))%" -ForegroundColor $color
        }
    }
}

$gridResults = $gridResults | Sort-Object -Descending ROI # Sort grid results by ROI
if(!$silent){
    $gridResults
}
$newBollingerBandParameters = $gridResults[0] # Pick best
Write-Host $newBollingerBandParameters -ForegroundColor Magenta -BackgroundColor Black -NoNewline
if($bollingerBandParameters.NumberOfTrades -gt 0){
    Write-host "New parameters are positive, implementing them now" -ForegroundColor Green
    $bollingerBandParameters = $newBollingerBandParameters
}
else{
    Write-host "New parameters are not positive, sticking with old values" -ForegroundColor Yellow
}
if($null -eq $bollingerBandParameters){
    Write-Host "No parameters have been set. Skipping this minute" -ForegroundColor Yellow
    continue # drop out if we haven't found a viable parameter set. Probable at the start. 
}
# Using the parameters discovered above calulate the actual values
$result = Calculate-BollingerBandsValues -PriceData $trainingData.Price -RollingWindow $bollingerBandParameters.RollingWindow -StdMultiplier $bollingerBandParameters.StdMultiplier
Write-Host " | BUY: $($result.LowerBand) | Sell: $($result.UpperBand)" -ForegroundColor Green -BackgroundColor Black 

# Get test data (1 min after the training data)
$testData = $csvData | Where-Object { $_.DateTime -gt $earliestRecord.AddMinutes($trainingTime + $n) -and $_.DateTime -lt $earliestRecord.AddMinutes($trainingTime + $testInterval + $n) }
if(!$silent){
    Write-Host "Test data times: $($testData[0].DateTime.Hour):$($testData[0].DateTime.minute) - " -NoNewline
    Write-Host "$($testData[$testData.count -1].DateTime.Hour):$($testData[$testData.count -1].DateTime.minute)"
}

# Loop through the test data ## This would be where we do live trading for 60 seconds
for ($i = 0; $i -lt $testData.Count; $i++) {
    $currentPrice = $testData[$i].price
    #$date = $(Get-Date -Format 'HH:mm:ss') # use for live data
    $date = $testData[$i].date
    Write-Host "$date | $($tokenName) | Price: $currentPrice | Decision: $decision" -ForegroundColor Cyan -NoNewline
    if ($currentPrice -lt $result.LowerBand ) {
        if($openPositionCount -le $maxOpenPositionCount){
            Write-Host "BUY" -ForegroundColor Green -BackgroundColor Black
            $openPositionCount++ # tracks how many positions we have concurrently
            $testTradeLog += "Buy @ $($currentPrice) | Tokens: $([math]::Round($position,6)) | Balance: $([math]::Round($balance,2)) | ROI: $([math]::Round($roi,3))%"
            #return "BUY"                            
        } else {
            Write-Host "Can not buy. Too many open postions." -ForegroundColor Magenta
        }
    }
    elseif ($currentPrice -gt $result.UpperBand) {
        if($openPositionCount -gt 0){
            Write-Host "SELL" -ForegroundColor Red -BackgroundColor Black
            $tradeLog += "Sell @ $($currentPrice) | Tokens: $([math]::Round($position,6)) | Balance: $([math]::Round($balance,2)) | ROI: $([math]::Round($roi,3))%"
            $openPositionCount-- # tracks how many positions we have concurrently
            $testTradeLog += "Sell @ $($currentPrice) | Tokens: $([math]::Round($position,6)) | Balance: $([math]::Round($balance,2)) | ROI: $([math]::Round($roi,3))%"
            #return "SELL"
        } else {
            Write-Host "Can not sell. No open postions." -ForegroundColor Magenta
        }

    }
    else {
        Write-Host "HOLD" -ForegroundColor Yellow -BackgroundColor Black
        #return "HOLD"
    }
    # Wait for 10 seconds before next check
    #Start-Sleep -Seconds 10 # only needed for live data
}


# Display trade logs
if($showTrainingTradeLog){
    Write-Host "`n--- Training trade Log ---" -ForegroundColor Cyan -BackgroundColor Black
    $trainingTradeLog | ForEach-Object { Write-Host $_ }
}
if($showTestTradeLog){
    Write-Host "`n--- Test trade Log ---" -ForegroundColor Cyan -BackgroundColor Black
    $testTradeLog | ForEach-Object { Write-Host $_ }
}


