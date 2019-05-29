# BEP-2: IEOs on Binance Chain


- [BEP-2: IEOs on Binance Chain](#ieos-on-binance-chain)
  * [1.  Summary](#1--summary)
  * [2.  Abstract](#2--abstract)
  * [3.  Status](#3--status)
  * [4.  Motivation](#4--motivation)
  * [5.  Specification](#5--specification)
  * [6. License](#6-license)

## 1.  Summary

This BEP describes a proposal for conducting Initial Exchange Offerings (IEOs) on the Binance Chain.

## 2.  Abstract

A specification for running IEOs directly on Binance Chain. This specification attempts to provide details on how the 
currently active IEO process (as of May 29, 2019) can be transplanted to run on Binance Chain, including any necessary 
modifications to the chain protocol itself.

## 3.  Status

This BEP is in Draft status.

## 4.  Motivation

Several IEOs have been successfully conducted on Binance.com. However, they lack the benefits of transparency and 
decentralization which Binance Chain provide. Furthermore, it seems that most (if not all) IEOs (Harmony.One) result in 
contributors being awarded BEP-2 tokens that are native to Binance Chain. Thus it makes sense to take things one step 
forward and conduct the IEO itself on Binance Chain, thus providing far greater transparency and auditability to 
the process.

In summation, here are some of the benefits:

* Greater transparency and auditability, thereby increasing trust in the IEO process, and thus its popularity.
* No need to bridge from Binance.com to Binance Chain (i.e. BNB no longer needs to be sent to Binance.com in order 
to participate, thus reducing participant risk).
* Faster turnaround time from IEO to tradeability of crowdfunded token, since the offered token is already present on Binance Chain.

## 5.  Specification

It is possible that a token owner may wish to conduct more than one crowdsale. Thus, for the remainder of this spec the term _Offering_ will be used in place of _IEO_ since the latter refers specifically to an initial offering only.

_Note: I've tried to simply implement the current IEO process with minimal adjustment. This may not be the best approach, however._

_Note: I'm still learning about Binance Chain so of my technical assumptions below may be incorrect - please correct me!_

### 5.1 Overview of process

Assumptions:

* The token being offered is already registered on Binance Chain as a BEP-2 asset.

Rough outline of the process:

1. The entity who wishes to conduct an Offering must first create an offering via a transaction. The resulting Offering will be a special entity that has its own unique address on Binance Chain. It will also hold a no. of tokens, taken from the total supply pool of the token being offered.
2. Once the Offering has been created and the _claim period_ has begun, any address on Binance Chain can attempt to _claim_ tokens by sending a transaction to the Offering address. This _claim_ transaction will result in the caller being allocated a share of the available tokens according to lottery rules. They will give up the requisite amount of BNB according to the preset token/BNB price and recieve their allocated tokens in return.
3. Once the _claim period_ is over, the entity who is conducting the Offering may send a transaction to _end_ the Offering and return any unclaimed tokens back to the token's total supply pool. 

The next few sections go into more details...

### 5.2 Creating the Offering

The entity who is running the Offering must send a _create offering_ transaction on Binance Chain. The input data for this transaction (and what ends up on the chain) consists of:

| **Field**    | **Type** | **Description**                                              |
| :------------ | :-------- | :------------------------------------------------------------ |
| Token        | string   | The BEP-2 symbol of a valid token on Binance Chain. |
| Supply       | int64    | The supply of this token that is being made available for this Offering. There must be atleast this amount owned by the caller address so that it can get allocated to the Offering address. |
| MeasureStartDate       | timestamp    | The start date for the range of dates over which the caller's average BNB balance gets calculated. |
| MeasureEndDate       | timestamp    | The start date for the range of dates over which the caller's average BNB balance gets calculated. |
| ClaimStartDate | timestamp | Start of the _claim period_ |
| ClaimEndDate | timestamp | End of the _claim period_ |
| Price | int64 | Price per ticket (in BNB) |
| TokensPerTicket | int64 | Tokens per ticket |
| MaxTicketsPerClaim | int64 | Max. no. of tickets available per claim |

	- Linked to token by Symbol
	- Allocates certain amount of token to be locked into Offering process 
	- Config: BNB Measurement start date
	- Config: BNB Measurement duration
	- Param: per-BNB price of token (fixed from now on)

Transaction to claim tokens (by user), costs small BNB fee:
	- Chain calculates user’s average BNB holdings between start date and end dates
	- Chain calculates lottery tickets for user based on their average holdings
	- Chain randomly allocates token percentage to user based on their lottery tickets
	- Chain stores this data (is there somewhere better?)

Transaction to get tokens (by user), costs small BNB fee:
	- Allocate tokens to user based on their previously calculated percentage


### 5.3 Editing the Offering

Up until the _claim period_ has started, the Offering owner can "edit" the following details of the Offering by virtue of on-chain transactions:

| **Field**    | **Type** | **Description**                                              |
| :------------ | :-------- | :------------------------------------------------------------ |
| MeasureStartDate       | timestamp    | The start date for the range of dates over which the caller's average BNB balance gets calculated. |
| MeasureEndDate       | timestamp    | The start date for the range of dates over which the caller's average BNB balance gets calculated. |
| ClaimStartDate | timestamp | Start of the _claim period_ |
| ClaimEndDate | timestamp | End of the _claim period_ |
| Price | int64 | Price per ticket (in BNB) |
| TokensPerTicket | int64 | Tokens per ticket |
| MaxTicketsPerClaim | int64 | Max. no. of tickets available per claim |

Once the _claim period_ has started, the Offering owner can only "edit" the _claim period_ end date. And importantly the end date can only be moved backward (i.e. into the future), not backwards.

### 5.3 Claim period - claiming tokens

### 5.4 Ending an offering

### 5.5 KYC & sybil resistance

### 5.6 Cancelling an Offering



This specification builds 

The Binance Token, BNB, is the native asset on Binance Chain and created within Genesis Block. As the native asset, BNB would be used for fees (gas) and staking on Binance Chain. BNB was an ERC20 token, but after Binance Chain is live, all BNB ERC20 tokens are swapped for BNB token on Binance Chain. All users who hold BNB ERC20 tokens can deposit them to Binance.com, and upon withdrawal, the new Binance Chain native tokens will be sent to their new addresses.


Transaction to create an Offering (by token owner), costs large BNB fee:
	- Linked to token by Symbol
	- Allocates certain amount of token to be locked into Offering process 
	- Config: BNB Measurement start date
	- Config: BNB Measurement duration
	- Param: per-BNB price of token (fixed from now on)

Transaction to claim tokens (by user), costs small BNB fee:
	- Chain calculates user’s average BNB holdings between start date and end dates
	- Chain calculates lottery tickets for user based on their average holdings
	- Chain randomly allocates token percentage to user based on their lottery tickets
	- Chain stores this data (is there somewhere better?)

Transaction to get tokens (by user), costs small BNB fee:
	- Allocate tokens to user based on their previously calculated percentage




## 6. License

The content is licensed under [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
