
########################################
####### Bollering Bands Strategy #######
########################################

function Run-BolleringBandStrategy {
    param (
        [Parameter(Mandatory = $true)][string] $TokenName,
        [Parameter(Mandatory = $false)][string] $LogFolder = ".\log"
    )
    $i = 5 # starting at 5 so we initially kick off the whole loop
    $tokenCode = Get-TokenCode
    $tokenIssuer = Get-TokenIssuer
    Write-Host "Starting live trading with Bollering Band strategy..." -ForegroundColor Green
    while ($true) {
        $currentPrice = Get-TokenPrice -TokenCode $tokenCode -TokenIssuer $tokenIssuer -Silent $true
        Log-Price -TokenName $tokenName -TokenPrice $currentPrice # log all the price data for a token 
        
        if($i -eq 5){
            $i++
            # init stuff for strategy
        }
        # Every minute do this...
        if($i % 6 -eq 0){
            Write-Host "Getting 10mins of data" -ForegroundColor Yellow -BackgroundColor Black
            # get the live CSV data for the token
            $csvData = Import-Csv -Path "$logFolder\$tokenName.csv"
            if ($csvData.Count -eq 0) {
                Write-Host "No data available. Waiting for updates..." -ForegroundColor Yellow
                Start-Sleep -Seconds 5
                continue
            }

            # Convert timestamp to DateTime
            $csvData = $csvData | ForEach-Object { $_ | Add-Member -PassThru -MemberType NoteProperty -Name DateTime -Value ([datetime]$_.Timestamp) }

            # Filter last 10 minutes of data
            $currentTime = Get-Date
            $lastNminutesOfData = $csvData | Where-Object { $_.DateTime -ge $currentTime.AddMinutes(-10) }
            $earliestRecord = ($lastNminutesOfData | Sort-Object DateTime | Select-Object -First 1).DateTime
            Write-Host "Earlist record = $($earliestRecord)"
            
            # Check if the earliest record is actually 10 minutes old
            while ($earliestRecord -lt $currentTime.AddMinutes(-10)) {
                # Don't have 10mins of data yet, wait 30 seconds and retry. Easy loop, the earliest record never changes
                $n++
                Write-Host "Not enough data (waiting for 10 minutes of coverage). Waiting...($($n)%)" -ForegroundColor Yellow
                Start-Sleep -Seconds 6  
                Log-Price -TokenName $tokenName -TokenPrice $currentPrice # log while we're waiting                                              
            }

            ## TODO 
            # add loop to check newestRecord is > $currentTime.AddMinutes(-1)
            
            $latestRecord = ($lastNminutesOfData | Sort-Object DateTime | Select-Object -Last 1).DateTime

            if($i -le 6){ # Only write this on the first iteration
                Write-Host "At least 10 minutes of data available. Proceeding..." -ForegroundColor Green
            }
            # Get the data again to ensure we have latest full 10mins
            $csvData = Import-Csv -Path "$logFolder\$tokenName.csv"
            $csvData = $csvData | ForEach-Object { $_ | Add-Member -PassThru -MemberType NoteProperty -Name DateTime -Value ([datetime]$_.Timestamp) } # Convert timestamp to DateTime
            $lastNminutesOfData = $csvData | Where-Object { $_.DateTime -ge $currentTime.AddMinutes(-10) }

            # shit to name the temp file
            $firstTimestamp = $earliestRecord.ToString("yyyyMMdd_HHmmss")
            $lastTimestamp = $latestRecord.ToString("yyyyMMdd_HHmmss")
            $csvFileName = "$tokenName-$firstTimestamp-$lastTimestamp.csv"
            $tempCsvFilePath = "$logFolder\temp\$csvFileName"
            Write-Host "csv file path = $($tempCsvFilePath)"
            $lastNminutesOfData | Export-Csv -Path $tempCsvFilePath -NoTypeInformation
                    
            # Calculate best Bollinger Bands paramaters
            $gridResults = Run-BollingerBandsGridSearch -CsvFile $tempCsvFilePath -RollingWindows @(15, 20, 25, 30, 35, 40, 45, 50) -StdMultipliers @(1.5, 2.0, 2.5, 3, 3.5, 4) -Slippage 0.05 -Silent $true
            $gridResults = $gridResults | Sort-Object -Descending TotalROI
            $bollingerBandParameters = $gridResults[0]
            Write-Host $bollingerBandParameters -ForegroundColor Magenta -BackgroundColor Black -NoNewline
        }

        # Extract price data
        $csvData = Import-Csv -Path $tempCsvFilePath
        $priceData = $csvData.Price | ForEach-Object { [double]$_ }

        # Run the actual strategy on our temp data with the parameters we calculated from the grid search
        $result = Calculate-BollingerBandsParameters -PriceData $priceData -RollingWindow $bollingerBandParameters.RollingWindow -StdMultiplier $bollingerBandParameters.StdMultiplier
        Write-Host " | Low: $($result.LowerBand) | High: $($result.UpperBand)" -ForegroundColor Magenta -BackgroundColor Black 
        
        $currentPrice = Get-TokenPrice -TokenCode $tokenCode -TokenIssuer $tokenIssuer -Silent $true
        Write-Host "$(Get-Date -Format 'HH:mm:ss') | $($tokenName) | Price: $currentPrice | Decision: $decision" -ForegroundColor Cyan -NoNewline
        if ($currentPrice -lt $result.LowerBand) {
            Write-Host "BUY BUY BUY"
            if(!($null -eq $global:buyTime)){
                if( Has-nMinutesPassed -InitialTime $global:buyTime -MinutesPassed 1 ){
                    Write-Host "**** BUY ****" -ForegroundColor Green -BackgroundColor Black
                    #return "BUY"                
                }
                else {
                    Write-Host "BUY conditions met. Too soon to last buy" -ForegroundColor Yellow
                }
            }
        }
        elseif ($currentPrice -gt $result.UpperBand) {
            Write-Host "SELL" -ForegroundColor Red -BackgroundColor Black
            #return "SELL"
        }
        else {
            Write-Host "HOLD" -ForegroundColor Yellow -BackgroundColor Black
            #return "HOLD"
        }

        # Wait for 10 seconds before next check
        $i++
        Start-Sleep -Seconds 10
    }
}


function Calculate-BollingerBandsParameters {
    param (
        [Parameter(Mandatory = $true)][array] $PriceData,
        [Parameter(Mandatory = $true)][int] $RollingWindow,
        [Parameter(Mandatory = $true)][float] $StdMultiplier
    )

    $lastPrices = $PriceData[-$RollingWindow..($count - 1)]
    $average = ($lastPrices | Measure-Object -Average).Average
    $stdDev = [math]::Sqrt(($lastPrices | ForEach-Object { ($_ - $average) * ($_ - $average) } | Measure-Object -Sum).Sum / $RollingWindow)

    $upperBand = $average + ($StdMultiplier * $stdDev)
    $lowerBand = $average - ($StdMultiplier * $stdDev)

    return @{
        UpperBand = $upperBand
        LowerBand = $lowerBand
        MovingAverage = $average
    }
}


function Fix-CSV {
    param (                
        [Parameter(Mandatory = $true)][string] $CsvFile,
        [Parameter(Mandatory = $false)][bool] $Silent = $false
    )
        
    $data = Get-Content -Path $csvFile

    # Get rid of bad line
    $data = $data | Where-Object { $_ -ne '#TYPE System.Management.Automation.PSCustomObject' }

    
    # Add headers to columns
    $tempFile = "$csvFile.temp"
    $expectedHeader = "timestamp,price,token name"
    $expectedHeader2 = '"timestamp","price","token name"'
    # Read the first line of the CSV
    $firstLine = Get-Content -Path $csvFile -TotalCount 1
    # If the header is incorrect, prepend the correct header
    if ($firstLine -ne $expectedHeader ){
        if( $firstLine -ne $expectedHeader2 ) {        
            if(!$silent){
                Write-Host "Fixing CSV: Adding missing header..."
            }
            $newContent = @($expectedHeader) + (Get-Content -Path $csvFile)
            $newContent | Set-Content -Path $tempFile
            Copy-Item -Path $tempFile -Destination $csvFile -Force
            Remove-Item -Path $tempFile 
        }
    } 

    
    # Fix timestamps in CSV
    $data = $data -replace '/', '-'
    $data = $data -replace '"', ''
    $data = $data -replace '(\d{2}-\d{2}),', '$1 '
    $data = $data -replace '(-2025),', '$1 '
    $data | Set-Content -Path $csvFile

    return $data

}
function Test-BollingerBands {
    param (        
        [Parameter(Mandatory = $true)][string] $CsvFile,
        [Parameter(Mandatory = $false)][int] $InitialBalance = 100,
        [Parameter(Mandatory = $false)][int] $TradeAmount = 10,
        [Parameter(Mandatory = $false)][float] $slippage = 0.05,
        [Parameter(Mandatory = $true)][int] $RollingWindow = 20,
        [Parameter(Mandatory = $true)][float] $StdMultiplier = 2,
        [Parameter(Mandatory = $false)][switch] $ShowTradeLog,
        [Parameter(Mandatory = $false)][bool] $Silent = $false
    )

    
    $a = $CsvFile.Split('\')
    $csvFileName = $a[$a.count-1]    
    $csvFileName = $csvFileName.Split('.')[0]

    Fix-CSV -CsvFile $csvFile -Silent $true
    
    # Load price data
    $data = Import-Csv -Path $csvFile -Delimiter ',' | Select-Object -Property timestamp, price
    
    # Convert Price column to float
    $data | ForEach-Object { $_.Price = [double]$_.Price }

    # Compute Moving Average and Standard Deviation for Bollinger Bands
    $data = @($data)  # Ensure $data is treated as an array
    for ($i = $rollingWindow; $i -lt $data.Length; $i++) {
        $subset = $data[($i - $rollingWindow)..$i]
        $mean = ($subset.Price | Measure-Object -Average).Average
        $stdDev = [math]::Sqrt(($subset.Price | ForEach-Object { ($_ - $mean) * ($_ - $mean) } | Measure-Object -Sum).Sum / $rollingWindow)
        $data[$i] | Add-Member -MemberType NoteProperty -Name MovingAvg -Value $mean
        $data[$i] | Add-Member -MemberType NoteProperty -Name UpperBand -Value ($mean + ($stdMultiplier * $stdDev))
        $data[$i] | Add-Member -MemberType NoteProperty -Name LowerBand -Value ($mean - ($stdMultiplier * $stdDev))
    }

    # Initialize variables for backtest
    $balance = $initialBalance
    $position = 0
    $tradeLog = @()
    $roiList = @()

    # Backtest strategy
    for ($i = $rollingWindow; $i -lt $data.Count; $i++) {
        $currentPrice = $data[$i].Price
        $lowerBand = $data[$i].LowerBand
        $upperBand = $data[$i].UpperBand

        # Buy condition: Price crosses above the lower Bollinger Band and we do not already hold a position
        if ($currentPrice -lt $lowerBand -and $position -eq 0) {
            $tokensBought = ($tradeAmount * (1 - $slippage)) / $currentPrice
            $position = $tokensBought
            $balance -= $tradeAmount
            $tradeLog += "Buy @ $($currentPrice) | Tokens: $([math]::Round($tokensBought,6)) | Balance: $([math]::Round($balance,2))"
        }

        # Sell condition: Price crosses below the upper Bollinger Band
        elseif ($currentPrice -gt $upperBand -and $position -gt 0) {
            $sellValue = $position * $currentPrice * (1 - $slippage)
            $profit = $sellValue - $tradeAmount
            $roi = ($profit / $tradeAmount) * 100
            $roiList += $roi
            $balance += $sellValue
            $tradeLog += "Sell @ $($currentPrice) | Tokens: $([math]::Round($position,6)) | Balance: $([math]::Round($balance,2)) | ROI: $([math]::Round($roi,3))%"
            $position = 0
        }
    }

    # Calculate total ROI
    $totalROI = (($balance - $initialBalance) / $initialBalance) * 100
    $sumROI = ($roiList | Measure-Object -Sum).Sum

    # Display trade log
    if($showTradeLog){
        Write-Host "`n--- Trade Log ---" -ForegroundColor Cyan -BackgroundColor Black
        $tradeLog | ForEach-Object { Write-Host $_ }
    }

    # Display resultsif($totalROI -lt 0){
    if($totalROI -lt 0){
        $color = 'Red'
    }
    if($totalROI -gt 0){
        $color = 'Green'
    }
    if($tradeLog.Count -eq 0){
        $color = 'Yellow'
    }
    if(!$silent){
        Write-Host "--- $($CsvFileName) --- Window=$($rollingWindow)/SDmultiplier=$($stdMultiplier)   ---" -ForegroundColor $color -BackgroundColor Black
        if(!($silent)){
            Write-Host "Slippage = $($slippage)" -ForegroundColor Cyan 
            Write-Host "Rolling window = $($rollingWindow)" -ForegroundColor Cyan 
            Write-Host "Standard deviation multiplier = $($stdMultiplier)" -ForegroundColor Cyan 
           
            Write-Host "Total Trades: $($tradeLog.Count)" -ForegroundColor $color
            Write-Host "Total ROI: $([math]::Round($totalROI,3))%" -ForegroundColor $color
        }
    }
    # Create and return the totalROI object
    $totalROIobj = [PSCustomObject]@{
        RollingWindow = $RollingWindow
        StdMultiplier = $StdMultiplier
        TotalROI = [math]::Round($totalROI, 3)
        NumberOfTrades = $($tradeLog.Count)
    }

    return $totalROIobj

}

function Run-BollingerBandsGridSearch {
    param (                
        [Parameter(Mandatory = $true)][string] $CsvFile,
        [Parameter(Mandatory = $false)][int[]] $rollingWindows = @(15, 20, 25, 30, 35, 40, 45, 50),
        [Parameter(Mandatory = $false)][float[]] $stdMultipliers = @(1.5, 2.0, 2.5, 3, 3.5, 4),   
        [Parameter(Mandatory = $false)][float] $Slippage = 0.05,
        [Parameter(Mandatory = $false)][bool] $Silent = $false
    )

    
    # Initialize results array
    $gridResults = @()

    # Perform grid search
    foreach ($rollingWindow in $rollingWindows) {
        foreach ($stdMultiplier in $stdMultipliers) {
            # Run the Bollinger Bands test for each parameter combination
            if(!$silent){
                Write-Host "Testing rolling window = $($rollingWindow)"
                Write-Host "Testing stdMultiplier = $($stdMultiplier)"
            }
            $result = Test-BollingerBands -CsvFile $csvFile -RollingWindow $rollingWindow -StdMultiplier $stdMultiplier -Slippage $slippage -Silent $silent

            # Store results in an object
            $gridResults += [PSCustomObject]@{
                RollingWindow = $result.RollingWindow
                StdMultiplier = $result.StdMultiplier
                TotalROI      = $result.TotalROI
                NumberOfTrades = $result.NumberOfTrades
            }
        }
    }

    if(!$silent){
        $gridResults | Sort-Object -Descending TotalROI
    }
    return $gridResults
}


##################################
####### Stop Loss Strategy #######
##################################


function Test-StopLossBuyConditions {
    param (        
        [Parameter(Mandatory = $true)][double] $InitialPrice,           
        [Parameter(Mandatory = $true)] $TokenCode,        
        [Parameter(Mandatory = $true)][string] $TokenIssuer,
        [Parameter(Mandatory = $false)][int] $StartIncriment = 0,
        [Parameter(Mandatory = $false)][string] $BuyConditionsFilePath = '.\config\buyConditions.csv',
        [Parameter(Mandatory = $false)][bool] $CollectDataOnly
    )

    
    $buyConditions = Import-Csv -Path $buyConditionsFilePath
    $buyConditions
    $number = $buyConditions.count-1
    $seconds = $buyConditions.Seconds[$number]

    Write-Host "Monitoring for $($seconds) seconds"
    $progressActivity = "Monitoring for $seconds seconds"
    $progressStatus = "Time remaining"
    # Array to track the percentage increases
    $percentageHistory = @()

    for ($i = $startIncriment; $i -lt $seconds; $i++) {   
        $percentComplete = [int](($i / $seconds) * 100)
        $timeRemaining = $seconds - $i
        [double]$newPrice = Get-TokenPrice -TokenCode $tokenCode -TokenIssuer $tokenIssuer
        [double]$percentageIncrease = "{0:F2}" -f ((($newPrice - $initialPrice) / $initialPrice) * 100)
        Log-Price -TokenName $tokenName -TokenPrice $newPrice # log all the price data for a token 

        # Track the percentage increase for last 2 iterations
        $percentageHistory += $percentageIncrease
        if ($percentageHistory.Count -gt 2) {
            $percentageHistory = $percentageHistory[-2..-1]
        }

        # Add this check to only buy if price has not jumped +50% in the last 2 iterations
        if ($percentageHistory.Count -eq 2) {
            $lastIncreaseDiff = [math]::Abs($percentageHistory[-1] - $percentageHistory[-2])
            if ($lastIncreaseDiff -gt 50) {
                Write-Host "Skipping buy action: Price change is too volatile ($lastIncreaseDiff% change)" -ForegroundColor Yellow
                continue
            }
        }

        # Every 10 iterations show total percentage change
        if($i % 10 -eq 0){
            Write-Host "The percentage increase is $($percentageIncrease)%" -ForegroundColor Magenta
            Write-Host "percentageIncreaseRequired = $($percentageIncreaseRequired)" -ForegroundColor Magenta

            # Validate that the price hasn't dropped to < 15%
            if($percentageIncrease -lt -85){
                Write-Host "Price has flatlined" -ForegroundColor Red
            }
        }

        # Work out the required percentage increase as per buy conditions CSV
        $percentageIncreaseRequired = 250
        foreach ($buyCondition in $buyConditions){
            if($i -lt $buyCondition.Seconds){
                $percentageIncreaseRequired = $buyCondition.BuyCondition
                break
            }
        }

        # Buy logic
        if($percentageIncrease -gt $percentageIncreaseRequired){
            Write-Host "Price increase" -ForegroundColor Green
            Write-Host "Current  Price = $($newPrice)"
            Write-Host "The percentage increase is $($percentageIncrease)%" -ForegroundColor Magenta
            Write-Host "Buy token" -ForegroundColor Green
            $action = "buy"
            Log-Token -Action BuyToken -TokenName -$tokenName -PercentageIncrease $percentageIncrease
            # Stop and remove the progress bar
            Write-Progress -Activity "Processing" -Completed
            return $action
        }
        
        [double]$newPrice = Get-TokenPrice -TokenCode $tokenCode -TokenIssuer $tokenIssuer

        if($newPrice -gt $initialPrice){
            Write-Host "Price increase" -ForegroundColor Green
            Write-Host "Initial Price = $($initialPrice)"
            Write-Host "Current  Price = $($newPrice)"
            [double]$percentageIncrease = "{0:F2}" -f ((($newPrice - $initialPrice) / $initialPrice) * 100) # only show to 2 decimal places
            
            Write-Host "Token gained, but not enough: hold" -ForegroundColor Red
            $action = "hold"
            return $action
        
        } else {
            if($percentageIncrease -gt -35){
                Write-Host "Price decreased $($percentageIncrease)" -ForegroundColor Red
                Log-Token -Action Distroy -TokenName -$tokenName
                $action = "abandone"
                return $action
            } 
            else{            
                Write-Host "Token lost, but not much: hold" -ForegroundColor Red
                $action = "hold"
                return $action
            }
        }

        Write-Progress -Activity $progressActivity -Status "$progressStatus : $timeRemaining seconds" -PercentComplete $percentComplete
        Start-Sleep -Seconds 1
    }

    # Complete the progress bar
    Write-Progress -Activity $progressActivity -Status "Completed" -PercentComplete 100
}



function Run-StopLossStrategy {
    Param (
        [Parameter(Mandatory = $true)][string] $TokenCode,
        [Parameter(Mandatory = $true)][string] $TokenIssuer,
        [Parameter(Mandatory = $false)] $StopNumber = 1,
        [Parameter(Mandatory = $true)][double] $BuyPrice,
        [Parameter(Mandatory = $true)][datetime] $BuyTime,
        [Parameter(Mandatory = $false)][string] $StopsFilePath = '.\config\stops.csv',
        [Parameter(Mandatory = $false)][bool] $Silent = $false, 
        [Parameter(Mandatory = $false)][bool] $CollectDataOnly
    )

    [double]$newPrice = Get-TokenPrice -TokenCode $tokenCode -TokenIssuer $tokenIssuer
    $tokenName = Get-TokenName
    Log-Price -TokenName $tokenName -TokenPrice $newPrice # log all the price data for a token 
    
    $stopLevels = Import-Csv -Path $stopsFilePath
    $stopLevels
    
    # if you clear all the stops, sell all
    if ($stopNumber -gt (($stopLevels.count)-1)) {
        Write-Host "All stops completed, selling remaining tokens."
        Send-TelegramMessage -ChatId "@ForwardingAlert" -Message "All stops completed for $($tokenName), selling all." -Silent $silent
        if(!$collectDataOnly){
            Sell-Token -TokenIssuer $tokenIssuer -TokenCode $tokenCode -AmountOfTokenToSell 100 -Slipage 0.1 -Message "- No further stops programmed"
        }
        else{
            Write-Host "Sell-Token - All stops completed (if not data collection only)" -ForegroundColor Red -BackgroundColor Black
        }
    }
    else{
        [double]$stopLowerLimit = $buyPrice * ($stopLevels.stopLowerLimit[$stopNumber-1] /100)
        [double]$stopUpperLimit = $buyPrice * ($stopLevels.stopUpperLimit[$stopNumber-1] /100)

        Write-Host "Stop $($stopNumber) upper limit = $($stopUpperLimit)" -ForegroundColor DarkYellow -BackgroundColor Black
        Write-Host "Stop $($stopNumber) lower limit = $($stopLowerLimit)" -ForegroundColor DarkYellow -BackgroundColor Black
        
        #Loop while you're in the stop
        while ($newPrice -gt $stopLowerLimit -and $newPrice -lt $stopUpperLimit) {
            $i++
            Start-Sleep -Seconds 5
            Write-Host "*** At stop $($stopNumber) ***"
            [double]$newPrice = Get-TokenPrice -TokenCode $tokenCode -TokenIssuer $tokenIssuer 
            Log-Price -TokenName $tokenName -TokenPrice $newPrice # log all the price data for a token 
    
            # Every 10 iterations show total percentage change
            if($i % 10 -eq 0){
                [double]$percentageIncrease = "{0:F2}" -f ((($newPrice - $buyPrice) / $buyPrice) * 100)
                Write-Host "$($tokenName) has changed $($percentageIncrease)%" -ForegroundColor Magenta
                Start-Sleep -Seconds 1 # Small delay to avoid multiple writes in the same second
                Write-Host "Stop $($stopNumber) upper limit = $($stopUpperLimit)" -ForegroundColor DarkYellow -BackgroundColor Black
                Write-Host "Stop $($stopNumber) lower limit = $($stopLowerLimit)" -ForegroundColor DarkYellow -BackgroundColor Black
            }       
        }       
        
        # you've moved through the stop
        if($newPrice -gt $stopUpperLimit){
            Write-Host "Reached upperlimit for $stopNumber (target: $stopUpperLimit)" -ForegroundColor Green
            Send-TelegramMessage -ChatId "@ForwardingAlert" -Message "$($tokenName) Reached stop upperlimit for $($stopNumber)" -Silent $silent    
            $stopNumber++
            Run-StopLossStrategy -TokenIssuer $tokenIssuer -TokenCode $tokenCode -BuyPrice $buyPrice -BuyTime $buyTime -StopNumber $stopNumber -Silent $silent -CollectDataOnly $collectDataOnly 
        }

        # Sell if it drops below the stop     
        if($newPrice -lt $stopLowerLimit){        
            Write-Host "$($tokenName) fell below stop $($stopNumber) lower stop" -ForegroundColor Red
            Send-TelegramMessage -ChatId "@ForwardingAlert" -Message "$($tokenName) fell below stop $($stopNumber) lower stop" -Silent $silent     
            if(!$collectDataOnly){
                Sell-Token -TokenIssuer $tokenIssuer -TokenCode $tokenCode -AmountOfTokenToSell 100 -Slipage 0.5 -Message "- $($tokenName) fell below stop $($stopNumber) lower stop"
                exit
            }
            else{
                Write-Host "Sell-Token (if not data collection only)" -ForegroundColor Red -BackgroundColor Black
            }
        }    
    }
}