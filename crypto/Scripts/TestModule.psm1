
function Run-BollingerBandsTests {
    param (                
        [Parameter(Mandatory = $true)][string] $CsvFileName,
        [Parameter(Mandatory = $false)][int[]] $rollingWindows = @(15, 20, 25, 30, 35, 40, 45, 50),
        [Parameter(Mandatory = $false)][float[]] $stdMultipliers = @(1.5, 2.0, 2.5, 3, 3.5, 4),   
        [Parameter(Mandatory = $false)][float] $Slippage = 0.05,
        [Parameter(Mandatory = $false)][string] $LogDirectory = 'C:\crypto\Log\Historic Data',
        [Parameter(Mandatory = $false)][switch] $Silent
    )

    
    $csvFile = "$logDirectory\$csvFileName"

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
            $result = Test-BollingerBands -CsvFileName $csvFileName -RollingWindow $rollingWindow -StdMultiplier $stdMultiplier -Slippage $slippage -Silent $silent

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
        $gridResults | sort -Descending TotalROI
    }
    return $gridResults
}


function Test-BollingerBands {
    param (        
        [Parameter(Mandatory = $false)][string] $LogDirectory = 'C:\crypto\Log\Historic Data',
        [Parameter(Mandatory = $true)][string] $CsvFileName,
        [Parameter(Mandatory = $false)][int] $InitialBalance = 100,
        [Parameter(Mandatory = $false)][int] $TradeAmount = 10,
        [Parameter(Mandatory = $false)][float] $slippage = 0.05,
        [Parameter(Mandatory = $true)][int] $RollingWindow = 20,
        [Parameter(Mandatory = $true)][float] $StdMultiplier = 2,
        [Parameter(Mandatory = $false)][switch] $ShowTradeLog
    )
    
    if($csvFileName -like "C:\*"){
        $csvFile = $csvFileName
    }
    else{
        $csvFile = "$logDirectory\$csvFileName"
    }
    
    # Add headers to columns
    $tempFile = "$csvFile.temp"
    $expectedHeader = "timestamp,price,token name,supply"
    # Read the first line of the CSV
    $firstLine = Get-Content -Path $csvFile -TotalCount 1
    # If the header is incorrect, prepend the correct header
    if ($firstLine -ne $expectedHeader) {
        Write-Host "Fixing CSV: Adding missing header..."
        $newContent = @($expectedHeader) + (Get-Content -Path $csvFile)
        $newContent | Set-Content -Path $tempFile
        Copy-Item -Path $tempFile -Destination $csvFile -Force
        Remove-Item -Path $tempFile 
    } 

    # Fix timestamps in CSV
    $data = Get-Content -Path $csvFile
    $data = $data -replace '(\d{2}-\d{2}),', '$1 '
    $data = $data -replace '(-2025),', '$1 '
    $data = $data -replace '(/2025),', '$1 '
    $data | Set-Content -Path $csvFile

    
    # Load price data
    $data = Import-Csv -Path $csvFile -Delimiter ',' | Select-Object -Property timestamp, price
    #$data = Import-Csv -Path $csvFile -Delimiter ',' | select -First 10

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

    # Display results
    Write-Host "--- $($CsvFileName) - Bollinger Bands: Backtest Results ---" -ForegroundColor Magenta -BackgroundColor Black
    Write-Host "Slippage = $($slippage)" -ForegroundColor Cyan 
    Write-Host "Rolling window = $($rollingWindow)" -ForegroundColor Cyan 
    Write-Host "Standard deviation multiplier = $($stdMultiplier)" -ForegroundColor Cyan 

    Write-Host "Total Trades: $($tradeLog.Count)"
    if($balance -lt 100){
        Write-Host "Final Balance: $([math]::Round($balance,2))" -ForegroundColor Red
    }
    else {
        Write-Host "Final Balance: $([math]::Round($balance,2))" -ForegroundColor Green
    }
    if($totalROI -lt 0){
        Write-Host "Total ROI: $([math]::Round($totalROI,3))%" -ForegroundColor Red
    }
    else {
        Write-Host "Total ROI: $([math]::Round($totalROI,3))%" -ForegroundColor Green
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


function Run-BollingerBandsTests2 {
    param (                
        [Parameter(Mandatory = $true)][string] $CsvFileName,
        [Parameter(Mandatory = $false)][float] $Slippage = 0.05
    )

    $totalROIs = @()
    $totalROIs += Test-BollingerBands -CsvFileName $csvFileName -RollingWindow 15 -StdMultiplier 1.5 -Slippage $slippage
    $totalROIs += Test-BollingerBands -CsvFileName $csvFileName -RollingWindow 15 -StdMultiplier 2 -Slippage $slippage
    $totalROIs += Test-BollingerBands -CsvFileName $csvFileName -RollingWindow 15 -StdMultiplier 2.5 -Slippage $slippage
    $totalROIs += Test-BollingerBands -CsvFileName $csvFileName -RollingWindow 15 -StdMultiplier 3 -Slippage $slippage
    $totalROIs += Test-BollingerBands -CsvFileName $csvFileName -RollingWindow 15 -StdMultiplier 3.5 -Slippage $slippage

    $totalROIs += Test-BollingerBands -CsvFileName $csvFileName -RollingWindow 20 -StdMultiplier 1.5 -Slippage $slippage
    $totalROIs += Test-BollingerBands -CsvFileName $csvFileName -RollingWindow 20 -StdMultiplier 2 -Slippage $slippage
    $totalROIs += Test-BollingerBands -CsvFileName $csvFileName -RollingWindow 20 -StdMultiplier 2.5 -Slippage $slippage
    $totalROIs += Test-BollingerBands -CsvFileName $csvFileName -RollingWindow 20 -StdMultiplier 3 -Slippage $slippage
    $totalROIs += Test-BollingerBands -CsvFileName $csvFileName -RollingWindow 20 -StdMultiplier 3.5 -Slippage $slippage
    $totalROIs += Test-BollingerBands -CsvFileName $csvFileName -RollingWindow 20 -StdMultiplier 4 -Slippage $slippage

    $totalROIs += Test-BollingerBands -CsvFileName $csvFileName -RollingWindow 25 -StdMultiplier 1.5 -Slippage $slippage
    $totalROIs += Test-BollingerBands -CsvFileName $csvFileName -RollingWindow 25 -StdMultiplier 2 -Slippage $slippage
    $totalROIs += Test-BollingerBands -CsvFileName $csvFileName -RollingWindow 25 -StdMultiplier 2.5 -Slippage $slippage
    $totalROIs += Test-BollingerBands -CsvFileName $csvFileName -RollingWindow 25 -StdMultiplier 3 -Slippage $slippage
    $totalROIs += Test-BollingerBands -CsvFileName $csvFileName -RollingWindow 25 -StdMultiplier 3.5 -Slippage $slippage

    $totalROIs += Test-BollingerBands -CsvFileName $csvFileName -RollingWindow 30 -StdMultiplier 1.5 -Slippage $slippage
    $totalROIs += Test-BollingerBands -CsvFileName $csvFileName -RollingWindow 30 -StdMultiplier 2 -Slippage $slippage
    $totalROIs += Test-BollingerBands -CsvFileName $csvFileName -RollingWindow 30 -StdMultiplier 2.5 -Slippage $slippage
    $totalROIs += Test-BollingerBands -CsvFileName $csvFileName -RollingWindow 30 -StdMultiplier 3 -Slippage $slippage
    $totalROIs += Test-BollingerBands -CsvFileName $csvFileName -RollingWindow 30 -StdMultiplier 3.5 -Slippage $slippage

    $totalROIs += Test-BollingerBands -CsvFileName $csvFileName -RollingWindow 35 -StdMultiplier 1.5 -Slippage $slippage
    $totalROIs += Test-BollingerBands -CsvFileName $csvFileName -RollingWindow 35 -StdMultiplier 2 -Slippage $slippage
    $totalROIs += Test-BollingerBands -CsvFileName $csvFileName -RollingWindow 35 -StdMultiplier 2.5 -Slippage $slippage
    $totalROIs += Test-BollingerBands -CsvFileName $csvFileName -RollingWindow 35 -StdMultiplier 3 -Slippage $slippage
    $totalROIs += Test-BollingerBands -CsvFileName $csvFileName -RollingWindow 35 -StdMultiplier 3.5 -Slippage $slippage
    
    $totalROIs += Test-BollingerBands -CsvFileName $csvFileName -RollingWindow 40 -StdMultiplier 1.5 -Slippage $slippage
    $totalROIs += Test-BollingerBands -CsvFileName $csvFileName -RollingWindow 40 -StdMultiplier 2 -Slippage $slippage
    $totalROIs += Test-BollingerBands -CsvFileName $csvFileName -RollingWindow 40 -StdMultiplier 2.5 -Slippage $slippage
    $totalROIs += Test-BollingerBands -CsvFileName $csvFileName -RollingWindow 40 -StdMultiplier 3 -Slippage $slippage
    $totalROIs += Test-BollingerBands -CsvFileName $csvFileName -RollingWindow 40 -StdMultiplier 3.5 -Slippage $slippage
    
    $totalROIs += Test-BollingerBands -CsvFileName $csvFileName -RollingWindow 45 -StdMultiplier 1.5 -Slippage $slippage
    $totalROIs += Test-BollingerBands -CsvFileName $csvFileName -RollingWindow 45 -StdMultiplier 2 -Slippage $slippage
    $totalROIs += Test-BollingerBands -CsvFileName $csvFileName -RollingWindow 45 -StdMultiplier 2.5 -Slippage $slippage
    $totalROIs += Test-BollingerBands -CsvFileName $csvFileName -RollingWindow 45 -StdMultiplier 3 -Slippage $slippage
    $totalROIs += Test-BollingerBands -CsvFileName $csvFileName -RollingWindow 45 -StdMultiplier 3.5 -Slippage $slippage

    $totalROIs += Test-BollingerBands -CsvFileName $csvFileName -RollingWindow 50 -StdMultiplier 1.5 -Slippage $slippage
    $totalROIs += Test-BollingerBands -CsvFileName $csvFileName -RollingWindow 50 -StdMultiplier 2 -Slippage $slippage
    $totalROIs += Test-BollingerBands -CsvFileName $csvFileName -RollingWindow 50 -StdMultiplier 2.5 -Slippage $slippage
    $totalROIs += Test-BollingerBands -CsvFileName $csvFileName -RollingWindow 50 -StdMultiplier 3 -Slippage $slippage
    $totalROIs += Test-BollingerBands -CsvFileName $csvFileName -RollingWindow 50 -StdMultiplier 3.5 -Slippage $slippage
    $totalROIs | sort -Descending TotalROI | select -First 10
    
    $totalROIs = $totalROIs | sort -Descending TotalROI
    return $totalROIs 
}

