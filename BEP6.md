# BEP-6: Delist Trading Pairs

## 1. Summary
This BEP describes a proposal for delisting trading pairs on the Binance Chain.
## 2. Abstract
Listing new trading pairs is done via listing proposals. Suppose a token has credit issue or one of its trading pairs has too little trading volume for a long time, then the community might consider to drop related trading pairs to save network cost. This BEP proposes a method to delist trading pairs via governance. The below picture describes the overview of how delist logic works. 

```
+-----------------+       +----------------+        +---------------+        +--------------------+       +--------+
|                 |       | deposit period |        | voting period |        | cooling-off period |       |        |
|                 |       |   +--------+   |        | +-----------+ |        |     +--------+     |       |        |
| Submit proposal | <---> |   | 2 days |   | <----> | | less than | | <----> |     | 3 days |     | <---> | delist |
|                 |       |   +--------+   |        | |  14 days  | |        |     +--------+     |       |        |
|                 |       |                |        | +-----------+ |        |                    |       |        |
+-----------------+       +----------------+        +---------------+        +--------------------+       +--------+
```

## 3. Status
This BEP is WIP.
## 4. Motivation
Delisting is to concentrate computing resource on good assets and provide a way to clean up or correct the trading markets on DEX.
## 5. Specification
The delisting procedure can be divided into three steps: 

- Submit proposal and vote proposal
- Cooling-off period
- Check constraints and expire orders

To delist a trading pair, users just need to submit a `DelistTradingPair` proposal. If the proposal is passed finally, then step 2 and step 3 will be automatically triggered. If one step failed, all following steps won’t be executed. 
### 5.1 DelistTradingPair Proposal
Firstly, users must propose by specifying which trading pair to delist and the corresponding justification. 


|        Name         |   Type      |        Description        |    json field      |
| ------------------- | ----------- | ------------------------  | ------------------ |
| BaseAssetSymbol     |   string    | base asset symbol         | base_asset_symbol  |
| QuoteAssetSymbol    |   string    | quote asset symbol        | quote_asset_symbol |
| Justification       |   string    | the reason to delist trading pair; the maximum length is limited by proposal total length, which is 2048 bytes | justification |

These parameters will be json marshaled to string and assigned to proposal `Description` field. 

Secondly, DelistTradingPair proposal is kind of governance proposal. It requires other governance related parameters:

|        Name       |   Type      |        Description        |
| ----------------- | ----------- | ------------------------  |
|       Title       |   string    | base asset symbol         |
|    Description   |   string    | Json marshals string of BaseAssetSymbol, QuoteAssetSymbol and Justification |
|    ProposalType   |   string    | Type of proposal, here the type should be “DelistTradingPair” |
|      Proposer     | Bech32_address | Address of the proposer |
|   InitialDeposit  |   coins    | Initial deposit paid by sender. Must be strictly positive |
|    VotingPeriod   |   int      | Length of the voting period|

For other document about governance proposal, please refer to this page: https://docs.binance.org/governance.html#proposal-parameters

### 5.2 Cooling-Off Period
Once a `DelistTradingPair` proposal is passed, it will enter cooling-off period. This period length is around 3 days from the time of vote pass until the 3rd UTC midnight. As the name suggests, users should re-evaluate the market and take action on the asset to be delisted as they wish, as in this period, users can create new orders and cancel orders on the trading pair as usual. Once this period is ended, all outstanding orders (unfilled or uncanceled) on the market will expire.
### 5.3 Delist
Delist happens on the 3rd midnight (UTC) after the proposal is voted pass. There are 2 steps to delist trading pairs as below.
#### 5.3.1 Trading Pairs Constraint Check
In binance chain, all listed tokens must be listed against BNB first. Suppose there are three tokens on binance chain: `A`, `B` and `BNB`, and there only one trading pair: `A_BNB`. If someone wants to create a new trading pair: `A_B`, then he must create another trading pair first: `B_BNB`.

In conclude, a `non-BNB` trading pair `A_B` will depend on two other trading pairs: `A_BNB` and `B_BNB`, and any `BNB` related trading pair might be the dependency of other trading pairs.

The constraint will be checked before removing the trading pair. If the constraint is not satisfied, the trading pair won’t be removed. If the delister still want to delist the trading pair, he/she must propose a new DelistTradingPair proposal on this trading pair again. However, before doing that, the delister must figure out all trading pairs which depend on this trading pair and delist all of them.
#### 5.3.2 Remove Trading Pair And Expire All Orders  
Once the trading pair constraint check is passed, the clearance operation will be triggered immediately. All related outstanding orders will be expired. The locked tokens in the orders will be refunded to users and fee will be charged as normal expire orders.

After these 2 steps, the trading pair will be removed from the market lists. The delist operation is done.
## 6. License
All the content is licensed under [CC0](https://creativecommons.org/publicdomain/zero/1.0/).


