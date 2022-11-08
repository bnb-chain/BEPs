# BEP-?: update backOffTime

[toc]

## 1. Summary

 This BEP introduces an update for parlia consensus about the behavior when `slash` happend, so that the network will be more stable and efficient.

## 2. Abstract

This BEP introduces an update for parlia consensus, which change the `timestamp` and `delay` setting for `offturn` validators. When the validator `inturn` missed his turn to commit block, the block mined by the `offturn` validator selected would be committed as soon as possible(4 or 3 seconds).

## 3. Status

This BEP is a draft

## 4. Motivation

Before this BEP, a `slash` would happen  when a validator missed his turn to commit a valid block . It would take some time longer than expected 3s for the specific block mining with the `delay` mechanism, and even worse with the calculation algorithm deciding how long would be delayed when the block mined by `offturn` block could be committed. And it took quit a long time (might be more than 1 minute) for the network recovering back to the expected block committing order with expected time duration(3s).

With this BEP we rewrite the calculation algorithm for the `offturn` validation `delay` time,  so that it should be able to commit block in 4s for the selected `offturn` validator when the `inturn` validator missed his turn. What's more, the `slash` will not have bad influence on the future blocks which means the network will recover to expected block producing duration in time. 

## 5. Specification

- Remove `recentlySigned` validators from the candidate set When calculate `delay` time for `offturn` validators.
- Reduce minimum `delay` to be zero added to 3 seconds when the `inturn` validator has `recentlySigned`

![backoffTime](/Users/linqing/Downloads/backoffTime.png)