# BEPs

****

> **Mirror**
> This repo mirrors from Gitlab to Github. Please commit to the Gitlab repo:
> https://gitlab.com/canyacoin/binancechain/beps

****

BEP stands for Binance Chain Evolution Proposal. Each BEP will be a proposal document providing information to the Binance Chain/DEX community. 


# CanYa Submissions

The CanYa Team will be working on a number of Binance Tech Modules. You can read about them here: [Proposed Binance Tech Modules](https://gitlab.com/canyacoin/binancechain/beps/blob/ece6cf363a9e040271e939f24967824c552b40f8/BinanceTechModules.pdf)


### 1) NON-INTERACTIVE MULTI-SIGNATURE MODULE
This module using Cosmos multi-key store to persist state about the wallets on-chain and is non-interactive since signers don’t need to be online at the same time. 
Signatures and public keys are recorded on-chain, as opposed to off-chain. This functions similar to Ethereum’s Gnosis Multi-sig contract, where the wallet is set up first before it can be used.


### 2) ESCROW MODULE
This module is a simple escrow module that allows members to register funds in an escrow that must be paid out in accordance with the set up. It is an adapted non-interactive multi-signature module that places enforceable restrictions on how the transaction is paid out. 


### 3) HEDGED ESCROW MODULE
This module implements a price hedge into the escrow so that an external value can be specified in the payment and the payout correctly paid at all times. This allows escrows to pay out funds in an externally priced asset (such as paying BNB for a transaction that is priced in USD) and removes volatility risks to escrows. The hedged escrow has already been implemented successfully in the CanWork platform. 


### 4) DAO MODULE
This module is a simple staking, election and voting module that allows members to stake assets that can only be unlocked after a period of time, start elections in communities and cast votes that represent on-chain governance.


### 5) CONTINUOUS LIQUIDITY POOL MODULE
This module allows users to stake assets and BNB in on-chain pools, and then perform trustless swaps across pools. 
The module features always-on liquidity and fair market-based prices that are resistant to manipulation. 
Stakers earn fees when staking assets, and users can instantly swap assets in a single transaction. 
This module is exciting because it will drive staking demand for BNB and BinanceChain assets, and solve liquidity problems for the ecosystem since it has the correct incentives to stake assets and earn fees. Developers can add a swap widget in their apps to instantly convert assets at market prices trustlessly with no counter-party.

