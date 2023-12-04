<pre>
  BEP: xxx4844
  Title: ProtoDankSharding
  Status: Draft
  Type: Standards
  Created: 2023-12-04
</pre>

# BEP-xxx4844: ProtoDankSharding

## 1. Summary

This BEP proposes introduction of blob-carrying transactions which may contain large amount of data.

## 2. Abstract 

Introduce a new transaction format for “blob-carrying transactions” which contain a large amount of data that cannot be accessed by EVM execution, but whose commitment can be accessed. The format is intended to be fully compatible with the format that will be used in full sharding.

## Status 

Work in progress. A PoC has been created in this branch: https://github.com/bnb-chain/bsc/tree/4844 

## 3. Motivation 

Rollups such as OpBnB offer scaling solutions of BSC. But their ability might be limited sometimes due to higher transaction fees and cost of storage in the blockchain.

This BEP provides a solution by introducing blob-transaction which carry blobs that can be arbitrary data (e.g. from a rollup) and they act as temporary storage. Therefore they cost less and have the potential to make it cheaper for rollups to interact with BSC.

## 4. Ethereum Specification 

Details of Ethereum specification can be found [here](https://eips.ethereum.org/EIPS/eip-4844). 
The specification from execution layer will be same in case of BSC. The specifications from consensus layer will differ as BSC doesn't have execution-consensus separation. 

## Life of a Blob Transaction

### Blob pool
### Verification / Filtering
### Consensus process
### Generation of Sidecars
### Storage of Sidecars
### Propagation of Sidecars among peers
### Fetching of Sidecars when a node starts

## 5. Changes Specifc to BSC

As there is on separation of execution-consensus layers in BSC, the engine api related changes from Ethereum aren't required here. The other changes are summarized below:

# 5.1 Verification

The verification will occur in parlia consensus layer. The blobs are stored separately as sidecars instead of being part of the block. Parlia consensus engine is responsible for persisting these sidecars.

# 5.2 Sidecar Propagation / P2P network

The propagation of sidecars will be done the same way it is done for blocks.

# 5.3 Sidecar Fetching/Downloading

In line with the current fetcher of BSC which is used for blocks, a new fetcher will be created which will be specifically for fetching blobs/sidecars. Same way for Downloader. A decision needs to be made regarding frequency of fetching as high frequency might be costly for the network.

## 7. License
The content is licensed under [CC0](https://creativecommons.org/publicdomain/zero/1.0/).