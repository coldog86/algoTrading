
function Run-BolleringBandStrategy {
    param (
        [Parameter(Mandatory = $true)][string] $TokenName,
        [Parameter(Mandatory = $false)][string] $LogFolder = ".\log"
    )

    Write-Host "Starting live trading with Bollering Band strategy..." -ForegroundColor Green
    while ($true) {
        # get the CSV data for the 
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

        # Check if we have enough data
        if ($filteredData.Count -gt 0) {
            # Find the oldest timestamp in the last 10 minutes
            $earliestRecord = ($filteredData | Sort-Object DateTime | Select-Object -First 1).DateTime

            # Check if the earliest record is actually 10 minutes old
            if ($earliestRecord -le $currentTime.AddMinutes(-10)) {
                Write-Host "At least 10 minutes of data available. Proceeding..." -ForegroundColor Green
                
                $tokenName = $filteredData[0].TokenName
                $tokenName = $tokenName -replace '[^a-zA-Z0-9_-]', ''  # Remove invalid filename characters
                $firstTimestamp = $earliestRecord.ToString("yyyyMMdd_HHmmss")
                $lastTimestamp = $latestRecord.ToString("yyyyMMdd_HHmmss")
                $csvFileName = "$tokenName-$firstTimestamp-$lastTimestamp.csv"
                $csvFilePath = "logFolder\temp\$csvFileName"
                
                $filteredData | Export-Csv -Path $csvFilePath -NoTypeInformation

                Write-Host "New data saved to: $tempFile" -ForegroundColor Cyan
                break  
            }
        }

        # Not enough data yet, wait and retry
        Write-Host "Not enough data (waiting for 10 minutes of coverage). Waiting..." -ForegroundColor Yellow
        Start-Sleep -Seconds 30  

        # Calculate best Bollinger Bands paramaters
        Run-BollingerBandsGridSearch -CsvFile ?? -RollingWindows @(15, 20, 25, 30, 35, 40, 45, 50) -StdMultipliers @(1.5, 2.0, 2.5, 3, 3.5, 4) -Slippage = 0.05

        $bands = Calculate-BollingerBands -PriceData $priceData -RollingWindow $RollingWindow -StdMultiplier $StdMultiplier

        # Get current price
        $currentPrice = [float]$filteredData[-1].Price

        # Evaluate trade decision
        $decision = Evaluate-Trade -CurrentPrice $currentPrice -Bands $bands

        # Log trade decision
        Write-Host "$(Get-Date -Format 'HH:mm:ss') | Price: $currentPrice | Decision: $decision" -ForegroundColor Cyan

        # Wait for 1 minute before next check
        Start-Sleep -Seconds 60
    }
}