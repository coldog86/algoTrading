from pycoingecko import CoinGeckoAPI
import json

cg = CoinGeckoAPI()
#print ( cg.get_price(ids='bitcoin', vs_currencies='aud') )

#result = cg.get_coin_market_chart_by_id(id='bitcoin',vs_currency='aud',days='1')
#print(json.dumps(result, sort_keys=True, indent=4))

#print( result )



data = cg.get_coin_market_chart_by_id(id='bitcoin',vs_currency='aud',days='1')


with open('data.json', 'w') as outfile:
    json.dump(data, outfile)