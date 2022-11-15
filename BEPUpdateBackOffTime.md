# BEP-172: Improvement on BSC validator committing stability

- [BEP-172: Improvement on BSC validator committing stability](#bep-172-improvement-on-bsc-validator-committing-stability)
  - [1. Summary](#1-summary)
  - [2. Abstract](#2-abstract)
  - [3. Status](#3-status)
  - [4. Motivation](#4-motivation)
  - [5. Specification](#5-specification)
    - [5.1 Overall Workflow](#51-overall-workflow)
    - [5.2 Remove recentlySigned validators from the candidate set](#52-remove-recentlysigned-validators-from-the-candidate-set)
    - [5.3 Reduce minimum delay duration to be zero added to 3 seconds](#53-reduce-minimum-delay-duration-to-be-zero-added-to-3-seconds)

## 1. Summary

 This BEP introduces an update for parlia consensus about the behavior when `slash` happend, so that the network will be more stable and efficient.

## 2. Abstract

This BEP introduces an update for parlia consensus, which changes the `timestamp` and `delay` setting for `offturn` validators. When the validator `inturn` missed his turn to commit block, the block mined by the `offturn` validator selected randomly would be committed as soon as possible(4 or 3 seconds).

## 3. Status

This BEP is a draft

## 4. Motivation

Before this BEP, a `slash` would happen when a validator missed his turn to commit a valid block. It would take some time longer than expected 3 seconds for the specific block mined with the `delay` mechanism, and even worse with the calculation algorithm deciding how long would be delayed when the block mined by `offturn` validator could be committed. And it took quit a long time (might be more than 1 minute) for the network recovering back to the expected block committing order with expected time duration(3 seconds).

With this BEP we rewrite the calculation algorithm for the `offturn` validation `delay` time, so that it should be able to commit block in 4 seconds for the selected `offturn` validator when the `inturn` validator missed his turn. What's more, the `slash` will not have bad influence on the future blocks which means the network will recover to expected block producing duration in time. 

## 5. Specification
### 5.1 overall workflow
![backoffTime](https://user-images.githubusercontent.com/26671219/200496713-a04cf05e-78e7-437b-a056-fe9ca001274b.png)

### 5.2 Remove recentlySigned validators from the candidate set
  - All validators would be involved to calculate the `delay` time when committing the block mined by himself currently, and when the `inturn` validator missed his turn, the fastest-with the smallest `delay` duration equals to 4 seconds-`offturn` validator might be the one that had signed recently which led to some other `offturn` validator be the valid selected one to commit block. This is how we observed a block be committed in more than 4 seconds when the `slash` happend. In this BEP, we remove the `recently signed` validators off from the candidate set for calculating `delay` duration from 1 seconds(then the duration would be 3+1=4 seconds) up.
### 5.3 Reduce minimum delay duration to be zero added to 3 seconds
  - When a `slash` happend, things would go wrong for quite a long time later on. For example, when `inturn` validator_A was `slashed` on block_100 and `offturn` validator_B took his place to commit the block of number 100. However validator_B should be `inturn` for committing block_101, then it would fail to commit block_101 since he had committed block_100 `recently`. So although there was actually no `slash` happend(all validator worked appropriately), we still need to `delay` some time (1 second or more) to wait for the `offturn` validator committing the block since the `inturn` validator had `recently` committed some block earlier.In this BEP, we reduce the shortest duration to zero second for this specific scenario which means blocks shold be able to committed in expected duration (3 seconds) when all validators workd propriately.


