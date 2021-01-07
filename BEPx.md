# BEPX: Token Symbol Minimum Length Change

## 1. Summary
This BEP proposes to reduce the minimum length limit for token symbol on Binance Chain

## 2. Abstract
Currently, the token symbol minimum length is limited to 3. After implementing this BEP, the users are allowed to issue a token with a symbol of 2 characters.

## 3. Status
draft

## 4. Motivation
As many users have the requirements to issue a two-character token on Binance Chain, the minimum token symbol length will be changed to 2 in this BEP.

## 5. Specification

### Length Changes
When the issuer sends an issue transaction for issuing BEP2/BEP8 token, the token symbol length must be between 2-8. Here is the comparison of the length check below:

| **Token Type** | **Length Check(Before)** | **Length Check(After)** |
| :------------- | :----------------------- | :---------------------- |
| BEP2 | 3-8 | 2-8 |
| BEP8 | 3-8 | 2-8 |

After the implementation of this BEP, the token symbol length of Binance Chain would be between 2 and 8.

## 6. License

The content is licensed under [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

