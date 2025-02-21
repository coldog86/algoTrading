
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
        $currentPrice = Get-TokenPrice -TokenCode $tokenCode -TokenIssuer $tokenIssuer
        Write-Host "currentPrice = $($currentPrice)"
        Write-Host "currentPrice = $($TokenName)"
        Log-Price -TokenName $tokenName -TokenPrice $currentPrice # log all the price data for a token 
        break
        if($i -eq 5){

            $i++
        }
        # Every minute do this...
        if($i % 6 -eq 0){
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
            $filteredData = $csvData | Where-Object { $_.DateTime -ge $currentTime.AddMinutes(-10) }

            # Check if we have 10 minutes of data
            $earliestRecord = ($filteredData | Sort-Object DateTime | Select-Object -First 1).DateTime

            # Check if the earliest record is actually 10 minutes old
            while ($earliestRecord -gt $currentTime.AddMinutes(-2)) {
                # Not enough data yet, wait and retry
                Write-Host "Not enough data (waiting for 10 minutes of coverage). Waiting..." -ForegroundColor Yellow
                Start-Sleep -Seconds 30  
            }
            
            Write-Host "At least 10 minutes of data available. Proceeding..." -ForegroundColor Green
            
            $tokenName = $tokenName -replace '[^a-zA-Z0-9_-]', ''  # Remove invalid filename characters
            $firstTimestamp = $earliestRecord.ToString("yyyyMMdd_HHmmss")
            $lastTimestamp = $latestRecord.ToString("yyyyMMdd_HHmmss")
            $csvFileName = "$tokenName-$firstTimestamp-$lastTimestamp.csv"
            $csvFilePath = "logFolder\temp\$csvFileName"
            
            $filteredData | Export-Csv -Path $csvFilePath -NoTypeInformation

            Write-Host "New data saved to: $csvFilePath" -ForegroundColor Cyan
        
            # Calculate best Bollinger Bands paramaters
            $gridResults = Run-BollingerBandsGridSearch -CsvFile $csvFilePath -RollingWindows @(15, 20, 25, 30, 35, 40, 45, 50) -StdMultipliers @(1.5, 2.0, 2.5, 3, 3.5, 4) -Slippage 0.05
            $gridResults = $gridResults | Sort-Object -Descending TotalROI
            $bollingerBandParameters = $gridResults[0]
        }

        # Extract price data
        $csvData = Import-Csv -Path $csvFilePath
        $priceData = $csvData.Price | ForEach-Object { [double]$_ }
        $currentPrice = Get-TokenPrice -TokenCode $tokenCode -TokenIssuer $tokenIssuer
        $result = Calculate-BollingerBands -PriceData $priceData -RollingWindow $bollingerBandParameters.RollingWindow -StdMultiplier $bollingerBandParameters.StdMultiplier
        
        if ($currentPrice -lt $result.LowerBand) {
            Write-Host "**** BUY ****" -ForegroundColor Green -BackgroundColor Black
            #return "BUY"
        }
        elseif ($currentPrice -gt $result.UpperBand) {
            Write-Host "**** SELL ****" -ForegroundColor Green -BackgroundColor Black
            #return "SELL"
        }
        else {
            Write-Host "**** HOLD ****"
            #return "HOLD"
        }

        # Log trade decision
        Write-Host "$(Get-Date -Format 'HH:mm:ss') | Price: $currentPrice | Decision: $decision" -ForegroundColor Cyan

        # Wait for 10 seconds before next check
        $i++
        Start-Sleep -Seconds 10
    }
}

function Calculate-BollingerBands {
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