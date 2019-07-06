# BEP-24: Improvements to Freeze Function

- [BEP-24: Improvements to Freeze Function](#bep-24-improvements-to-freeze-function)
  - [1. Summary](#1-summary)
  - [2. Abstract](#2-abstract)
  - [3. Status](#3-status)
  - [4. Motivation](#4-motivation)
  - [5. Specification](#5-specification)
    - [5.1 Transactions](#51-transactions)
      - [5.1.1 Freeze](#511-freeze)
      - [5.1.2 Unfreeze](#512-unfreeze)
      - [5.1.4 QueryBondPeriod](#514-querybondperiod)
      - [5.1.4 QueryUnlockTime](#514-queryunlocktime)
  - [6. License](#6-license)

## 1.  Summary 

This BEP describes an improvement for the [BEP9](https://github.com/binance-chain/BEPs/blob/master/BEP9.md) freeze feature of tokens on the Binance Chain.

## 2.  Abstract

BEP-24 Proposal describes functionality to improve freeze functionality of tokens on the Binance Chain:

+ **BondPeriod**: Freeze the token with a specified bond period for the token after which they can be claimed. 
+ **Unfreeze**: Unfreeze the tokens and begin the unbonding period. A second unfreeze call after tokens are unbonded is necessary to then claim. 
+ **QueryBondPeriod**: QueryBondPeriod will return the **bond period** of the token freeze. 
+ **QueryUnlockTime**: QueryUnlockTime will return the unlock time when the token begins unlocking. 

Difference to [BEP9](https://github.com/binance-chain/BEPs/blob/master/BEP9.md).

BEP9 refers to timelocking of tokens that can be reclaimed after a certain date.

BEP24 refers to how long the tokens take to unlock. The user can try to unfreeze *at any time* but it will begin a mandatory unbonding period, such as 30 days. This is more similar to the process of staking.

BEP24 can be built on the fundamentals of BEP9. Without BEP24, users will have to keep coming online to re-lock their tokens.


## 3.  Status

This BEP is under implementation.

## 4.  Motivation

Some dApps require token holders to perform certain actions in holding utility coins before unlocking features, such as freezing tokens for certain time periods.
For example, a dApp with a certain premium feature set may require token holders to freeze a certain quantity of tokens on their address for a minimum of 30 days (bond period). 

## 5.  Specification

###  5.1 Transactions

#### 5.1.1 Freeze

Freeze transactions can freeze tokens from the owner address for a specified bond period. Any address can freeze its own tokens. 

The existing fee (a fixed amount of BNB) will be charged on Freeze transactions.

**Parameters for Freeze Operation**:

| **Field**    | **Type** | **Description**                                              |
| :------------ | :-------- | :------------------------------------------------------------ |
| Description   | string  | Description of the freeze operation. Max length of description is 128 bytes. |
| Amount        | []Coin   | A set of tokens to be frozen |
| BondPeriod    | int64  | The time period for bonding in seconds. Max BondPeriod should be less than 315,360,000 (10 years). Default is 0.  
| UnlockTime     | int64 | Timestamp for when the tokens can be unlocked. Default is null if `BondPeriod==0`. |

Freeze transaction will transfer frozen tokens to a purely-code-controlled escrow account and will return a Frozen record id. No one can transfer the tokens out of the escrow account, unless the owner of the tokens successfully runs “UnFreeze” under the preset requirements.

#### 5.1.2 Unfreeze

Unfreeze transactions unlock tokens from a given Freeze record if `time.now() > UnlockTime && UnlockTime != 0`, or `BondPeriod==0`. 
If `time.now() < UnlockTime`, then Unfreeze transactions will apply the BondPeriod by setting Unfreeze to a timestamp that is `time.now() + BondPeriod`. 
Unfreeze will fail if the address is not the same as the tokens’ owner.

If a Unfreeze transaction succeeds, the locked tokens will be returned to the owner's account, and the related Freeze record will be deleted.

A fee (a fixed amount of BNB) will be charged on Unfreeze transactions.


**Parameters for Unfreeze Operation**:

| **Field**    | **Type** | **Description**                                              |
| :------------ | :-------- | :------------------------------------------------------------ |
| RecordId   | int64  | `Freeze` record id |


#### 5.1.3 QueryBondPeriod

QueryBondPeriod will return all BondPeriod records of a specific address.

#### 5.1.4 QueryUnlockTime

QueryUnlockTime will return UnlockTime record of a given Freeze record id of a specific address.

## 6. License

The content is licensed under [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
