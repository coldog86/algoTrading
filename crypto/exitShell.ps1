write-host "exiting"
Write-Host "The PID of this shell is $PID"
Stop-Process -Id $PID -Force