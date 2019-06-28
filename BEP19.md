# BEP-19: Introduce Maker and Taker for Match Engine

- [BEP-19: Introduce Maker and Taker for Match Engine](#bep-19--introduce-maker-and-taker-for-match-engine)
  * [1. Summary](#1-summary)
  * [2. Abstract](#2-abstract)
  * [3.  Status](#3--status)
  * [4. Motivation](#4-motivation)
  * [5. Specification](#5-specification)
    + [5.1 Price Determination](#51-price-determination)
    + [5.2 Execution Allocation](#52-execution-allocation)
      - [5.2.1 Definition of Maker and Taker](#521-definition-of-maker-and-taker)
      - [5.2.2 Execution Pricing](#522-execution-pricing)
    + [5.3 Match Time](#53-match-time)
    + [5.4 Publish](#54-publish)
  * [6. License](#6-license)

## 1. Summary

This BEP describes a new on-chain match engine, Maker/Taker concepts are introduced to enhance the current periodic auction match algorithm.

## 2. Abstract

The current match engine uses a periodic auction match algorithm. Matching will be executed once every block,  all the candidate orders will be tried to be matched at the same time at the same price in every auction. 

Based on that algorithm, this specification introduces the concepts of maker and taker. The match is still executed only once in each block while the execution prices may vary for maker and taker orders.

## 3.  Status

This BEP is under implementation.

## 4. Motivation

On not-so-liquid or highly volatile markets, the classic periodic auction match methodology would result in much worse average trade price to aggressive orders (i.e. Taker orders in the continuous match context), because all the trades would be marked with one final price, instead of the average price of all the waiting orders from the market. This is not friendly to active traders and amateur clients that are more familiar with continuous match markets. This causes extra effort to split aggressive orders and much confusion as Binance DEX matches as fast as continuous matching exchange.

## 5. Specification

An Auction Match comprises two steps, Price Determination followed by Execution Allocation.

### 5.1 Price Determination
This BEP keeps the current algorithm to determine the single equilibrium match price, the following criteria shall be assessed in sequence: 
 - Maximize the execution quantity
 - Execute all orders or at least all orders on one side that are fillable against the selected price.
 - Indicate the market pressure from either buy or sell and also consider to limit the max price movement
let’s call this concluded price `P`.

### 5.2 Execution Allocation

#### 5.2.1 Definition of Maker and Taker

Among all the orders to be allocated, between buy and sell sides, this specification defines four concepts.

| Name        | Definition                           |
| ----------- | ------------------------------------ |
| Maker Order | order from the previous blocks       |
| Taker Order | new incoming order in the current block   |
| Maker Side  | buy or sell side which has maker orders. May also have taker orders.  |
| Taker Side  | buy or sell side which only has taker orders. |

In each round of match, for all the orders that can be filled with the concluded price `P`, the algorithm ensures only one of the below two circumstances can happen, 

1. Both buy and sell side are `Taker Side`, when there is no leftover orders from all the previous blocks; or, 

2. One side is `Maker Side` that has orders from previous blocks (and may/may not have orders from this current block),  and the other is `Taker Side` that only has orders from this current block.

#### 5.2.2 Execution Pricing

Among all the orders to be allocated,

1. For maker side,
    - all the maker orders are executed at their limit price
    - all the taker orders on the maker side are executed at the concluded price `P`

2. For taker side, all the orders are executed at the `average execution price` from the above #1

If no maker side in this match, all the orders are executed at price `P`.

### 5.3 Match Time

Candidates would be matched right after one block is committed. Each block has one round of match.

### 5.4 Publish

In `OrderUpdates` messages, the trades generated in each block are published, either in json format or avro format.  Here we can add a new field `TickType` to the `Trade` to indicate which side is the taker.


| TickType Enum | Int value | Explanation | 
| ------------- | --------- | ----------- |
| Unknown       | 0         | For compatibility, all trades would use this before upgrade.
| SellTaker     | 1         | Sell order is the taker
| BuyTaker      | 2         | Buy order is the taker
| BuySurplus    | 3         | Both are taker, buy side has surplus. Market pressure is on the buy side
| SellSurplus   | 4         | Both are taker, sell side has surplus. Market pressure is on the sell side
| Neutral       | 5         | Both are taker, surplus is 0.

When displaying the trade history, any client UI is suggested to show the above TickType in the below way:

1. Unknown in a neutral color
2. SellTaker/SellSurplus in downtick color
3. BuyTaker/BuySurplus/Neutral in uptick color

## 6. License

All the content is licensed under [CC0](https://creativecommons.org/publicdomain/zero/1.0/).