# BEP-4: 256-bit Tokens

- [BEP-4: Improved Tokens on Binance Chain](#bep-4-256-bit-tokens)
  * [1.  Summary](#1--summary)
  * [2.  Abstract](#2--abstract)
  * [3.  Status](#3--status)
  * [4.  Motivation](#4--motivation)
  * [5.  Specification](#5--specification)
    + [5.1  Drop signed integers in favor of unsigned integers](#51--drop-signed-integers-in-favor-of-unsigned-integers)
    + [5.2  Extend existing balances, amounts, and supplies to 256 bits](#52--extend-existing-balances-amounts-and-supplies-to-256-bits)
    + [5.3  Modified Token Properties](#53--modified-token-properties)
    + [5.4  Modified Token Operations](#54--modified-token-operations)
    + [5.5  Modified Exchange Operations](#55--modified-exchange-operations)
  * [6.  License](#6--license)

## 1.  Summary

This BEP describes a proposal for increasing the size of the balances and supply fields for BEP2 tokens.

## 2.  Abstract

Increasing the bits in Supply and Amount bits from 63 to 256 improves precision and supply cap.
Backwards compatibility is protected by differentiating message types.

## 3.  Status

This BEP is a WIP. 

## 4.  Motivation

The int64 type used in BEP2 is insufficient to handle existing use cases.
For example, Tether currently has a supply of 2,834,358,182.
To support redemption precise to one cent, Tether would need to issue 100 tokens per dollar.
However, the base unit for issuance and redemption is 1e8, or 100,000,000.
With just 63 bits, the maximium number of tokens Tether could issue is 90,000,000,000, or 900,000,000 dollars.
Because Binance Chain cannot handle even a third of Tether's existing supply, it should improve its token capacity.
Ethereum uses 256 bits for its word size, and several tokens Binance Chain would like to support would be from Ethereum.
While 128 bits would satisfy the immediate concern, supporting 256 bits would reduce the likelihood Binance Chain would need to increase the entropy again.

## 5.  Specification

### 5.1  Drop signed integers in favor of unsigned integers.
For ERC20 tokens, balance, supply, and amount are unsigned.
This is because there is no meaning to a negative balance, or a negative supply.
Already, one cannot transfer a negative amount.
One cannot transfer more tokens than they have, and cannot have a negative balance.
The total supply cannot be negative.
The possibility of negative numbers is a waste of entropy, because everywhere we are concerned 

### 5.2  Extend existing balances, amounts, and supplies to 256 bits
Existing balances and supplies will be extended to 256 bits at the upgrade block.
Orders may remain unchanged.

### 5.3  Modified Token Properties
* Balance: Balance of token holder
* Total Supply: Total supply will be the total number of issued tokens. 

### 5.4  Modified Token Operations
The `Amount` field of the following operations changes to `uint256`.

* Issue Tokens
* Transfer Tokens
* Freeze Tokens
* Unfreeze Tokens
* Mint Tokens
* Burn Tokens

These messages will need new object type encodings so they are not ambiguous with existing operations.

### 5.5  Modified Exchange Operations
Currently, no exchange operations seem to need modification.

## 6.  License

The content is licensed under [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
