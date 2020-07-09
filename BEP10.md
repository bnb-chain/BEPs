# BEP-10: Registered Types for Transaction Source

- [BEP-10: Registered Types for Transaction Source](#bep-10--registered-types-for-transaction-source)
  * [1. Summary](#1-summary)
  * [2. Abstract](#2-abstract)
  * [3.  Status](#3--status)
  * [4. Motivation](#4-motivation)
  * [5. Specification](#5-specification)
    + [5.1 Transaction Data Structure](#51-transaction-data-structure)
    + [5.2 Register Process](#52-register-process)
    + [5.3  Registered Source types](#53--registered-source-types)
  * [6. License](#6-license)

## 1. Summary

This BEP describes how to have a better understanding of the origin of a transaction with a special field in a transaction for recording its source.

## 2. Abstract

By adding a field in each transaction message, the origin of any transaction could be tracked.

## 3.  Status

This BEP is already implemented.

## 4. Motivation

Binance Chain is designed to connect with multiple service providers, such as different wallelt providers and trading platforms. By adding an optional field in each transaction message, the origin of any transaction could be tracked. This proposal does not want to deal with assigning the values for various source types. The different sources will claim different value and such a proposition will be assigned afterwards.

## 5. Specification

### 5.1 Transaction Data Structure

The transaction is a standard way to wrap a message with signatures.

| Field  | Type      | Description                           |
| ------ | --------- | ------------------------------------- |
| Msgs   | message   | transaction message                   |
| Sig    | signature | signatures from the  account holder   |
| Memo   | string    | some notes come with the transaction  |
| Source | int64     | where does this transaction come from |
| Data   | byte[]    | transaction data                      |

### 5.2 Register Process

- Service Provider choose their own source identifier
- They have to create a PR to BEP-10 and add their identifier code in the form under section **5.3**
- Maintainer review their PR
- If the PR gets accepted, this new identifier will be recognized

### 5.3  Registered Source types

These are the registered source types.

All of these constant values shall be considered hardcoded in client implementations.



| Identifier | Source Description           |
| ---------- | ---------------------------- |
| 0          | Default source value, e.g. for Binance Chain Command Line, or SDKs   |
| 1          | Binance DEX Web Wallet       |
| 2          | Trust Wallet                 |
| 3          | CanWork.io Decentralised [Serviceplace App](https://github.com/canyacoin/canwork-web-ui)|
| 4          | CanYaDAO [Decentralised Autonomous Organisation](https://github.com/canyacoin/canyadao)|
| 5          | Math Wallet                 |
| 6          | SafePal [Secure, simple, powerful hardware wallet for the masses](https://www.safepal.io)|
| 7          | GoBNB [GoBNB Payments App](https://github.com/gobnb/)
| 8          | [Magnum Wallet](https://magnumwallet.co)|
| 9          | [Atomic Wallet](https://atomicwallet.io)|
| 10         | [Equal Wallet](https://equal.tech/)|
| 11         | [Infinito Wallet](https://www.infinitowallet.io/)|
| 12         | Coinomi|
| 18         | MEET.ONE [Blockchain Wallet Supports Binance DEX](https://meet.one)|
| 21         | Vision - [Portfolio & Multi-Chain Wallet](https://vision-crypto.com/)|
| 68         | Trubi Wallet|
| 82         | [Cosmostation Wallet](https://www.cosmostation.io)|
| 91         | [Frontier Wallet](https://frontierwallet.com/) |
| 711        | [CoolWallet S](https://coolwallet.io/)|
| 714        | Binance|
| 777        | Guarda Wallet [Multi-currency, custody-free wallet](https://guarda.co/)
| 888        | TrustToken: [Cross-chain, multi-currency fiat onramp+offramp](https://app.trusttoken.com)|
| 999        | [TokenPocket Wallet](https://www.tokenpocket.pro/)|
| 1014       | Binance OCBS service|
| 1035       | Trubi Token Swap service|
| 2048       | BNB Browser: [Metamask like wallet for BNB](https://chrome.google.com/webstore/detail/bnb-browser/eeflaanifildahldmpahjmgmgippmgne?hl=en)|
| 800,000,000 ~ 1,600,000,000| reserved source code|


## 6. License

The content is licensed under [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
