# BEP-99: Temporary Maintenance Mode for Validators

- [BEP-99: Temporary Maintenance Mode for Validators](#bep-99-temporary-maintenance-mode-for-validators)
    - [1. Summary](#1-summary)
    - [2. Abstract](#2-abstract)
    - [3. Status](#3-status)
    - [4. Motivation](#4-motivation)
    - [5. Specification](#5-specification)
    - [6. License](#6-license)

## 1. Summary

This BEP introduces the Temporary Maintenance mode for validators on the Binance Smart Chain.

## 2. Abstract

Temporary Maintenance is supposed to last a few minutes to one hour.  

The validator seat will be temporarily dropped from the block producing rotation during the maintenance. 

Since frequent offline maintenance is not encouraged, a certain part of reward from the validator will be deducted. 

To lower the impact from poorly-operating validators who forget to claim its maintenance, they will be forced to enter Temporary Maintenance mode too.

## 3. Status

This BEP is a draft.

## 4. Motivation

Due to the design of Parlia consensus, the absence of the validator, even if it is due to scheduled maintenance, will cause instability and capacity loss of BSC due to the extra waiting time and chain reorganization for other validators. 

Introducing Temporary Maintenance mode will stabilize the blocking rotation and maintain the capacity of BSC.

## 5. Specification

### Current Slash Mechanisms

The [slash contract](https://bscscan.com/address/0x0000000000000000000000000000000000001001) will record the missed blocking metrics of each validator.

1. Once the metrics are above the predefined threshold, the blocking reward for validator will not be relayed to BC for distribution but shared with other better validators.

2. If the metrics remain above another higher level of threshold, the validator will be dropped from the rotation, and put as “in jail”. This will be propagated back to Binance Chain, where a predefined amount of BNB would be slashed from the self-delegated BNB of the validator.

### Temporary Maintenance Mode

[Temporary Maintenance Flow]()

#### Proactive Maintenance

Validator can claim itself to enter scheduled maintenance by sending a transaction signed by the consensus key. The validator can claim itself to exit maintenance by sending another transaction. 

The slash cleaning work will be done within the exit transaction:

`SlashCount` =  (`MaintenanceEndHeight` - `MaintenanceStartHeight`) / len(`currentValidatorSet`) / `Scale`

Scale is a governable parameter, the initial setting is 2, usually it should be larger than 1. If  SlashCount is larger than a predefined value, the validator will still be slashed. 

The validator can get more time to bring the node back before being slashed if it claims itself to enter maintenance. 

Validator is encouraged to claim  itself to exit maintenance even if it will be put in jail, since it can send the unjail transaction earlier.

#### Passive Maintenance

Once the number of missed blocks is above a predefined threshold, the validator will enter maintenance automatically. 

The validator still gets a chance to catch up and claim itself online again.

#### Limit

The number of maintained validators has an upper limit. Once exceeded, the following claim request will be rejected.

A validator can only enter maintenance once per day.

## 6. License

The content is licensed under [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
