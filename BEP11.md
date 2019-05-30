# BEP-11: IEOs on Binance Chain

- [BEP-11: IEOs on Binance Chain](#ieos-on-binance-chain)
  * [1.  Summary](#1--summary)
  * [2.  Abstract](#2--abstract)
  * [3.  Status](#3--status)
  * [4.  Motivation](#4--motivation)
  * [5.  Specification](#5--specification)
    + [5.1 Creating the Offering](#51-creating-the-offering)
    + [5.2 Editing the Offering](#52-editing-the-offering)
    + [5.3 Claim period - claiming tokens](#53-claim-period-claiming-tokens)  
    + [5.4 Lottery allocation](#54-lottery-allocation)  
    + [5.5 Withdrawing tokens](#55-withdrawing-tokens)  
    + [5.6 Ending an Offering](#56-ending-an-offering)  
    + [5.7 Cancelling an Offering](#57-cancelling-an-offering)  
    + [5.8 Random value generator](#58-random-value-generator)
    + [5.9 KYC & Sybil resistance](#59-kyc--sybil-resistance)  
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

_Note: I've tried to simply implement the current IEO process with minimal adjustment. This may not be the best approach, however. Also, I'm still learning about Binance Chain so of my technical assumptions below may be incorrect - please correct me!_

It is possible that a token owner may wish to conduct more than one crowdsale. Thus, for the remainder of this spec the term _Offering_ will be used in place of _IEO_ since the latter refers specifically to an initial offering only.

Assumptions:

* The token being offered is already registered on Binance Chain as a BEP-2 asset.

Rough outline of the process:

1. The entity who wishes to conduct an Offering must first create an offering via a transaction. The resulting Offering will be a special entity that has its own unique address on Binance Chain. It will also hold a no. of tokens, taken from the total supply pool of the token being offered.
2. Once the Offering has been created and the _claim period_ has begun, any address on Binance Chain can attempt to _claim_ tokens by sending a transaction to the Offering address. This _claim_ transaction will result in the caller being allocated a max. no. of "tickets" for the allocation lottery. Each ticket is a randomly number of a large enough no. of digits.
3. Once the _claim period_ is over, The Offering owner can at any point start the _allocation lottery_ process via a transaction to the Offering address. This will run a loop which continously generates random numbers to match with the tail numbers of saved lottery tickets, and keep running until the maximum possible no. of tickets (= tokens available / tokens per ticket) have been allocated. All "winning" tickets are marked as such.
4. Callers can now check if they have a "winning" ticket and withdraw their "won" tokens by sending a transaction to the Offering address. At this point they must have enough BNB to pay for the tokens.
5. Once the _claim period_ is over, the entity who is conducting the Offering may send a transaction to _end_ the Offering and return any unclaimed tokens back to the token's original pool. 

The next few sections go into more details...

### 5.1 Creating the Offering

The entity who is running the Offering must send a _create offering_ transaction on Binance Chain. The input data for this transaction (and what ends up on the chain) consists of:

| **Field**    | **Type** | **Description**                                              |
| :------------ | :-------- | :------------------------------------------------------------ |
| Token        | string   | The BEP-2 symbol of a valid token on Binance Chain. |
| Supply       | int64    | The supply of this token that is being made available for this Offering. There must be atleast this amount owned by the caller address so that it can get allocated to the Offering address. |
| MeasureStartDate       | timestamp    | The start date for the range of dates over which the caller's average BNB balance gets calculated. |
| MeasureEndDate       | timestamp    | The start date for the range of dates over which the caller's average BNB balance gets calculated. |
| ClaimStartDate | timestamp | Start of the _claim period_ |
| ClaimEndDate | timestamp | End of the _claim period_ |
| PricePerTicket | int64 | Price per ticket (in BNB) |
| TokensPerTicket | int64 | Tokens per ticket |
| MaxTicketsPerClaim | int64 | Max. no. of tickets available per claim |

### 5.2 Editing the Offering

Up until the _claim period_ has started, the Offering owner can "edit" the following details of the Offering by virtue of on-chain transactions:

| **Field**    | **Type** | **Description**                                              |
| :------------ | :-------- | :------------------------------------------------------------ |
| MeasureStartDate       | timestamp    | The start date for the range of dates over which the caller's average BNB balance gets calculated. |
| MeasureEndDate       | timestamp    | The start date for the range of dates over which the caller's average BNB balance gets calculated. |
| ClaimStartDate | timestamp | Start of the _claim period_ |
| ClaimEndDate | timestamp | End of the _claim period_ |
| PricePerTicket | int64 | Price per ticket (in BNB) |
| TokensPerTicket | int64 | Tokens per ticket |
| MaxTicketsPerClaim | int64 | Max. no. of tickets available per claim |

Once the _claim period_ has started, the Offering owner can only "edit" the _claim period_ end date. And importantly the end date can only be moved backward (i.e. into the future), not forwards.

### 5.3 Claim period - claiming tokens

The caller sends a transaction to the Offering address. This results in the following computation off-chain:

1. Calculate caller’s average BNB holdings between `MeasureStartDate` and `MeasureEndDate` inclusive
2. Calculate max. no. of tickets for caller based on their average holdings over the measurement period, ensuring not to exceed `MaxTicketsPerClaim`.
3. Generate this no. of tickets whereby each ticket is a [randomly generated](#58-random-value-generator) number with a large number of digits. I propose 18 digits to be sufficient, meaning a maximum of 9^18 tickets are possible to be generated.
4. Record all the tickets for this caller into the storage area associated with the Offering address.
5. The total no. of generated lottery tickets is record as `TotalClaimedTickets`.

### 5.4 Lottery allocation

Once the _claim period_ is over, the Offering owner can send a transaction to the Offering address to trigger the _lottery allocation_. This results in the following:

1. Use a [CSRNG](#58-random-value-generator) to generate a seed value. Record this into storage.
2. Input the seed value into a PRNG to deterministically generate 3-digit numbers. Mark all the matching generated tickets (by comparing last 3 digits of ticket numbers) as winning. Repeat until the max possible no. of tickets (`= Math.min(Supply / TokensPerTicket, TotalClaimedTickets`) have been matched.

### 5.5 Withdrawing tokens

Once the _lottery allocation_ is complete, callers can send a transaction to the Offering address to obtain their "won" tokens. Their BNB balance is deducted accordingly. 

### 5.6 Ending an Offering

Once the _lottery allocation_ is complete, the owner of an Offering can send a transaction at any point to end the offering. This will cause all unclaimed tokens to be returned to the token's original supply and the Offering itself disabled for further withdrawals.

### 5.7 Cancelling an Offering

Cancelling an Offering is only possible up until before the _lottery allocation_ process has started. Once winning tickets have been allocated, an Offering cannot be cancelled. Cancellation is done by the Offering owner sending a transaction to the Offering address.

### 5.8 Random value generator

A key requirement of this BEP is a Cryptographically-Secure Random Number Generator (CSRNG). Ideally the numbers generated by this RNG would be a publicly verifiable. The key properties of such an RNG would be: in-corruptible, un-predictable, always-available, publicly-verifiable. 

This could be a whole BEP in and of itself, though I would argue that Binance Chain would, in general, benefit from having a random "beacon" of sorts that fits this critieria. A beacon based on the BLS signature mechanism would, in my view, be a suitable implementation as we could probably build this using Binance Chain's existing validator set. BLS signatures are already in use by various blockchains (DFinity, Harmony, Casper, etc).

### 5.9 KYC & Sybil resistance

Two further problems need solving to allow for IEOs on Binance Chain:

* Ensuring a person cannot exceed `MaxTicketsPerClaim` by contributing from more than one address (Sybil resistance).
* Ensuring that only people who are KYC/AML approved can contribute.

Both could be solved by introducing the notion of a KYC-approved list of sender addresses which gets stored in a Binance Chain "central storage" area of some sort. The list would only be editable by trusted editors (initially, just Binance) and could potentially be represented as a hash table mapping a Binance Chain address to a struct as such:

`
kyc_approved: <Boolean>
country: <ISO 2-letter code>
`

During the _claim period_, the Offering would only allow a caller to claim tokens if their address is present in this list with the right attributes set.

When creating an Offering there could be an additional input field:

| **Field**    | **Type** | **Description**                                              |
| :------------ | :-------- | :------------------------------------------------------------ |
| AllowedCountries | [string] | List of ISO 2-letter country codes representing countries whose citizens may claim tokens in this IEO. All others will be disallowed. |

Of course, if this list of allowed countries is the same across IEOs then it could be stored in Binance Chain alongside the KYC list above.

To get one's BNB sender address onto the KYC list one would have to complete KYC on Binance.com as per normal and enter a Binance Chain address one wishes to use for IEO contributions. Binance.com would then write this information to the Binance Chain KYC list above.

## 6. License

The content is licensed under [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
