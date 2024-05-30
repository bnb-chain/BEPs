# BEP-6: Delist Trading Pairs

## 1. Summary
This BEP describes a proposal for delisting trading pairs from the BNB Beacon Chain DEX.
## 2. Abstract
Listing new trading pairs is done via listing proposals. Suppose a token has a crediting issue or one of its trading pairs has little trading volume for a long time, the community might consider to drop related trading pairs to save network cost. This BEP proposes a method to delist trading pairs via governance. The below picture describes the overview of how delist logic works.

```
+----------+     +----------------+      +---------------+      +--------------------+     +--------+
|          |     | deposit period |      | voting period |      | cooling-off period |     |        |
|  Submit  |     |   +--------+   |      | +-----------+ |      |     +--------+     |     |        |
| proposal |<--->|   | 2 days |   |<---->| | less than | |<---->|     | 3 days |     |<--->| delist |
|          |     |   +--------+   |      | |  14 days  | |      |     +--------+     |     |        |
|          |     |                |      | +-----------+ |      |                    |     |        |
+----------+     +----------------+      +---------------+      +--------------------+     +--------+
```

## 3. Status
This BEP is already implemented.
## 4. Motivation
The purpose of delisting is to prioritise  computing resources on healthy assets and provide a way to optimise trading markets on DEX.
## 5. Specification
The delisting procedure can be divided into three steps:

- Submit and voting on proposal
- Cooling-off period
- Check constraints and expire orders

To delist a trading pair, users submit a DelistTradingPair proposal. If the proposal is passed, then step 2 and 3 will be triggered. If any of the steps fail, all subsequent steps will not be executed.
### 5.1 DelistTradingPair Proposal
Firstly, users must propose by specifying which trading pair to delist and the corresponding justification.

|        Name         |   Type      |        Description        |    json field      |
| ------------------- | ----------- | ------------------------  | ------------------ |
| BaseAssetSymbol     |   string    | base asset symbol         | base_asset_symbol  |
| QuoteAssetSymbol    |   string    | quote asset symbol        | quote_asset_symbol |
| Justification       |   string    | the reason to delist trading pair; the maximum length is limited by proposal total length, which is 2048 bytes | justification |

These parameters will be json marshaled to strings and assigned to the Description field.

The DelistTradingPair proposal is similar to a governance proposal. It requires other governance related parameters:

|        Name       |   Type      |        Description        |
| ----------------- | ----------- | ------------------------  |
|       Title       |   string    | base asset symbol         |
|    Description   |   string    | Json marshals string of BaseAssetSymbol, QuoteAssetSymbol and Justification |
|    ProposalType   |   string    | Type of proposal, here the type should be “DelistTradingPair” |
|      Proposer     | Bech32_address | Address of the proposer |
|   InitialDeposit  |   coins    | Initial deposit paid by sender. Must be strictly positive |
|    VotingPeriod   |   int      | Length of the voting period|


### 5.2 Cooling-Off Period
Once a `DelistTradingPair` proposal is passed, it will enter a cooling-off period. The cooling-off period lasts until the next UTC 00:00 after the 72-hour point of the proposal passing.  As the name suggests, users should re-evaluate the market and take action on the proposed asset to be delisted. In this period, users can still create new orders and cancel orders on the trading pair. Once this period has ended, all outstanding orders will expire.
### 5.3 Delist
Delisting happens on the next UTC 00:00 after the 72-hour point of the proposal passing. There are 2 steps to delist trading pairs as below.
#### 5.3.1 Trading Pairs Constraint Check
For BNB Beacon Chain, all listed tokens requires `BNB` as an initial base pair. Suppose there are three tokens on BNB Beacon Chain: `A`, `B` and `BNB`, and there is only one trading pair: `A_BNB`. If someone wants to create a new `A_B` trading pair, he must create the `B_BNB` trading pair first.

In conclusion, a `non-BNB` trading pair `A_B` will depend on two other trading pairs: `A_BNB` and `B_BNB`, and any `BNB` related trading pair may be the dependency of other trading pairs.

This constraint is checked before the removal of the trading pair. If the constraint is not satisfied, the trading pair won’t be removed. If the delister still wishes to delist the trading pair, he must propose a new `DelistTradingPair` proposal on this trading pair again. However, before doing that, the delister must delist all dependent trading pairs first.

#### 5.3.2 Remove Trading Pair And Expire All Orders
Once the trading pair constraint check has been passed, the clearance operation will be triggered and all related outstanding orders will expire. The locked tokens in the orders will be refunded to users and order expiration fee will be charged.

After these 2 steps, the trading pair will be removed. The delisting process is complete.

## 6. License
All the content is licensed under [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

