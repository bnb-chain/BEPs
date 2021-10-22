# BEP-95: Introduce Real-Time Burning Mechanism

- [BEP-95: Introduce Real-Time Burning Mechanism](#bep-95-introduce-real-time-burning-mechanism)
    - [1. Summary](#1-summary)
    - [2. Abstract](#2-abstract)
    - [3. Status](#3-status)
    - [4. Motivation](#4-motivation)
    - [5. Specification](#5-specification)
    - [6. License](#6-license)

## 1. Summary

This BEP introduces a real-time burning mechanism into the economic model of BSC.

## 2. Abstract

To speed up the burning process of BNB and make BSC more decentralized, part of the gas fee will be burned. It includes two parts:

+ A fixed ratio of the gas fee collected by the validators will be burned in each block.
+ The burning ratio can be governed by the BSC validators.


## 3. Status

This BEP is a draft.

## 4. Motivation

The burning of gas fees can speed up the burning process of BNB and improve the intrinsic value of BNB.

The BNB holders will decide how to dispatch the gas reward of BSC.

Though the staking reward of the validators and delegators may decrease in BNB amount, the reward value in dollars may increase in the long run with the increase of BNB value and a more active ecosystem.

## 5. Specification

### 5.1 Gas Fee Distribution

As BNB is not an inflationary token, there will be no mining rewards as what Bitcoin and Ethereum networks generate, and the gas fee is the major reward for validators. As BNB is also utility tokens with other use cases, delegators and validators will still enjoy other benefits of holding BNB. The gas fee is collected each block and distributed to two system smart contracts:

1. [System Reward Contract](https://bscscan.com/address/0x0000000000000000000000000000000000001002). The contract can possess at most 100 BNB. 1/16 of the gas fee will be transferred to the system reward contract if it possesses less than 100 BNB. The funding within the reward contract is used as cross-chain package subsidies.
2. [ValidatorSet Contract](https://bscscan.com/address/0x0000000000000000000000000000000000001000). The rest of the gas fee is transferred to the ValidatorSet contract. It is the vault to keep gas fees for both validators and delegators. The funding within the contract will be transferred to Binance Chain and distributed to delegators and validators according to their shares every day.

### 5.2 Burning Mechanism

A governable parameters: `burnRatio` will be introduced in the [ValidatorSet Contract](https://bscscan.com/address/0x0000000000000000000000000000000000001000). At the end of each block, the Validator will sign a transaction to invoke the `deposit` function of the contract to transfer the gas fee. The burning logic is implemented within the `deposit` function that:  `burnRatio` * `gasFee` will be transferred to the [burn address](https://bscscan.com/address/0x000000000000000000000000000000000000dead);

The initial setting:

+ burnRatio = 10%

### 5.3 Governance

The change of `burnRatio` will be determined by BSC Validators together through a proposal-vote process based on their staking.

This process will be carried on Binance Chain, every community member can propose a change of the params. The proposal needs to receive a minimum deposit of BNB (2000BNB on mainnet for now, refundable after the proposal has passed) so that the validator can vote for it. The validators of BSC can vote for it or against it based on their staking amount of BNB.

If the total voting power of bounded validators that votes for it reaches the quorum(50% on mainnet), the proposal will pass and the corresponding change of the params will be passed onto BSC via cross-chain communication and take effect immediately. The vote of unbounded validators will not be considered into the tally.


## 6. License

The content is licensed under [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
