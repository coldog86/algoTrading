Import-Module 'E:\cmcke\Documents\Crypto\CryptoModule.psm1' -Force -WarningAction Ignore
$walletAddress = Read-Host "Please enter wallet address (it will look something like this 'rDXgW8ZdcPwmSzEzK7s45V6xeSwuwgiVYG')"
Set-WalletSecret -SecretNumbers $secretNumbers
$secretNumbers = Read-Host "Please enter wallet secret numbers (it must look something like this '261821 261821 261821 261821 261821 261821 261821 261821')"
Set-WalletSecret -SecretNumbers $secretNumbers
$userTelegramGroup = Read-Host "Please enter the name of the Telegram group you added the bot to" 
Set-UserTelegramGroup -UserTelegramGroup $userTelegramGroup
$adminTelegramGroup = Read-Host "Use default for admin telegram group? (y/n)"
if($adminTelegramGroup -eq 'n'){
    $adminTelegramGroup = Read-Host "Please enter the name of the admin Telegram group"
    Set-UserTelegramGroup -UserTelegramGroup $userTelegramGroup
}    
Create-PythonScripts
Create-GoBabyGoScript