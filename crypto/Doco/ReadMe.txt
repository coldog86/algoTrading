	[ Before you begin ]
1. You will need an Xaman wallet. 
	Technically it doesn't have to be Xaman, but it must have a secret in this format '261821 261821 261821 261821 261821 261821 261821 261821' as oppsoed to the mnemonic words or the shorter S**** secret number.

2. Set up a Telegram public chat. 
	The bot will be added to this chat, it is how you'll receive alerts. 

	[ SETUP ]
1. Go to here: https://raw.githubusercontent.com/coldog86/algoTrading/refs/heads/main/crypto/init.ps1
2. Copy all the code
3. Open PowerShell (start > PowerShell) 
4. Paste code, hit enter


	[ RUNNING ]
1. Open PowerShell and change to the bot's directory (cd c:\crypto)
2. Run GoBabyGo to start the bot (./GoBabyGo.ps1)

		[Paramaters]
	Paramaters are passed at runtime like this GoBabyGo.ps1 -WaitTime 10 -Branch main
	There are no manditory paramaters. Below outlines what each does and their default values. 
	-WaitTime
		Purpose: This is how long the bot will monitor a new coin for. 
		Default value: 600 (seconds)
		Accepted values: Integers i.e. Whole digit positive numbers
		Note: This value is in seconds.
	-Branch 
		Purpose: This specifies which GitHub branch to run. Beta is where the latest code will be. The more stable branch would be 'main'
		Default value: 'Beta'
		Accepted values: 'Beta', 'main'
		Note: This is case sensitive



	[ TROUBLE SHOOTING ]

		[ Telegram ]
	Telegram is a critical peice of infrastructure for this solution. 
	The bot is using a paid API which improves stability dramatically however since development has begun Telegram has had two outages so I would say it is a common problem.
	The status of Telegram can be checked here: https://downdetector.com.au/status/telegram/
	Downed APIs are not a solvable problem, if Telegram is down, just wait it out. 