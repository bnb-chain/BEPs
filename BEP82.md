# BEP-82: Token Ownership Changes

## 1. Summary
This BEP describes the changes related to the token owner who issued a token on Binance Chain.

## 2. Abstract
Currently, many token-related transactions, such as token listing, minting, burning, etc., can only be proposed by the token owner who can not be changed once the token is issued on Binance Chain.

This BEP proposes the solutions to provide more convenience and flexibility for these transactions.

## 3. Status
This BEP is already implemented

## 4. Motivation
To reduce the transaction's dependence on the related token’s owner and make the ownership of token changeable, we introduce those solutions as following:
- Providing an entrance to transfer the ownership of a specific token.
- Removing the owner verification when handling some token related transactions.

## 5. Specification
### 5.1 Transfer Ownership
**TransferOwnership** transaction can transfer ownership of a specific token to another address, and only the original owner has the permission to send this transaction.

A fee (a fixed amount of BNB) will be charged on **TransferOwnership** transactions.

Parameters for TransferOwnership Operation:

|     **Field**       | **Type**    |    **Description**        |
| ------------------- | ----------- | ------------------------  |
| From                | string      | the address who wants to transfer the ownership to another address |
| Symbol              | string      | the token symbol needs to be transferred ownership |
| NewOwner            | string      | the address who is assigned to be the new owner of the token |

### 5.2 Token Owner Verification Changes
Currently, some token-related transactions are restricted to being proposed by token owners while others are not.  After the implementation of this BEP, any address can burn its own tokens. Here is the comparison below:

|    **Transaction Type**   |  **Verify Owner(Before)** |  **Verify Owner(After)**  |
| ------------------------- | ------------------------- |---------------------------|
| list token                | yes                       | yes                       |
| mint token                | yes                       | yes                       |
| burn token                | yes                       | no                        |
| freeze token              | no                        | no                        |
| set URI                   | yes                       | yes                       |
| atomic swap related       | no                        | no                        |
| time lock                 | no                        | no                        |
| time unlock               | no                        | no                        |
| time relock               | no                        | no                        |
| transfer                  | no                        | no                        |
| cross transfer out        | no                        | no                        |
| cross bind                | yes                       | yes                       |
| cross unbind              | yes                       | yes                       |


## 6. License
The content is licensed under [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

