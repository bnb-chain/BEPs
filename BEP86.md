# BEP-86: Dynamic Extra Incentive To BSC Relayers

- [BEP-86: Dynamic Extra Incentive To BSC Relayers](#bep-86-dynamic-extra-incentive-to-bsc-relayers)
  - [1. Summary](#1-summary)
  - [2. Abstract](#2-abstract)
  - [3. Status](#3-status)
  - [4. Motivation](#4-motivation)
  - [5. Specification](#5-specification)
    - [5.1 Governable Parameter](#51-governable-parameter)
    - [5.2 Modify RelayerIncentivize Contract](#52-modify-relayerincentivize-contract)
  - [6. License](#6-license)
  
## 1. Summary

This BEP proposes a reward mechanism to balance the gain and risk for BSC relayers, which will attract more relayers to engage in and improve the cross chain communication robustness between BC and BSC.

## 2. Abstract

Now all bsc-relayers are suffering from BNB loss in relaying cross chain packages from BC to BSC. Besides, it would not be helpful to community development if common users have to pay more relay fees. To compensate relayers and avoid additional burden to common users, some dynamic extra reward will be granted to bsc-relayers from the [SystemReward Contract](https://github.com/binance-chain/bsc-genesis-contract/blob/master/contracts/SystemReward.sol).

## 3. Status

This BEP is under implementation.

## 4. Motivation

Anyone can maintain a bsc-relayer by depositing 100:BNB to the RelayerHub contract. If the relay reward can cover the relay cost, then more and more people will maintain their own bsc-relayer, which will improve the robustness of the cross chain communication between BC and BSC. Otherwise, no one is willing to maintain a bsc-relayer. Thus the communication between the BC and the BSC will be blocked. 

## 5. Specification

### 5.1 Governable Parameter
Import a governable parameter `extraRelayerReward` to the [RelayerIncentivize Contract](https://github.com/binance-chain/bsc-genesis-contract/blob/master/contracts/RelayerIncentivize.sol):
1. The `extraRelayerReward` represents the amount of BNB which will be transferred from the SystemReward to the bsc relayer reward pool.
2. The `extraRelayerReward` can be modified by sidechain governance on BC.

### 5.2 Modify RelayerIncentivize Contract
Modify the `addReward` method in the RelayerIncentivize contract:
1. Try to claim `extraRelayerReward` from the SystemReward contract.
2. Add the new claimed reward to the existing reward.
3. Add the total reward to the relayer reward pool.

## 6. License
All the content is licensed under [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
