# BEP3: HTLC and Atomic Peg

# Summary

This BEP is about introducing Hash Timer Locked Contract functions and further mechanism to handle inter-blockchain token peg.

# Abstract

[HTLC](https://en.bitcoin.it/wiki/Hash_Time_Locked_Contracts) has been used for Atomic Swap and cross payment channel for a few years on Bitcoin and its variant blockchains, and also Ethereum. This BEP defines native transactions to support HTLC on Binance Chain, and also proposes the standard infrastructure and procedure to use HTLC for inter-chain atomic swap to easily create and use pegged token, which is called `Atomic Peg`.

# Status

DRAFT

# Motivation

Binance Chain serves fast transferring transactions and also high capacity asset Exchange, which have benefits a lot assets issues on it. However, there are major cases Binance Chain itself cannot satisfy:

1. Assets have complicated token economies themselves, such as DeFi.
2. Assets serve as native tokens on other blockchain.

For these tokens, the best way to use Binance Chain is to spread the tokens on multiple chains. One can issue or peg part of total token supply on Binance Chain to enjoy the speed, fast finality and powerful exchange, meanwhile keep other benefit and necessity on other chains. Many new requirements are imposed for such model:

1. there should be easy way for users to swap unidirectionally or bidirectionally between Binance Chain and the other chain, better in a trustless way;
2. there should be restrictions and/or transparency to ensure the total supply of tokens remained the same, and no one, even the issuer cannot freely change the circulation at will;
3. there should be easy way to calculate how many tokens are in circulation on each chain of both sides.

Here new transaction and logics are required on Binance Chain, as it doesn’t support Smart Contract. Also a standard infrastructure and procedure should be proposed and used as best practice for such inter-chain communications.

The BEP is to tackle the problem, and try to pave the broadway for a practical cross chain solution to empower the decentralized economy with Binance DEX.

# Specification

## Atomic Peg Swap

The primary purpose of HTLC in Binance Chain is to support Atomic Peg Swap (APS). APS is proposed here as the standard way for asset/token issuers to peg or migrate part of the asset/token onto Binance Chain, so that users of the tokens can enjoy the fast transactions and pleasant trading experience.

APS is designed to support peg token from any EVM based blockchain or any one with full smart contract features. Here in order to simplify the description, Ethereum is used as the most typical example.

### Roles

*   **Client**: users that who want to swap tokens from Ethereum to Binance Chain, or the other way round;
*   **Owner**: the issuers or anyone who want to peg the tokens from Ethereum to Binance Chain. In most cases, the Owner should be the issuer of the token. There expects one or multiple Owners to provide some service for one blockchain/project, depending on the size of the blockchain/project. 

### Infrastructure Components

*   **New transaction types on Binance Chain**: HTLT and CHLT transactions are used to lock and claim the asset to swap. The details are covered in the following section.
*   **Swap smart contracts on Ethereum**: the APS contract are used to lock and claim the asset to swap too. The function should be similar to the new transaction types on Binance Chain. The details of interface covered in the following section.
*   **Deputy process**: an application run and maintained by Owner to facilitate the automatic and continuous swap activity.
*   **Client tooling**: wallets or other tools that help Clients to monitor the blockchains to complete the claim (and maybe the lock as well).

### Protocol

The protocol is the execution of 

#### Preparation Stage

1. Owner should issue proper number of tokens on Binance Chain as the Pegged 
2. Owner should create one address on Binance Chain (as OB in the below diagram), and transfer in enough number of tokens for swap
3. Owner should deploy the APS Ethereum smart contract on Ethereum, and deposit enough number of tokens for swap into a dedicated address (which both should be public announced).
4. Client should have an address on both Binance Chain (CB) and Ethereum (CE).
5. For such swap, Owner should publish all their OB and APS contract address, and also the expected minimum time span, MinLockTime.

#### Usage Expectation and Benefits

1. It is expected that each issuer of the pegged token should set up their own Deputy Process, or rely on 3rd party custodian service providers to manage one.
2. Via the public balance of OB and APS contract, everyone can check the total pegged token swapped, and ensure the total supply stays clear in the same way as if the token is not pegged
3. Client gets guarantee on their fund safety. They don’t need to worry too much about the availability of the Deputy process, or any cheat from issuers or swap service providers.
4. It is possible for one set of infrastructure to handle swap for multiple tokens.

#### Client Swap Tokens from Ethereum to Binance Chain

1. Client calls APS contract, with the hash of a secret, X tokens and a time span T parameters, to express his/her interest to swap X tokens. If the parameters are good (e.g. T>MinLockTime, enough tokens to swap), the call transaction is recorded on the blockchain.
2. Deputy process monitors the events of the APS contract on Ethereum. If it detects the client’s call and verify good, it will sign and broadcast the HTLT transaction on Binance Chain. This will lock X (or more as bonus) number of pegged tokens on Binance Chain. Please note the time span used in this HTLT transaction should be smaller enough than T in Client’s APS call.
3. Client or Client tooling monitors any transactions onto CB, if it is from OB and has the proper hash, Client or Client tooling should broadcast CHLT transaction to claim his/her requested Pegged tokens by disclosing the random number generating the hash. Binance Chain will verify the random number, if it matches the hash, it will release the locked Pegged tokens to Client address CB.
4. Deputy process monitors the transactions onto OB. If there is a success CHLT, it will read the value of the random number Client disclosed, and call APS contract to claim the locked tokens by Client.

#### Client Swap Tokens from Binance to Ethereum

1. Client sends HTLT transaction to Owner address OB with the hash of a secret, X tokens and a time span T parameters, to express his/her interest to swap X tokens. If the parameter is good, the transaction will be recorded on Binance Chain.
2. Deputy Process monitors the transactions onto OB. If there is a success HTLT, it will double verify the transaction parameters (e.g. T>MinLockTime, enough tokens to swap). If all are good, it will call the APS contract on Ethereum to lock X number of tokens on Ethereum with the hash with shorter time span, expecting to be unlocked by Client address CE.
3. Client or Client tooling monitors events of the APS contract on Ethereum. If it detects Deputy process’s call, it will verify and call the APS contract to claim the tokens by disclosing the random number generating the hash.
4. Deputy process monitors the events from APS contract. If there is a successful claim, it will read the value of the random number Client disclosed and broadcast a CHLT transaction to claim the locked tokens by the Client via the HTLT.

#### Client Tooling

Client Tooling is the part to help user experience. While the most commonly used tools are wallets, command line interfaces and programming SDKs, wallets are the most critical part. The wallet is expected to handle the below part to facilitate the swap, which can be challenging to the existing wallets to call the specific smart contract.

1. start the request of Atomic Peg on either chain of the two, which means sign and broadcast specific transactions, or trigger smart contract with parameters;
2. monitor the blockchain and automatically claim the swapped token (or automatically trigger the refund after the timeout on Ethereum and other blockchains).
3. if the wallet supports multiple blockchain, e.g. both Binance Chain and Ethereum, it will be super convenient for Client to complete the whole swap process within the wallet.

## New Transaction Types on Binance Chain

The below are the details for HTLT and CHLT.

### Hash Timer Locked Transfer

Hash Timer Locked Transfer (HTLT) is a new transaction type on Binance Chain, to serve as HTLC in the first step of Atomic Swap, with parameters defined as the below:

| Name | Type | Description | Optional |
| -----| ---- | ----------- | -------- |
| From | Address | Sender address, where the asset is from | No| 
| To | Address | Receiver address, where the asset is to, if the proper condition meets. This address must be flagged with HTLT flag in order to claim the transfer to be fully done once the hashed secret is disclosed by Sender. | No | 
| ToOnOtherChain  | bytes   | an byte array, maximum 32 bytes, in any proper encoding | No            | 
| Random Number Hash | 32 bytes   | Sender address, where the asset is from | No | 
| Coins | []Coin   |similar to the Coins in the original Transfer defined in BEP2| No | 
| TimeSpan | int64   | number of blocks to wait before the asset may be returned to From if not claimed via Random. The number must be larger than or equal to 360 (>2 minutes), and smaller than 518400 (>48 hours) | No | 

Before the above `To` claims the transferred Coins with the correct random number that can generate the same Random Hash, the Coins will not appear as balance on `To` address. The transaction is signed by private key for `From` address.


### Claim Hash Timer Locked 

Claim Hash Timer Locked (CHTL) is to claim the locked asset by showing the Random Number value that matches the hash. Each HTLT locked asset is guaranteed to be release once.

| Name | Type | Description | Optional |
| -----| ---- | ----------- | -------- |
| From | Address | Sender address, where the asset is from | No| 
| Random Number Hash | 32 bytes   | Sender address, where the asset is from | No |
| transaction hash | bytes | the hash of HTLT transaction that locked the asset | No| 

## APS Smart Contract Interface for Other Blockchain

### Transaction interfaces

1. function **initiateSwap**(bytes32 _swapID, bytes32 _secretHashLock, uint256 _timelock, address _traderAddr, address _BEP2Addr, uint256 _amount)
    1. client transfer tokens to swap contract
    2. emit SwapInitialization event
2. function **refund**(bytes32 _swapID)
    1. only accessible when timelock is expired
    2. unlock the received token and refund to swap initializer address
    3. emit SwapExpire event
3. function **claim**(bytes32 _swapID, bytes32 _secretKey)
    1. timelock must not be expired
    2. verify the secretKey against secretHashLock
    3. transfer token from swap contract to trader address
    4. emit SwapCompletion event

### Query interfaces

1. function **querySecret**(bytes32 _swapID) returns(bytes32)
2. function **swapID**(bytes32 _secretHashLock, uint256 _timelock) returns (bytes32)
3. function **initiatable**(bytes32 _swapID) return (bool)
4. function **refundable**(bytes32 _swapID) returns (bool)
5. function **claimable**(bytes32 _swapID) returns (bool)

### Event

1. event **SwapInitialization**(bytes32 _swapID, bytes32 _secretHashLock, uint256 _timelock, address _traderAddr, uint256 _amount);
2. event **SwapExpire**(bytes32 _swapID);
3. event **SwapCompletion**(bytes32 _swapID, bytes32 _secretKey);

## License

The content is licensed under [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
