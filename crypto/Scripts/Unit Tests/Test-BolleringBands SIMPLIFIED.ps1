$iterationCount = 2 # this is the number of loops
$modulesFileNames = @('CryptoModule.psm1', 'StrategyModule.psm1')
$logFolder = "c:\crypto\log"
$tokenName = 'WWXD'
$trainingtime = 30 # in minutes
$silent = $false
$initialBalance = 100
$bolleringBandsParameters = @()
$rollingWindows = @(15, 20, 25, 30, 35, 40, 45, 50)
$stdMultipliers = @(1.5, 2.0, 2.5, 3, 3.5, 4)

# Back testing variables
$gridResults = @()
$tradeAmount = 10
$slippage = 0.05
$balance = $initialBalance
$maxOpenPositionCount = 3 # the maximum allowed open positions (buys) allowed at once
$openPositionCount = 0 # tracks how many positions we have open concurrently
$testTradeLog = @()

# Testing variables
$testInterval = 1 # in minutes
$trainingTradeLog = @()

# Load the Crypto & Strategy modules
foreach ($fileName in $modulesFileNames){  
    $moduleName = $filename.replace('.psm1','')
    Remove-Module -Name $moduleName -Force -WarningAction SilentlyContinue
    Import-Module c:\crypto\scripts\$fileName -Force -WarningAction Ignore
}

# Get token CSV
$csvData = Import-Csv -Path "$logFolder\$tokenName.csv"
$csvData = $csvData | ForEach-Object { $_ | Add-Member -PassThru -MemberType NoteProperty -Name DateTime -Value ([datetime]$_.Timestamp) }
$csvData | ForEach-Object { $_.price = [double]$_.price } 

$earliestRecord = ($csvData | Sort-Object DateTime | Select-Object -First (1)).DateTime # Get earliest record from the dataset
$trainingDataSet = $csvData | Where-Object { $_.DateTime -gt $earliestRecord -and $_.DateTime -lt $earliestRecord.AddMinutes($trainingtime) } 
# Get training data (EarliestRecord + trainingTime = trainingDataSet)
for($i = 1; $i -le $iterationCount; $i++){        
    $latestRecord = ($trainingDataSet | Sort-Object DateTime | Select-Object -Last (1)).DateTime
    $newtrainingDataSet = $csvData | Where-Object { $_.DateTime -gt $latestRecord -and $_.DateTime -lt $latestRecord.AddMinutes($trainingtime) }    
}
if(!$silent){
    Write-Host "Current training data times: $($trainingDataSet[0].DateTime.Hour):$($trainingDataSet[0].DateTime.minute) - " -NoNewline
    Write-Host "$($trainingDataSet[$trainingDataSet.count -1].DateTime.Hour):$($trainingDataSet[$trainingDataSet.count -1].DateTime.minute)"
}

# Create an object with the Bollinger bands parameters for each of our pairing in our grid ($rollingWindows & $stdMultipliers) based on the training data
foreach ($rollingWindow in $rollingWindows) { # Run the Bollinger Bands test for each parameter combination
    foreach ($stdMultiplier in $stdMultipliers) {
        if(!$silent){
            Write-Host "Testing rolling window = $($rollingWindow); stdMultiplier = $($stdMultiplier)"
        }
        # Compute the actual Moving Average and Standard Deviation from training data
        $mean = ($trainingDataSet.Price | Measure-Object -Average).Average
        $stdDev = [math]::Sqrt(($trainingDataSet.Price | ForEach-Object { ($_ - $mean) * ($_ - $mean) } | Measure-Object -Sum).Sum / $rollingWindow)

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

#### Backtest strategy on the training data ####
# Loop through all the parameters objects we just discovered and see which one performs best on our training data    
foreach ($parameter in $bolleringBandsParameters){
    $tradeCount = 0 # reset the trade count
    $balance = $initialBalance
    $lowerBand = $parameter.LowerBand
    $upperBand = $parameter.UpperBand
    
    foreach ($trainingDataPoint in $trainingDataSet){
        $currentPrice = $trainingDataPoint.Price
        # Buy condition: Price crosses above the lower Bollinger Band and we do not already hold too many open positions
        if ($currentPrice -lt $lowerBand -and $openPositionCount -le $maxOpenPositionCount) {
            $tokensBought = ($tradeAmount * (1 - $slippage)) / $currentPrice
            $balance -= $tradeAmount
            $tradeCount++ # the idea is to track how many trades a specific paramater set makes accross the training data
            $openPositionCount++ # tracks how many positions we have concurrently
            $trainingTradeLog += "Buy @ $($currentPrice) | Tokens: $([math]::Round($tokensBought,6)) | Balance: $([math]::Round($balance,2))"
        }

        # Sell condition: Price crosses below the upper Bollinger Band
        if ($currentPrice -gt $upperBand -and $openPositionCount -gt 0) {
            $sellValue = $tokensBought * $currentPrice * (1 - $slippage)
            $tradeRoi = (($sellValue - $tradeAmount) / $tradeAmount) * 100
            $balance += $sellValue
            $openPositionCount-- # tracks how many positions we have concurrently
            $trainingTradeLog += "Sell @ $($currentPrice) | Tokens: $([math]::Round($tokensBought,6)) | Balance: $([math]::Round($balance,2)) | ROI: $([math]::Round($roi,3))%"            
        }
        
        # Create and return the totalROI object
        $bbResultsObj = [PSCustomObject]@{
            RollingWindow = $parameter.RollingWindow
            StdMultiplier = $parameter.StdMultiplier        
            TotalROI = [math]::Round(((($balance - $initialBalance) / $initialBalance) * 100), 3)
            TradeROI = $tradeRoi
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
            Write-Host "--- $($tokenName) --- Window=" -ForegroundColor $color -BackgroundColor Black -NoNewline
            Write-Host "$($bbResultsObj.RollingWindow)" -ForegroundColor $cyan -BackgroundColor Black -NoNewline
            Write-Host "/SDmultiplier=" -ForegroundColor $color -BackgroundColor Black -NoNewline
            Write-Host "$($bbResultsObj.StdMultiplier)" -ForegroundColor $cyan -BackgroundColor Black -NoNewline
            Write-Host "   --- ROI = $($bbResultsObj.TotalROI) --- Trades = $($bbResultsObj.NumberOfTrades)" -ForegroundColor $color -BackgroundColor Black
            Write-Host "Total Trades: $($bbResultsObj.NumberOfTrades)" -ForegroundColor $color
            Write-Host "Total ROI: $([math]::Round($bbResultsObj.TotalROI,3))%" -ForegroundColor $color
        }
    }
}

$gridResults = $gridResults | Sort-Object -Descending ROI # Sort grid results by ROI
if($logGridResults){ # TODO set this up
    $gridResults
}
$newBollingerBandParameters = $gridResults[0] # Pick best result
Write-Host $newBollingerBandParameters -ForegroundColor Magenta -BackgroundColor Black

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
$result = Calculate-BollingerBandsValues -PriceData $trainingDataSet.Price -RollingWindow $bollingerBandParameters.RollingWindow -StdMultiplier $bollingerBandParameters.StdMultiplier
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
            $tokensBought = ($tradeAmount * (1 - $slippage)) / $currentPrice
            $balance -= $tradeAmount
            $openPositionCount++ # tracks how many positions we have concurrently
            $testTradeLog += "Buy @ $($currentPrice) | Tokens: $([math]::Round($tokensBought,6)) | Balance: $([math]::Round($balance,2)) | ROI: $([math]::Round($roi,3))%"
            #return "BUY"                            
        } else {
            Write-Host "Can not buy. Too many open postions." -ForegroundColor Magenta
        }
    }
    elseif ($currentPrice -gt $result.UpperBand) {
        if($openPositionCount -gt 0){
            Write-Host "SELL" -ForegroundColor Red -BackgroundColor Black
            $tokensBought = ($tradeAmount * (1 - $slippage)) / $currentPrice
            $balance -= $tradeAmount
            $openPositionCount-- # tracks how many positions we have concurrently
            $testTradeLog += "Sell @ $($currentPrice) | Tokens: $([math]::Round($tokensBought,6)) | Balance: $([math]::Round($balance,2)) | ROI: $([math]::Round($roi,3))%"
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


