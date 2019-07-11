# BEP-9: Time Locking of Tokens

- [BEP-9: Time Locking of Tokens](#bep-9-time-locking-of-tokens)
  - [1. Summary](#1-summary)
  - [2. Abstract](#2-abstract)
  - [3. Status](#3-status)
  - [4. Motivation](#4-motivation)
  - [5. Specification](#5-specification)
    - [5.1 Transactions](#51-transactions)
      - [5.1.1 TimeLock](#511-timelock)
      - [5.1.2 TimeUnlock](#512-timeunlock)
      - [5.1.3 TimeRelock](#513-timerelock)
      - [5.1.4 QueryTimeLocks](#514-querytimelocks)
      - [5.1.4 QueryTimeLock](#514-querytimelock)
  - [6. License](#6-license)

## 1.  Summary

This BEP describes a proposal for a time-locking feature of tokens on the Binance Chain.

## 2.  Abstract

BEP-9 Proposal describes functionality to time-lock tokens on the Binance Chain. Such as:

+ TimeLock: TimeLock will transfer locked tokens to a purely-code-controlled escrow account and before the lock time expires, the specific user will not be able to claim them back, including restrictions where they cannot use, transfer or spend these tokens.
+ TimeUnlock: TimeUnlock will claim the locked tokens back when the specified lock time has passed.
+ TimeRelock: TimeRelock can extend lock times, increase the amount of locked tokens or modify the description of an existing lock record.
+ QueryTimeLocks: QueryTimeLocks will query all lock records of a given address.
+ QueryTimeLock: QueryTimeLock will query a lock record of a given address.


## 3.  Status

This BEP is already implemented.

## 4.  Motivation

Some business plans decide to lock certain amount tokens for pre-defined periods of time, and only vest in the future according to the schedules.
For example, some projects may lock some allocation of the issued tokens as a commitment by the founding team; some business scenarios also need to lock some tokens as collateral for value.

## 5.  Specification

###  5.1 Transactions

#### 5.1.1 TimeLock

TimeLock transactions can lock tokens from the owner address for a specified time period. Any address can TimeLock its own tokens.

A fee (a fixed amount of BNB) will be charged on TimeLock transactions.

**Parameters for TimeLock Operation**:

| **Field**    | **Type** | **Description**                                              |
| :------------ | :-------- | :------------------------------------------------------------ |
| Description   | string  | Description of the lock operation. Max length of description is 128 bytes. |
| Amount        | []Coin   | A set of tokens to be locked |
| LockTime      | int64  | The time when these tokens can be unlocked. LockTime is a future timestamp(seconds elapsed from January 1st, 1970 at UTC) and max LockTime should be before 10 years from now.  |

TimeLock transaction will transfer locked tokens to a purely-code-controlled escrow account and will return a TimeLock record id. No one can transfer the tokens out of the escrow account, unless the owner of the tokens successfully runs “TimeUnlock” under the preset requirements.

#### 5.1.2 TimeUnlock

TimeUnlock transactions unlock tokens from a given TimeLock record. TimeUnlock transactions will fail if the operation time is prior to the LockTime specified in the respective TimeLock transaction or if the address is not the same as the tokens’ owner.

If a TimeUnlock transaction succeeds, the locked tokens will be returned to the owner's account, and the related TimeLock record will be deleted.

A fee (a fixed amount of BNB) will be charged on TimeUnlock transactions.


**Parameters for TimeUnlock Operation**:

| **Field**    | **Type** | **Description**                                              |
| :------------ | :-------- | :------------------------------------------------------------ |
| RecordId   | int64  | `TimeLock` record id |

#### 5.1.3 TimeRelock

TimeRelock transactions update the amount of locked tokens or the lock time of a given TimeLock record. But users can only increase the amount of locked tokens and/or increase the lock time only.

A fee (a fixed amount of BNB) will be charged on TimeRelock transactions.


**Parameters for TimeRelock Operation**:

| **Field**    | **Type** | **Description**                                              |
| :------------ | :-------- | :------------------------------------------------------------ |
| RecordId    | int64  | `TimeLock` record id |
| Description   | string  | Description of the lock transaction. If Description is empty, this operation will not change description of TimeLock record. Max length of description is 128 bytes. |
| IncreaseAmountTo      | []Coin  | A set of tokens to be locked. If IncreaseAmountTo is empty, this operation will not change the amount in the TimeLock record. If Amount is not empty, amount should be more than the original amount. |
| ExtendedLockTime      | int64  | Time when these tokens can be unlocked. If ExtendedLockTime is zero, this operation will not change lock time of TimeLock record. If ExtendedLockTime is not zero, it should be after the original lock time. LockTime is a future timestamp and max LockTime should be before 10 years from now. |

#### 5.1.4 QueryTimeLocks

QueryTimeLocks will return all TimeLock records of a specific address.

#### 5.1.4 QueryTimeLock

QueryTimeLock will return TimeLock record of a given TimeLock record id of a specific address.

## 6. License

The content is licensed under [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
