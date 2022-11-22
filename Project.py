import ibapi
from ibapi.client import EClient
from ibapi.wrapper import EWrapper
from ibapi.contract import Contract
from ibapi.order import *
#
import threading
import time

#Vars

# Class for IB Connection
class IBApi(EWrapper, EClient):
    def __init__(self):
        EClient.__init__(self, self)
    # Listen for realtime bars
    def realtimeBar(self, reqID, time, open_, high, low, close, volume, wap, count):
        super().realtimeBar(reqID, time, open_, high, low, close, volume, wap, count)
        try:
            bot.on_bar_update(reqID, time, open_, high, low, close, volume, wap, count)
        except Exception as e:
            print(e)
    def error(self, id, errorCode, errorMsg):
        print(errorCode)
        print(errorMsg)

# Bot logic
class Bot:
    ib = None
    def __init__(self):
        # Connect to IB on init
        self.ib = IBApi()
        self.ib.connect("127.0.0.1", 7496,1)
        ib_thread = threading.Thread(target=self.run_loop, daemon=True)
        ib_thread.start()
        time.sleep(1) # pause application for a second, to allow some auto messages to piss off.
        # Get symbol info
        symbol = input("Enter the symbol you want to trade: ")
        
        # Create the IB Contract Object
        contract = Contract()
        contract.symbol = symbol.upper #symbols need to be in uppercase 
        contract.secType = "STK" # type for useAM is Stocks
        contract.exchange = "SMART" # which exchange to use?
        contract.currency = "USD"

        # Request real time market data
        self.ib.reqRealTimeBars(0, contract, 5, "TRADES", 1, [])

    # Listen for socket in seperate thread
    def run_loop(self):
        self.ib.run()
    # Pass realtime bar data back to our bot oject
    def on_bar_update(self, reqID, time, open_, high, low, close, volume, wap, count):
        print(close)

# Start Bot
bot = Bot()