
[ MISSION STATEMENT ]
The goal is to create a working bot that consistently makes money. 
To achieve this we want to use a diverse group of testers each developing their own optimal version of checks and balances.


[ BEFORE YOU BEGIN ]
1. You will need an Xaman wallet. 
	Technically it doesn't have to be Xaman, but it must have a secret in this format '261821 261821 261821 261821 261821 261821 261821 261821' as opposed to the mnemonic words or the shorter S**** secret number.

2a. Set up a Telegram public chat. 
	The bot will be added to this chat, it is how you'll receive alerts. 

2b. Add the bot ragstoriches2 to the chat

[ SETUP ]
1. Go to here: https://raw.githubusercontent.com/coldog86/algoTrading/refs/heads/main/crypto/initiate.ps1
2. Copy all the code
3. Open PowerShell (start > PowerShell) 
4. Paste code, hit enter


[ RUNNING ]
1. Open PowerShell and change to the bot's directory (cd c:\crypto)
2. Run GoBabyGo to start the bot (./GoBabyGo.ps1)

	[Paramaters]
	Paramaters are passed at runtime like this GoBabyGo.ps1 -UseDefaultConfig -Branch main
	There are no manditory paramaters. Below outlines what each does and their default values. 
	-UseDefaultConfig
		Purpose: Use the config files that are stored .\config\default 
		Default value: False
		Accepted values: This is a switch, it doesn't take values. Just add it to the end of the call (GoBabyGo.ps1 -UseDefaultConfig).
		Note: These configurations will change randomly as updates are released. 
	-Branch 
		Purpose: This specifies which GitHub branch to run. Beta is where the latest code will be. The more stable branch would be 'main'
		Default value: 'Beta'
		Accepted values: 'Beta', 'main'
		Note: This is case sensitive



[ KNOWN BUGS and LIMITATIONS]
	[ Selling ] 
	When the bot sells it doesn't perform the transactions in a single movement. So it may take up to 10 transactions to totally cash out of a token. 
	At this point this is a known limitation and no effort is being made to 'fix' this. 

	[ Buying ] 
	When a buy action is performed it always buys less then the max. It appears not to debit the account more then it purchases but transactions are usually only about 95% of what is expected. 
	I suspect this is a bug and there may be a fix later on

[ TROUBLE SHOOTING ]
	[ Telegram ]
	Telegram is a critical peice of infrastructure for this solution. 
	The bot is using a paid API which improves stability dramatically however since development has begun Telegram has had two outages so I would say it is a common problem.
	The status of Telegram can be checked here: https://downdetector.com.au/status/telegram/
	Downed APIs are not a solvable problem, if Telegram is down, just wait it out. 