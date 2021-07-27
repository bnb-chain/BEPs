# BEP-91: Increase Block Gas Ceiling for Binance Smart Chain

- [BEP-91: Increase Block Gas Ceiling for Binance Smart Chain](#bep-91-increase-block-gas-ceiling-for-binance-smart-chain)
  - [1. Summary](#1-summary)
  - [2. Abstract](#2-abstract)
  - [3. Status](#3-status)
  - [4. Motivation](#4-motivation)
  - [5. Specification](#5-specification)
  - [6. License](#6-license)
  
## 1. Summary

This BEP describes a proposal for the increment of **gasceil** of BSC.

## 2. Abstract

BEP-91 Proposal describes a change of BSC node configuration, and suggests Validator operators should increase the value of  the block `GasCeil`from `75000000` to `100000000`, and increase the value of  the block `GasFloor`from `60000000` to `75000000` .

## 3. Status

This BEP is a draft. 

## 4. Motivation

The increasing adoption of BSC leads to a more active network. Blocks start hitting the gasceil daily. The increasing prevalence of blocks near the limit may lead to increased fees and delays in the processing of transactions in the future. This will undermine the core value of BSC as a fast and cheap network. 

<img src="https://lh3.googleusercontent.com/SJut_-wd361nLpE7Gk6pMW8CQ_DoV4zPn4iqdz-jXA_Nd576YByacMj3mdH1IVdfGyvYl6HgHXAaqioEDyRIXK4wgr-KSP6MxbWrrLNX8M-ml3cznz3F8M-hZEZBao4jWSXVOIx3" alt="img" style="zoom:25%;" />

BSC network has once reached the 40M gas limit, it can handle more transactions according to the following screenshot.

<img src="https://lh6.googleusercontent.com/IiLTxhMi5JrHnWd-Oz0AABtS0hqNe7ILUkiw3FG0-fuChPUfRtDX_ux-hoMeIRZyQUKEtx5Kj_THcTAXFmoyDjXwdpGwoPMO80ncpjvtOoUsVdVdyuWGYK0gqxRL4htAn46hwRIf" alt="img" style="zoom:25%;" />

Increased gasceil will lead to more transactions per block. It will be a direct solution to scale.  

## 5. Specification

According to the past laboratory tests, BSC can process real transactions with more than 120M Gas. Considering the complex network environment in mainnet and the different hardware of validators, 100M is a relatively reasonable value. If 100M is larger than expected, the miner module of BSC will adaptively adjust it to avoid network overloading. 

It is strongly recommended to raise the gasceil parameter as well as hardware. The validator may get less reward than expected if its hardware fails to validate enough tx.

As the transaction volume continues to increase, more changes should be made to the internal logic on transaction execution, storage and P2P communication.

## 6. History

- 2021-05-25: Raise gas limit from 60000000 to 75000000
- 2021-07-27: Raise gas limit from 75000000 to 100000000

## 7. License

The content is licensed under [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
