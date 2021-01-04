# BEP88: Compensate BSC Relayers

## Summary

This BEP proposes a reward mechanism to balance the gain and risk for BSC relayers, which will attract more relayers to engage in and improve the cross chain communication robustness between BC and BSC.

## Abstract

Now all bsc-relayers are suffering from BNB loss in relaying cross chain packages from BC to BSC. Besides, it would not be helpful to community development if common users have to pay more relay fees. To compensate relayers and avoid additional burden to common users, some extra reward will be granted to bsc-relayers from the SystemReward contract.

## Status

This BEP is under implementation.

## Motivation

Anyone can maintain a bsc-relayer by depositing 100:BNB to the RelayerHub contract. If the relay reward can cover the relay cost, then more and more people will maintain their own bsc-relayer, which will improve the robustness of the cross chain communication between BC and BSC. Otherwise, no one is willing to maintain a bsc-relayer. Thus the communication between the BC and the BSC will be blocked. 

## Specificaion

### Governable Parameter
Import a governable parameter `extraRelayerReward` to the `RelayerIncentivize` contract:
1. The `extraRelayerReward` represents the amount of BNB which will be transferred from the SystemReward to the relayer reward pool.
2. The `extraRelayerReward` can be modified by sidechain governance on BC.

### Modify RelayerIncentivize Contract
Modify the `addReward` method in the RelayerIncentivize contract:
1. Try to claim `extraRelayerReward` from the SystemReward contract.
2. Add the new claimed reward to the existing reward.
3. Add the total reward to the relayer reward pool.

## License
All the content is licensed under [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
