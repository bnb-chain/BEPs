# BEP-6: Delist Trading Pairs

## 1. Summary

This BEP describes a proposal for delisting trading pairs on the Binance Chain.

## 2. Abstract

Currently, we already have listing proposal to list new trading pairs. However, we can't delist any trading pairs now. Suppose a token has very bad reputation or one of its trading pairs has little trading volume for a long time, then the community might consider to remove related trading paris. BIP-5 proposal just provides the community a method to delist the unwanted trading pairs.

## 3. Status

This BEP is R4R. 

## 4. Motivation

To accelerate dex TPS and make the community healthier, some tokens with bad reputations or some trading pairs have very little trading volume should be removed.

## 5. Specification

### 5.1 `DelistTradingPair` proposal

**Msg Parameters**:

|                 |  Type           | Description          |
| --------------- | --------------- | -------------------- |
|  Title          | string          | Title of the proposal |
|  Description    | string          | Description of the proposal |
|  ProposalType   | ProposalKind    | Type of proposal |
|  Proposer       | Bech32_address  | Address of the proposer |
|  InitialDeposit | Coins           | Initial deposit paid by sender. Must be strictly positive. |
|  VotingPeriod   | int             | Length of the voting period |

Parameters to specify which trading pair to delist and why to do this. 

|                     |  Type    | Description          | json field |
| ------------------- | -------- | -------------------- | ---------- |
|  BaseAssetSymbol    | string   | base asset symbol    | base_asset_symbol |
|  QuoteAssetSymbol   | string   | quote asset symbol   | quote_asset_symbol| 
|  Justification      | string   | the reason to delist trading pair | justification|

The above data structures will be json marshaled to string and assigned to proposal `Description` field.

### 5.2 Delist trading pairs and expire all orders in breathe block
We assume that the ideal proposal life cycle is like this:
```
+-----------------+       +----------------+        +---------------+        +--------------+       +--------+
|                 |       | deposit period |        | voting period |        | delayed days |       |        |
|                 |       |   +--------+   |        | +-----------+ |        |  +--------+  |       |        |
| Submit proposal | <---> |   | 2 days |   | <----> | | less than | | <----> |  | 3 days |  | <---> | delist |
|                 |       |   +--------+   |        | |  14 days  | |        |  +--------+  |       |        |
|                 |       |                |        | +-----------+ |        |              |       |        |
+-----------------+       +----------------+        +---------------+        +--------------+       +--------+
```
If a `DelistTradingPair` proposal is passed, and its passed time is 3 day before the breathe block time, then a delist operation will be triggered.

When a trading pair is delisted, all related uncompleted orders will be expired. The locked tokens in the orders will be refunded to users and fee will be charged as normal expire orders.

### 5.3 Delist dependency

In binance chain, all listed tokens must be listed against `BNB` first. Suppose there are three tokens on binance chain: `A`, `B` and `BNB`, and there only one trading pair: `A_BNB`. If someone want to create a new trading pair: `A_B`, then he must create another trading pair first: `B_BNB`. This is the dependency example between different trading pairs. 

In conclusion, a non-`BNB` trading pair `A_B` will depend on two other trading pairs: `A_BNB` and `B_BNB`, and any non-`BNB` trading pairs won't be the dependency of other trading pairs. A `BNB` related trading pair might be the dependency of other trading pairs.

So we can delist any non-`BNB` related trading pairs directly. However, if you want to delist a `BNB` related trading pair, you must check if there are other trading pairs which depend on it. If so, you must delist these trading pairs first.

## 6. License

The content is licensed under [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

