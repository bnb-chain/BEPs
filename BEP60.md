# BEP60: Trustless Atomic Peg

# Summary

This BEP introduces an extension to BEP3 atomic pegs that improves it's trustlessness properties.

# Abstract

We propose a protocol that makes BEP3 pegs totally trustless through the addition of an emergency lockdown mechanism that is triggered via fraud proofs, which are used to prove deputy mismanagement via the relaying of SPV proofs of fraudulent transactions performed by the deputy.

This is an Improvement BEP and therefore does not require changes to Binance Chain in order to be implemented.

# Status

This BEP is under specification.

# Motivation

BEP3's atomic pegs are a huge boon in terms of transparency and have helped move the ecosystem forward, but, in terms of trustlessness, there's room for improvement, as, in it's current form under the BEP3 specification, they require honesty on the side of the deputy due to the fact that it assumes responsability for relaying information between chains, especifically it is expected to relay honest information.

This is not a problem in the cases where the role of deputy is assumed by the same entity that issues the tokens and gives them value, as in these cases users already need to trust these entities (the only thing underpinning the value of these tokens are the promises given by the issuers, if suddenly a tokenized company stopped giving dividends to token holders those tokens would become worthless, therefore if users don't trust the issuers those tokens shouldn't have any value to them) so the trust required for deputies can just piggyback on that inherent trust already placed on them and the trust model doesn't change.

But there are cases in which either this is impossible, such as when there isn't a centralized issuer like in the case of ether, or the issuer is not interested in becoming a deputy. In these cases there's no choice but to have a different deputy take the spot, leading to a change in the trust and security models, given that now it is necessary to trust a new entity. It is important to note that this trust must be absolute because, while BEP3 shields users from being scammed in the processes of porting tokens and redeeming them back, it is possible for a malicious deputy to relay fake information to the smart contract saying that an account controlled by them has locked an enormous amount of pegged BEP2 tokens with secret X, then proceed to reveal the secret and drain the smart contract out of all the real tokens stored there.

The BEP is to tackle this problem through the proposal of a protocol that enables trustless pegs with smart-contract-enabled chains. 

# Specification

## Pre-requisites

This BEP requires the existence of an up-to-date SPV node of Binance Chain on the smart-contract-enabled blockchain with which the peg is to be maintained. This means that a smart contract capable of verifying state transitions on Binance Chain should be developed and updated with the constant relaying of transactions that affect it's operations, such as any change in Binance Chain's validator set.

## Trustless Atomic Peg Swap

### Overview

This BEP extends the original BEP3 process in order to remove the parts that require trust in the deputy, which are the parts of the protocol where the deputy acts as a trusted oracle between both chains, relaying information between them. In the current state of BEP3 this is happens in two situations, when new pegged tokens are issued and when they are redeemed.

For token redemption this is pretty straightforward, tokens on Binance Chain can be burned by sending them to the null address and then an SPV proof of this transaction can be relayed by anyone to the smart contract, which will then verify that the transaction actually happened on Binance Chain and send the unlocked tokens to the entity that burned the tokens.

The other case, which involves minting new pegged tokens when real tokens are locked on the smart contract, is much harder to decentralize as there are no smart contracts on Binance Chain, preventing transaction verification on that side of the peg. We get around this by maintaining the figure of the deputy while adding an emergency mechanism, an escape hatch that allows anyone to ring the alarm whenever the deputy behaves incorrectly, prove his bad behavior and freeze everything in order to give all the tokens back to their current rightful owners. After this process has been completed, a new custodian can be selected and the peg restarted.

### Emergency mechanism

The emergency mechanism, which can be triggered by anyone in the event of the custodian minting unbacked coins, follows these steps:

1. Custodian sends tokens to some address that has not previously locked tokens on the smart contract, essentially minting pegged tokens out of thin air and destroying the backing of the peg.
2. A user finds out about this, creates an SPV proof of the fraudulent transaction described in the previous step and sends it to the smart contract.
3. The smart contract verifies the validity of the proof and checks that the address where the pegged tokens were sent has no previously locked tokens. If both conditions hold, the contract enters an emergency state, which prevents new tokens from being locked, takes the `AppHash` of the last known good block (the last block before the fraudulent transaction took place) and pins it as the final token distribution, taking a snapshot of all the token balances at that point.
4. Users can then submit proofs proving the value of their balances of pegged tokens at the moment the `AppHash` was snapshotted along with proof of ownership of the addresses that held those coins (this can be as simple as signing a message with that account's private key). Upon successful verification, they'd be allowed to withdraw in real tokens the amount of pegged tokens that they held at that point in time.

### Potential attack

This scheme can lead to an attack where the custodian rolls back transactions of the pegged tokens by waiting till a transaction happens and then sending a fraudulent transaction in the same block, when that is reported that block will not be included in the final distribution of tokens, therefore, in practical terms, it's as if the custodian has managed to remove that transaction. This can be fixed by implementing a system that tracks the origin of the tokens in any balance and only redeems those that do not come from fraudulent custodian mints, but this system is much more complex.

## License

The content is licensed under [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
