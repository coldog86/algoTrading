function Test-TelegramConnectivity(){
    $token = '7879974293:AAF9k4ofDNb2Bx4DBPQzfXPRxExna545pvs'
    $uri = "https://api.telegram.org/bot$($token)/getMe"
    Invoke-RestMethod -Uri $uri -Method GET
}


function Get-TelegramUpdates(){
    $token = '7879974293:AAF9k4ofDNb2Bx4DBPQzfXPRxExna545pvs'
    $uri = "https://api.telegram.org/bot$($token)/getUpdates"
    $response = Invoke-RestMethod -Uri $uri -Method GET
    return $response.result
}


function Get-TelegramChat(){
    Param
        (
            [Parameter(Mandatory = $true)][string] $ChatId
        )
    $token = '7879974293:AAF9k4ofDNb2Bx4DBPQzfXPRxExna545pvs'
    $uri = "https://api.telegram.org/bot$($token)/getUpdates"
    $payload = @{
        chat_id = $chatId
    }
    $response = Invoke-RestMethod -Uri $uri -Method POST -ContentType "application/json" -Body ($payload | ConvertTo-Json -Depth 10)
    return $response.result
}

function Assess-NewToken(){   
    Param
        (
            [Parameter(Mandatory = $true)] $NewToken 
        ) 
    $tokenHash = ($NewToken -split "`n")[2]
    Write-Host "$($tokenHash)" -ForegroundColor Magenta
    break
}

function Monitor-Alerts(){
    Param
        (
            [Parameter(Mandatory = $false)][string] $ChatId = "@testgroupjbn121"
        )
    $initialCount = (Get-TelegramChat -ChatId $chatId).count
    while($true){
        Write-Host "." -NoNewline
        Start-Sleep -Seconds 5
        $chat = Get-TelegramChat -ChatId $chatId
        $currentCount = $chat.count
        if($currentCount -gt $initialCount){
            Write-Host ""
            Write-Host "*** NEW TOKEN ***" -ForegroundColor Green
            $newToken = $chat[$chat.count -1].message.text
            Assess-NewToken -Token $newToken
        }
    }
}

function Send-Message(){
    Param
        (
            [Parameter(Mandatory = $true)][string] $ChatId, 
            [Parameter(Mandatory = $true)][string] $Message
        )
    $token = '7879974293:AAF9k4ofDNb2Bx4DBPQzfXPRxExna545pvs'
    $uri = "https://api.telegram.org/bot$($token)/sendMessage"
    # Prepare the payload
    $payload = @{
        chat_id = $chatId
        text    = $message
    }
    $response = Invoke-RestMethod -Uri $uri -Method POST -ContentType "application/json" -Body ($payload | ConvertTo-Json -Depth 10)
}

# Send-Message -ChatId "@testgroupjbn121" -Message "testComplete"


