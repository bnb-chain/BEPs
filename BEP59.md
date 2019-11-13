# BEP-59: Auction Module for Tokens

- [BEP-59: Auction Module for Tokens](#bep-59-auction-module-for-tokens)
  - [1. Summary](#1-summary)
  - [2. Abstract](#2-abstract)
  - [3. Status](#3-status)
  - [4. Motivation](#4-motivation)
  - [5. Specification](#5-specification)
    - [5.1 Transactions](#51-transactions)
      - [5.1.1 PlaceBid](#511-placebid)
      - [5.1.2 QueryAuctions](#512-queryauctions)
  - [6. License](#6-license)

## 1.  Summary

This BEP describes a proposal for adding auction functionality to tokens or NFTs on the Binance Chain.

## 2.  Abstract

BEP-59 Proposal describes functionality to auction tokens and NFTs on the Binance Chain. Such as:

+ StartForwardAuction: StartForwardAuction starts a normal flap auction.
+ StartReverseAuction: StartReverseAuction starts a flop auction where sellers compete by offering decreasing prices.
+ StartForwardReverseAuction: StartForwardReverseAuction starts a flip auction where bidders bid up to a maximum bid, then switch to bidding down on price.


## 3.  Status

Work in progress (WIP).

## 4.  Motivation

Auction functionality expands value for NFT's, create the option for a bidding marketplace, allows auction based IEO's, as well as required functionality for auctioning off collateral in many DeFi solutions.

## 5.  Specification

###  5.1 Transactions

#### 5.1.1 PlaceBid

PlaceBid transactions can place a bid on an existing internally created auction.

A fee (a fixed amount of BNB) will be charged on PlaceBid transactions.

**Parameters for PlaceBid Operation**:

| **Field**    | **Type** | **Description**                                              |
| :------------ | :-------- | :------------------------------------------------------------ |
| AuctionID   | ID  | The auction created |
| Bidder        | sdk.AccAddress   | This can be a buyer (who increments bid), or a seller (who decrements lot) |
| Bid      | sdk.Coin  | The bid placed on the auction  |
| Lot      | sdk.Coin  | The lot up for auction  |

#### 5.1.2 QueryAuctions

QueryAuctions returns a list of all current active auctions.

## 6. License

The content is licensed under [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
