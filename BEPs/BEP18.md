# BEP-18: State sync enhancement

- [BEP-18: State sync enhancement](#bep-18-state-sync-enhancement)
  - [1.  Summary](#1--summary)
  - [2.  Abstract](#2--abstract)
  - [3.  Status](#3--status)
  - [4.  Motivation](#4--motivation)
  - [5.  Specification](#5--specification)
    - [5.1 Take snapshot](#51-take-snapshot)
    - [5.2 Sync snapshot](#52-sync-snapshot)
    - [5.3 Manifest format](#53-manifest-format)
    - [5.4 Snapshot chunk format](#54-snapshot-chunk-format)
      - [5.4.1 App state chunk](#541-app-state-chunk)
      - [5.4.2 Tendermint state chunk](#542-tendermint-state-chunk)
      - [5.4.3 Block chunk](#543-block-chunk)
    - [5.5 Operation suggestion](#55-operation-suggestion)
  - [6. License](#6-license)

## 1.  Summary

This BEP describes [state sync](https://docs.bnbchain.org/docs/beaconchain/develop/node/synctypes/#state-sync) enhancement on the BNB Beacon Chain.

## 2.  Abstract

[State sync](https://docs.bnbchain.org/docs/beaconchain/develop/node/synctypes/#state-sync) is a way to help newly-joined users sync the latest status of the BNB Beacon Chain. It syncs the latest sync-able peer's status so that fullnode user (who wants to catch up with chain as soon as possible with a cost that discards all historical blocks locally) doesn't need sync from block height 0.

BEP-18 Proposal describes an enhancement of existing state sync implementation to improve user experience. The status of the blockchain that can be synced is represented in a **"snapshot"**, which consists of a manifest file and a bunch of snapshot chunk files. The manifest file summarizes version, height, and checksums of snapshot chunk files of this snapshot. The snapshot chunk files contain encoded essential state data to recover a full node.

This BEP introduces the following details:

- What's the procedure to take a snapshot
- What's the procedure to sync snapshot from other peers
- Snapshot (manifest, snapshot chunks) format

## 3.  Status

This BEP is already implemented.

## 4.  Motivation

We propose this BEP to enhance full node user experience (and ease their pain) on using state sync because of the following implementation limitations.

1. Users complain most about state syncing testnet is very slow and usually stuck on some requests. <br> <br> In this enhancement, we want data to respond more evenly across peers so that syncing can continuously make progress and the overall syncing time can reduce from 30 - 45 min to around 5 min.

2. Interruption during state sync (node process get killed because of reboot computer or user impatience) would make already synced data in vain (because the current full node doesn't persist synced part on disk). Worsely it mistakenly writes a lock file prevents user state sync again. <br> <br> In this enhancement, we want support break-resume downloading and keep the consistent status for arbitrarily restart.

## 5.  Specification

State sync will download **manifest** and **snapshot chunks** from other peers.

### 5.1 Take snapshot

There are two ways to take snapshots from a fullnode: automatically or manually. Snapshots will be put under `$HOME/data/snapshot/<height>`. All types involved in the snapshot are encoded by go-amino and compressed by snappy. More details will be explained later.

1. To make fullnode automatically take snapshots, just make sure `state_sync_reactor` in `$HOME/config.toml` is set to true. When set automatically snapshot, the fullnode will take a snapshot for blocks with a blocking time of 00:00 UTC each day. No snapshot will be taken for any other blocks during the day.
2. To manually take snapshots, stop the node if it is running, then run `./bnbchaind snapshot --home <home> --height <height>`.

If the snapshot taking procedure is interrupted, the node will be still in good status, but it cannot provide the interrupted height for other peers to sync.

Note: Automatic snapshot files will keep occupying disk space. Fullnode would not delete them automatically, so the user should periodically delete unneeded snapshots manually if they want to save disk space.

### 5.2 Sync snapshot

Syncing snapshot is designed to be only run once during full node first start. To enable state sync from others, `state_sync_reactor` should be true and `state_sync_height` should be set to non-negative (default `-1` means disable syncing from others).

If a user wants to sync from (majority) peers' latest sync-able height, they should set `state_sync_height` to 0.

Stop and restart fullnode during state sync is allowed. The next time full node is started, it will resume by loading Manifest and downloaded snapshot chunks then download missing snapshot chunks.

Once state sync is successful, a `STATESYNC.LOCK` file will be created under `$HOME/data` to prevent state sync next time.

### 5.3 Manifest format

Manifest serves as a summary of snapshot chunks to be synced. It also maintains the order and types of snapshot chunks. Fullnode firstly asks peer's for the manifest file at the beginning of state sync and will trust majority peers with the same manifest.

SHA256 hash sum of each chunk synced will be checked against the hash declared within the manifest file.

| Field          | Type        | Description                                                                                                                                                                                                                                                                                                                                                      |
|----------------|-------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Version        | int32       | snapshot version                                                                                                                                                                                                                                                                                                                                                 |
| Height         | int64       | height of this snapshot                                                                                                                                                                                                                                                                                                                                          |
| StateHashes    | []SHA256Sum | hashes of tendermint state chunks                                                                                                                                                                                                                                                                                                                                |
| AppStateHashes | []SHA256Sum | hashes of app state chunks                                                                                                                                                                                                                                                                                                                                       |
| BlockHashes    | []SHA256Sum | hashes of the blocks in this snapshot, currently only the block of requested height is synced. This synced block is needed mainly to make sure local databases are consistent with each other after state sync. It also provides block metadata like a timestamp for tendermint abci application.                                                                                                                                                                                                                                                                                             |
| NumKeys        | []int64     | number of keys for each sub-store.<br><br> |

### 5.4 Snapshot chunk format

#### 5.4.1 App state chunk

 App state chunk includes iavl tree nodes. Usually, each app state chunk takes up to 4MB serialized iavl tree nodes (before snappy compression).

 Iavl tree node bigger than 4MB is split into different incomplete chunks, that's where `Completeness` field effect.

| Field        | Type     | Description                                                                                                                                                                                  |
|--------------|----------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| StartIdx     | int64    | compare (startIdx and number of complete nodes) against (Manifest.NumKeys) we can know each node should be persisted to which application db's sub-store. <br/><br/>For example, `acc` and `token` store each has 10 and 5 nodes (with `NumKeys = []int64{10, 5}` in Manifest).  <br/><br/> An app state chunk whose `StartIdx` is `0` and completeness is `0` (complete) with `12` nodes, the first of 10 nodes will be persisted to `acc` store and last 2 nodes will be persisted to `token` store. <br/><br/> After above chunk, there might be *4* app chunks whose `StartIdx` are `12`, but `Completeness` would be `1`, `2`, `2`, `3` respectively and each chunk contains only one element in Nodes. The actual *3rd* `token` store iavl tree node should be recovered by combining these 4 chunks' node elements together. At the recovering side, we know the order of 2 middle chunks because their order is kept in the Manifest file.                                                                               |
| Completeness | uint8    | flag of completeness of this chunk, not enum because of go-amino doesn't support enum encoding.  <br/><br/> possible values: 0 (Complete), 1 (InComplete_First), 2 (InComplete_Mid), 3 (InComplete_Last)	<br/><br/> the InComplete flags are used to identify continuous large nodes' boundary.                                                                                                     |
| Nodes        | [][]byte | iavl tree serialized node, one big node (i.e. active orders and order book) might be split into different chunks (they share same StartIdx with different completeness flag), the order is ensured in the manifest file |

#### 5.4.2 Tendermint state chunk

| Field     | Type   | Description |
|-----------|--------|-------------|
| Statepart | []byte | current tendermint state            |

#### 5.4.3 Block chunk

| Field      | Type   | Description                                                                                                                                    |
|------------|--------|------------------------------------------------------------------------------------------------------------------------------------------------|
| Block      | []byte | amino encoded block                                                                                                                            |
| SeenCommit | []byte | amino encoded Commit<br>we need this because Block keeps seen commit for the last block. To save this block, we need to load and pass it in the same way it was saved |

### 5.5 Operation Suggestion
1. As mentioned in section [5.1 Take snapshot](#51-take-snapshot), fullnode cannot delete snapshot directories (`$HOME/data/snapshot/<height>`) automatically. This needs to be noticed by full node users who enabled `state_sync_reactor`. Either run a script periodically delete the snapshots or turn off `state_sync_reactor` (if they want to be selfish!) should be considered.

2. Once state sync succeeds, later full node restart would not state sync anymore (in case the local blocks are not continuous).

But if users do want state sync again (don't care that there are missing blocks between last stop and latest state sync snapshot height) and he wants to keep already synced blocks, he should delete `$BNCHOME/data/STATESYNC.LOCK`.

## 6. License

The content is licensed under [CC0](https://creativecommons.org/publicdomain/zero/1.0/).