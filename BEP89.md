# BEP-89: Visual Fork of Binance Smart Chain

- BEP-89: Visual Fork of Binance Smart Chain
  - [1. Summary](#1-summary)
  - [2. Abstract](#2-abstract)
  - [3. Status](#3-status)
  - [4. Motivation](#4-motivation)
  - [5. Specification](#5-specification)
    - [5.1 Fork Hash](#51-fork-hash)
    - [5.2 Vanity](#52-vanity)
    - [5.3 Vanity](#53-clients)
    - [5.4 Backwards Compatibility](#54-backwards-compatibility)
  - [6. License](#6-license)

## 1.  Summary

This BEP describes a proposal to enable the chain to display the whole view of validators that on different upcoming forks.

## 2.  Abstract

The four bytes of `Header.Extra[28:32]` will be fulfilled with `NEXT_FORK_HASH`. The `NEXT_FORK_HASH` indicates which fork the signer of this block is going to stay on. By analysing `N` (`N` is the amount of validators) continuous block headers, we are able to know which fork is supported by the majority of validators and exact which validator has not upgraded yet.

## 3.  Status

This BEP is already implemented

## 4.  Motivation

Binance Smart Chain will have some hard forks inevitably in the long run. Binance Smart Chain takes a risk of halt during hard fork once the validators can not reach a consensus. A validator could be slashed if it is not on the canonical fork which could be avoidable if the maintainer received alerts in time. A new protocol should be introduced to enable the chain to display the whole view of validators that on different upcoming forks. Any nodes/validators can decide to upgrade/fork or not accordingly.

## 5.  Specification

###  5.1 Fork Hash

Fork Hash is introduced in [EIP-2124](https://eips.ethereum.org/EIPS/eip-2124). It is a mechanism that can let ethereum nodes precisely identify whether another node will be useful.

- `FORK_HASH`. IEEE CRC32 checksum ([4]byte) of the genesis hash and fork blocks numbers that already passed. E.g. Fork Hash for mainnet would be: `forkhash₂ = 0x91d1f948 (DAO fork) = CRC32(<genesis-hash> || uint64(1150000) || uint64(1920000))`.
- `FORK_NEXT`. Block number (uint64) of the next upcoming fork, or 0 if no next fork is known.
- `NEXT_FORK_HASH`, whose algorithm is same with `FORK_HASH`, but `FORK_NEXT` will be included as well if it is not 0.

### 5.2 Vanity

Format of `Header.Extra`:

```
|   32 bytes       |       20 * N bytes      |   65 bytes     |
|   extraVanity    |   validatorSetBytes     |   extraSeal    |
```

`extraVanity` field is customized now, validator can use it to record `NEXT_FORK_HASH` of itself. The `NEXT_FORK_HASH` will only use the last 4 bytes of `extraVanity`.

### 5.3 Clients

- For validator. It will fill in `Header.Extra` with `NEXT_FORK_HASH` during preparing block header.
- For witness. It will log a warning message if the majority `NEXT_FORK_HASH` is different from local.
- For light client. No impact.

### 5.4 Backwards Compatibility

- This BEP itself is not a hardfork one, it breaks nothing of consensus.
- Downstream service is completely compatible with this BEP.

## 6. License

The content is licensed under [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
