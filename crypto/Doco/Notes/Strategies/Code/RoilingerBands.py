import pandas as pd
import ace_tools as ace_tools

# Load the data
file_path = '/mnt/data/Combined.csv'
data = pd.read_csv(file_path)

# Rename columns for clarity
data.columns = ['Date', 'Time', 'Close', 'Token', 'Supply']

# Convert Date and Time to a single datetime column for easier processing
data['Datetime'] = pd.to_datetime(data['Date'] + ' ' + data['Time'])
data = data.sort_values(by=['Token', 'Datetime'])

# Define Bollinger Bands strategy parameters
rolling_window = 50
std_dev_multiplier = 6
fixed_outlay = 10  # Fixed $10 per buy
initial_balance = 100  # Starting balance
slippage = 0.05  # 5% slippage per trade

# Initialize results storage
results = []

# Apply strategy to each token
for token, token_data in data.groupby('Token'):
    token_data = token_data.copy()
    token_data['Rolling Mean'] = token_data['Close'].rolling(rolling_window).mean()
    token_data['Upper Band'] = token_data['Rolling Mean'] + (token_data['Close'].rolling(rolling_window).std() * std_dev_multiplier)
    token_data['Lower Band'] = token_data['Rolling Mean'] - (token_data['Close'].rolling(rolling_window).std() * std_dev_multiplier)
    
    # Initialize variables for the strategy
    balance = initial_balance
    holdings = 0
    total_trades = 0
    
    for i in range(len(token_data)):
        row = token_data.iloc[i]
        
        # Buy signal: Close price below lower Bollinger Band
        if row['Close'] < row['Lower Band'] and holdings == 0 and balance >= fixed_outlay:
            trade_price = row['Close'] * (1 + slippage)
            quantity = fixed_outlay / trade_price
            holdings += quantity
            balance -= fixed_outlay
            total_trades += 1
        
        # Sell signal: Close price above upper Bollinger Band
        elif row['Close'] > row['Upper Band'] and holdings > 0:
            trade_price = row['Close'] * (1 - slippage)
            balance += holdings * trade_price
            holdings = 0
            total_trades += 1
    
    # Finalize holdings if any left at the end
    if holdings > 0:
        balance += holdings * token_data['Close'].iloc[-1] * (1 - slippage)
    
    # Calculate ROI for this token
    roi = ((balance - initial_balance) / initial_balance) * 100
    results.append({
        'Token': token,
        'Trades': total_trades,
        'ROI': roi,
        'Final Balance': balance
    })

# Create a DataFrame for results and calculate total ROI
results_df = pd.DataFrame(results)
total_roi = ((results_df['Final Balance'].sum() - (initial_balance * len(results_df))) / (initial_balance * len(results_df))) * 100

# Display results to the user
results_df['ROI'] = results_df['ROI'].round(3)
results_df['Final Balance'] = results_df['Final Balance'].round(3)
total_roi = round(total_roi, 3)

# Display the results
ace_tools.display_dataframe_to_user(name="Bollinger Bands Strategy Results", dataframe=results_df)

# Print the overall ROI
total_roi
