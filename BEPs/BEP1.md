<pre>
  BEP: 1
  Title: Purpose and Guidelines
  Status: Living
  Type: Process
  Created: 2019-04-11
</pre>

# BEP 1: Purpose and Guidelines


- [BEP 1: Purpose and Guidelines](#bep-1-purpose-and-guidelines)
  - [1.  What is BEP?](#1--what-is-bep)
  - [2.  BEP Rationale](#2--bep-rationale)
  - [3.  BEP Types](#3--bep-types)
  - [4.  BEP Workflow](#4--bep-workflow)
  - [5.  BEP Format](#5--bep-format)
  - [6.  Reference](#6--reference)
  - [7.  License](#7--license)


## 1.  What is BEP?

BEP stands for BNB Chain Evolution Proposal. Each BEP will be a proposal document providing information to the BNB Chain community, including  BNB Beacon Chain, BNB Smart Chain, and opBNB. The BEP should provide a concise technical specification of the feature or improvement and the rationale behind it. Each BEP proposer is responsible for building consensus within the community and documenting dissenting opinions. Each BEP has a unique index number.

## 2.  BEP Rationale

BEP is the primary mechanism for proposing new features, for collecting community technical input on issues, and for documenting the design decisions that go into BNB Chain. Because BEPs are maintained as text files in a versioned repository, their revisions are the historical records of feature proposals.

For BNB Chain contributors, it is a convenient way to track the progress of their implementation by BEPs. It will help end users to know the status of a given feature, function or improvement.

##  3.  BEP Types

There are three types of BEP:

- **Standards**: A Standards BEP describes functional changes on BNB Chain, such as a change to the network protocol, proposer selection mechanism in consensus algorithm, change in block size or fee mechanism in application level. It will effect the implementation of BNB Chain.
- **Information**: An Information BEP will clarify some concepts of the BNB Chain, it may not effect the BNB Chain client implementation.
- **Process**: This kind of proposal will change the workflow of BNB Chain working process, like this BEP itself.

## 4.  BEP Workflow
![overall workflow](./assets/bep-1/workflow.png)

*Figure 1: BEP workflow*

- **Idea**: If you have an idea but not sure if it worths a BEP or not, you may discuss with the community first before you put too much effort. You may post your idea in [bnb chain forum](https://forum.bnbchain.org/) and visit the [bep-discussion channel in our discord](https://discord.gg/bnbchain) to let the community know it.
- **Draft**: If your idea is widely accepted or you have the confidence, you can draft a document following the BEP format and raise a PR in this repo. Once the PR is reviewed and merged by the BEP editors, it becomes a legal BEP. The pull request number will be used as the BEP number. And it will be recorded and maintained by the community. The BEP author should keep pushing it forward, the author can update the BEP by creating new pull requests.
- **Review(vote)**: Once the BEP is fully prepared, it proceeds to the Review phase, where it will be assessed by the community. Should the BEP introduce modifications to pivotal elements such as the consensus mechanism, economic framework, or user experience compatibility, a [governance vote](https://docs.bnbchain.org/bnb-smart-chain/governance/overview/) becomes essential. However, if the BEP pertains to a minor fix or a non-fundamental alteration, the governance vote may be bypassed.
- **Candidate**: If review is passed and the BEP is accepted, it will enter Candidate state.
- **Enabled**: This proposal is enabled in BNB Chain mainnet, if it is a hard fork, the fork number has reached.

Other exceptional statuses include:

- **Living**: A BEP will be long-term maintained, like this BEP.
- **Stagnant**: A BEP has not been updated for more than 6 months, it will enter Stagnant state.
- **Withdrawn**: A BEP that is dropped and will not be implemented. Usually, it is due to some prerequisite conditions that are not true anymore.

To make it more flexible, BEP can be updated as long as it is not enabled yet.

## 5.  BEP Format
It is important to keep BEP clear and well organized, BEPs need to follow this format(BEP1 is excepted):
- Preamble: a short metadata about the BEP, it should be put at the top of the BEP. Here is an example:
<pre>
  BEP: 127
  Title: Temporary Maintenance Mode for Validators
  Status: Enabled
  Type: Standards
  Created: 2022-01-10
  Author(optional): it can be a name or an email.
  Description(optional): enabled by BSC Euler upgrade, block height 18907621, Jun-22-2022
  Discussions(optional): could be a link to the bnb forum, where it is discussed.
</pre>
- Summary: a very short summary with a single sentence, someone could understand the purpose of the BEP by reading it even without technical background.
- Abstract(optional): a short paragraph to give more introduction about the BEP, could be multi-sentence. Someone could read the abstract to know the general workflow of the BEP.
- Motivation: it is a critical part of the BEP, it should explain very clearly why this proposal is needed.
- Specification: it is another critical part, the detail workflow and configuration need to be provided. Diagrams are needed to make it easy to be understood if it is hard to be described in text.
- Rational(optional): it adds more information to support the specification, i.e. why the design in the specification is preferred.
- Forward Compatibility(optional): if the BEP will introduce compatibility problems in the future, probably because of some scheduled changes in the future that would be broken by the BEP. In such case, this part is a must to describe the detail incompatibilities and how to deal with it.
- Backward Compatibility(optional): similar to Forward Compatibility, if the BEP introduces compatibility problems to the previous or current system, then this part is a must to describe the detail incompatibilities and how to deal with it.
- Reference Implementations(optional): before the BEP enters the Final state, a reference implementation will be needed. However, if the BEP does not need a implementation, it can be omitted.
- Vote Status(optional): A link will be provided to showcase the outcome of the vote if the BEP needs vote.
- License: to show the copyright of the BEP.

## 6.  Reference

Ethereum Improvement Proposals:  [https://github.com/ethereum/EIPs](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1.md)

Bitcoin Improvement Proposals:  <https://github.com/bitcoin/bips>

##  7.  License

All the content are licensed under [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
