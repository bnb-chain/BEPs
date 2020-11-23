
# BEP-81: Tokenized Fee Service Layer For Binance Chain

- [Tokenized Fee Service Layer For Binance Chain](#bep-71-smart-contract-execution-fee)
  - [1. Summary](#1-summary)
  - [2. Abstract](#2-abstract)
  - [3. Status](#3-status)
  - [4. Motivation](#4-motivation)
  - [5. Specification](#5-specification)
    - [5.1 Transactions](#51-transactions)
      - [5.1.1 How it works](#511-confirmation_transaction)
      - [5.1.2 ExecuteByFee](#512-get_transaction)
      - [5.1.3 SignedHash](#513-submit_transaction)
 

## 1.  Summary

This BEP describes a proposal for executing smart contract functions by paying Tokens instead of BNB on the Binance Chain.

## 2.  Abstract

This BEP describes a proposal to improve the properties of BEP20 on Binance chain to pay tokens for transactions instead of gas (BNB) to execute the smart contract function.

## 3.  Status

This BEP is already implemented.

## 4.  Motivation

If a first-party token owner generates a transaction by improving the properties of BEP20 on Binance chain, the BEP delegates the Transaction Gas Fee (BNB) to a third party to transfer the token, paying for the gas and receiving a fee in token.
The owner who issued the token prefers to form the token economic and utility by paying transaction fees with the issued token. Current BEP20 tokens cannot pay fees with token itself, so token holders must have a separate gas (BNB). In order to improve this problem, if the token owner is referred to as a third party, the token owner pays gas cost (BNB) and the third party receives the token.
The structure above is the same as the exchange of classical finance, and the token infrastructure can be analyzed through the exchange rate.
CenterPrime Project's following proposal is to propose a BEP for “Token Infrastructure Analysis via Token Return Rate”.

## 5.  Specification

###  5.1 Transactions

#### 5.1.1 How It works

-   A: Sender Address
-   B: Receiver Addres
-   X: Token amount (from A to B)
-   Y: Fee Token amount for Transaction fee
-   T: Token to send
-   N: Nonce
-   O: Owner, doing the transaction for A, and paying for the gas.

**A** user with his private key generates  **{V,R,S}**  for the  **sha3**  of the payload  **P**  {N,A,B,D,X,Y,T}.

The user sends  **{V,R,S}**  and  **P**  (unhashed, unsigned) to the delegate.

The delegate verifies that  **Y**  and  **O**  have not been altered.

The delegate proceeds to submit the transaction from his account  **O**:

```
T.executeByFee(N,A,B,X,Y,V,R,S)

```

The  _executeByFee_  method reconstructs the sha3  **H**  of the payload  **P**  (where  **T**  is the address of the current contract and  **O**  is the  _msg.sender_).

We can then call  _ecrecover(H, V, R, S)_, make sure that the result matches  **A**, and if that’s the case, safely move  **X**  tokens from  **A**  to  **B**  and  **Y**  tokens from  **A**  to  **O**.

#### 5.1.2 ExecuteByFee

**executeByFee**  function parameters and submitting transaction.

**Parameters for ExecuteByFee Operation**:

| **Field**    | **Type** | **Description**                                              |
| :------------ | :-------- | :------------------------------------------------------------ |
| _signature   | bytes  | The signature, issued by the owner |
| _to   | address  | The address which you want to transfer to |
| _value   | uint256  | The amount of tokens to be transferred |
| _fee   | uint256  | The amount of tokens paid to msg.sender, by the owner |
| _nonce   | uint256  | Presigned transaction number. Should be unique, per user. |

```
function executeByFee(
    bytes _signature,
    address _to,
    uint256 _value,
    uint256 _fee,
    uint256 _nonce
)
    public
    returns (bool);
```

#### 5.1.3 SignedHash

SignedHash function return Hash (keccak256) of the payload used by **executeByFee**

**Parameters for SignedHash Operation**:

| **Field**    | **Type** | **Description**                                              |
| :------------ | :-------- | :------------------------------------------------------------ |
| _token   | address  | The address of the token |
| _to   | address  | The address which you want to transfer to |
| _value   | uint256  | The amount of tokens to be transferred |
| _fee   | uint256  | The amount of tokens paid to msg.sender, by the owner |
| _nonce   | uint256  | Presigned transaction number. |

```
function signedHash(
        address _token,
        address _to,
        uint256 _value,
        uint256 _fee,
        uint256 _nonce
    )
        public
        pure
        returns (bytes32)
    {
         return keccak256(bytes4(0x48664c16), _token, _to, _value, _fee, _nonce);
    }
```
