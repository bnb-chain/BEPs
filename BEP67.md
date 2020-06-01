# BEP-67: Price-based Order Expiration

- [BEP-67: Price-based Order Expiration](#bep-67-Price-based-order-expiration)
  - [1. Summary](#1-summary)
  - [2. Abstract](#2-abstract)
  - [3. Status](#3-status)
  - [4. Motivation](#4-motivation)
  - [5. Specification](#5-specification)
    - [5.1 Order Expiration](#51-order-expiration)
    - [5.2 Change Impact](#52-change-impact)
  - [6. License](#6-license)

## 1. Summary 

This BEP describes an enhancement of the [Order Expiration](https://docs.binance.org/faq.html#what-is-order-expire).  

## 2. Abstract

Currently orders on Binance Chain will be expired after 3 days. Order cannot live long on the market even their price stays competitive, which is not convenient and incurs cost to traders. The solution is to keep orders in the best 500 price levels for 30 days rather than 3 days.

## 3. Status

This BEP is under specification.

## 4. Motivation

Traders want to keep their open orders more than 3 days so that they do not need re-create their cancelled orders every 3 days. 


## 5. Specification

###  5.1 Order Expiration
By current implementation, in the first block after UTC 00:00 every day, orders which have been staying in order book for longer than 72 hours will be removed from order book and marked as 'expired'. 
After the implementation of BEP-67, those orders in the best 500 price levels on both ask and bid side will be expired after 30 days instead of 72 hours. Meanwhile, the expiration fee is unchanged.


###  5.2 Change Impact
####  5.2.1 Impact on Trader
For those traders who follow current strict 3-day expiration time, they may need change their order placement strategy.
####  5.2.2 Impact on Binance Chain
There could be more orders in node memory. So the compulsory expiration is introduced for the orders older than 30 days.
## 6. License

The content is licensed under [CC0](https://creativecommons.org/publicdomain/zero/1.0/).



