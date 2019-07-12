# BEP 1: Purpose and Guidelines


- [BEP 1: Purpose and Guidelines](#bep-1--purpose-and-guidelines)
  * [1.  What is BEP?](#1--what-is-bep)
  * [2.  BEP Rationale](#2--bep-rationale)
  * [3.  BEP Types](#3--bep-types)
  * [4.  BEP Workflow](#4--bep-workflow)
  * [5.  Reference](#5--reference)
  * [6.  License](#6--license)


## 1.  What is BEP?

BEP stands for Binance Chain Evolution Proposal. Each BEP will be a proposal document providing information to the Binance Chain/DEX community. The BEP should provide a concise technical specification of the feature or improvement and the rationale behind it. Each BEP proposer is responsible for building consensus within the community and documenting dissenting opinions. Each BEP has a unique index number.

## 2.  BEP Rationale

BEP is the primary mechanism for proposing new features, for collecting community technical input on an issue, and for documenting the design decisions that go into Binance Chain. Because the BEP are maintained as text files in a versioned repository, their revision history is the historical record of the feature proposal.

For Binance Chain contributors, BEPs are a convenient way to track the progress of their implementation. This will give end users a convenient way to know the current status of a given feature, function or improvement.

##  3.  BEP Types

There are three types of BEP:

- Feature Request: A Feature Request BEP describes functional changes on Binance Chain or/and Binance DEX, such as a change to the network protocol, proposer selection mechanism in consensus algorithm, change in block size or fee mechanism in application level.
- Improvement: Improvements are advice gathered from the community.
- Standard: This kind of proposal will change the workflow of Binance Chain working process, like this BEP itself.

## 4.  BEP Workflow

![img](https://lh3.googleusercontent.com/auaU1Ur5SZZKVcwQrFrHN-3T1vUP8C1wCjFWqJzzJpcdVCHR4JXe1Mzm7hCFuoEqVjkUOZIF5WrwK47jGw8r3wp9RLEPvAWY6DOsncNz0yCeVc84qew1Xf7ouk1qrcNdXpjGSNQG)

*Figure 1: BEP workflow*

Each status change is requested by the BEP author and reviewed by the BEP editors. Use a pull request to update the status.

- Work in progress (WIP) -- A community member will write a draft BEP as a pull request.
- Draft -- An editor will add notes and some requests, then if all changes are made, it will go to the next stage. If it’s not approved, it will be dropped.
- Final -- This BEP is ready to be implemented
- Implementation -- the development team could start work on this BEP

Other exceptional statuses include:

- Deferred -- This is for some BEPs that depend on changes of a future BEP implementation. The current BEP will stay in the *Deferred* state and wait for the hardfork.
- Dropped -- A BEP that is dropped and will not be implemented. Usually, it is due to some prerequisite conditions that are not true anymore.
- Superseded -- A BEP which was previously final but is no longer considered applicable. This happens when an on-going implementation conflicts with a newly created BEP in *Final* state. The latter needs to refer to the incompatibility BEP and elaborate backward incompatibilities issue.

## 5.  Reference

Ethereum Improvement Proposals:  [https://github.com/ethereum/EIPs](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1.md)

Bitcoin Improvement Proposals:  <https://github.com/bitcoin/bips>

##  6.  License

All the content are licensed under [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
