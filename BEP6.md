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

To delist a trading pair, users just need to to send a `DelistTradingPair` proposal. In the proposal description field, users should specify which trading pairs will be delisted and why to do this. If the proposal is passed before the time limit, then target trading pairs will be delisted and all related orders will be cancelled.

### 5.1 Send proposal

Proposal should contain:
1. Trading pair to delist: base asset and quote asset
2. Justification: why we need to delist this token.

### 5.2 Delist trading pairs and expire all orders in breathe block
We assume that the ideal proposal life cycle is like this:
- The deposit period is 2 days
- The voting period is 14 days
- The delisting operation will happen 3 days after proposal is passed. 

The total time is 20 days. In each breathe block, all `DelistTradingPair` proposals which are submitted in less than 20 days ago will be judged. If a `DelistTradingPair` proposal is passed, and its passed time is 3 day before the breathe block time, then a delist operation will be triggered. 

When a trading pair is delisted, all related uncompleted orders will be expired. The locked tokens in the orders will be refunded to users and no expire fee will be deducted.

## 6. License

The content is licensed under [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

