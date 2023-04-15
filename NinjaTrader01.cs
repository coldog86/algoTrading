
// Golden Cross
protected override void OnBarUpdate()
{
// if the fast simple moving average crosses above the slow simple moving average within the last bar, go long
  if (CrossAbove(SMA(Fast), SMA(Slow), 1))
    EnterLong();

// if the fast simple moving average crosses above the slow simple moving average within the last bar, go short
  if (CrossBelow(SMA(Fast), SMA(Slow), 1))
    EnterShort();
}


if (        
        ((Position.MarketPosition != MarketPosition.Long)
        || (Position.MarketPosition != MarketPosition.Short)
        || (EMA1[0] > EMA1[1])
        || (Close[0] > Open[0])
        || (CrossAbove(EMA1, SMA1, 1))
        || (CrossAbove(SMA(Fast), SMA(Slow), 1))
        || (SMA1[0] > SMA1[1])
        || (UseLong == true))
)
{
    EnterLong(Convert.ToInt32(Contracts), @"Long");
}
