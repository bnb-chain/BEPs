# BEP-93: Diff Sync Protocol on BSC

## 1.  Summary

This BEP introduces a new sync mode named diff sync on the BNB Smart Chain.

## 2.  Abstract

BEP-93 Proposal describes a fast block syncing protocol to lower the hardware requirement for running a BSC client. A BSC client can simply apply the execution result of a block securely without executing the transactions.

Currently, BSC has three kinds of sync mode: 
1. Snap sync; 
2. Fast sync; 
3. Full sync.

Snap sync and fast sync are used for the initial synchronization, once the client has the entire state and all historical block data, it will switch to full sync automatically. 

It takes several steps to process a block when doing full sync: 
1. Fetch/Receive blocks from other peers through p2p network.  
2. Verify header and block body. 
3. Execute transactions within EVM.
4. Calculate the root hash of MPT.
5. Commit MPT to memory DB,  persist snapshot and MPT to disk if necessary.

In most cases, step 3 occupied 70+% of the block processing time.  

This BEP proposes a diff sync protocol without executing transactions, in exchange, the security of a fullnode will degrade to a light client, but meanwhile the node can still keep the full state and blocks of the network. This will benefit the small node so that they can still be used as full nodes and participate in the light verification of the network.

## 3.  Status

This BEP is already implemented.

## 4.  Motivation

The increasing adoption of BSC leads to a more active network. Blocks on BSC start hitting the gasceil daily, and the BSC network will increase the capacity further. On the other hand, the node maintainer had a hard time keeping their node catching up with the chain. A light syncing protocol to lower the hardware requirement is an urgent need.

## 5.  Specification
### 5.1 Diff Protocol

A new protocol named diff will run on top of the p2p network besides eth and snap. Four kinds of packages are defined under the diff protocol:

1. **DiffCapMsg**. It is used to exchange whether the peer supports diff sync during the handshake. 
2. **GetDiffLayerMsg**. It is used to request diff layers from other peers.
3. **DiffLayerMsg**. It is used to broadcast diff layers to other peers.
4. **FullDiffLayerMsg**. It is a response to GetDiffLayerMsg which contains the diff layers.

Diff layer is the execution result of a block, it contains:
1. **BlockHash**. 
2. **Number**. The height of the block.
3. **Receipts**. The receipts of the block.
4. **Codes**. The newly created smart contract code within the block.
5. **Destructs**. The destroyed accounts within the block.
6. **Accounts**. The account change within the block.
7. **Storages**. The storage change within the block.

### 5.2 Sync Diff Layer
![Untitled Diagram drawio](https://user-images.githubusercontent.com/7310198/132794555-e071232b-9d91-461e-b6ef-9589cd37f738.png)


Workflow:
1. P2P nodes full sync a block and cache the generated diff layer. 
2. (optional)The generated diff layer can be persisted if it is on the canonical chain. 
3. P2P nodes may receive diff layers from other peers, will cache it in an untrusted diff layer set.
4. P2P node will broadcast diff layers to parts of connected peers.
5. P2P nodes will pick diff layers from the cache, disk, and untrusted set to respond to requests from other peers.
6. A full node can fetch diff layers from other peers 
7. A full node can apply the diff layers to MPT and Snapshot without executing transactions, it is called light process. If the light process failed, the full node will fall back to full sync.

### 5.3 Security
The diff sync protocol guarantees 1. Light client security; 2. State consistency.

It sustains 1. Validator collusion 2. Short fork with an invalid state.

For validator collusion, the full node will randomly full sync to prevent applying a false state caused by validator collusion.

For short fork with an invalid state, it is highly recommended that at least 21 blocks are needed to reach finality for a diff sync client. 

### 6. License

The content is licensed under [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
