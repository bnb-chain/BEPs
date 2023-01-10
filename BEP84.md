# BEP-84: Mirror BEP20 to BNB Beacon Chain

- [BEP-84: Mirror BEP20 to BNB Beacon Chain](#bep-84-mirror-bep20-to-bnb-beacon-chain)
  * [1. Summary](#1-summary)
  * [2. Abstract](#2-abstract)
  * [3. Motivation](#3-motivation)
  * [4. Status](#4-status)
  * [5. Specification](#5-specification)
    + [5.1 TokenManager](#51-tokenmanager)
      - [5.1.1 Mirror](#511-mirror)
        - [5.1.1.1 Parameters](#5111-parameters)
        - [5.1.1.2 Pre-check](#5112-pre-check)
        - [5.1.1.3 Core Mechanism](#5113-core-mechanism)
        - [5.1.1.4 Handle Ack Packages](#5114-handle-ack-packages)
      - [5.1.2 Sync](#512-sync)
        - [5.1.2.1 Parameters](#5121-parameters)
        - [5.1.2.2 Pre-check](#5122-pre-check)
        - [5.1.2.3 Core Mechanism](#5123-core-mechanism)
        - [5.1.2.4 Handle Ack Packages](#5124-handle-ack-packages)
    + [5.2 BC Bridge](#52-bc-bridge)
      - [5.2.1 Mirror Channel](#521-mirror-channel)
      - [5.2.2 Sync Total Supply Channel](#522-sync-total-supply-channel)
    + [5.3 Proposals to Enable New Channels](#53-proposals-to-enable-new-channels)
  * [6. License](#6-license)

## 1. Summary
This BEP proposes a scheme to facilitate users to issue and bind BEP2 tokens with existing BEP20 tokens.

## 2. Abstract
Currently, if a user wants to issue and bind a BEP2 token with an existing BEP20 token, it has to do a set of complex operations, including issue BEP2 tokens, sending a bind transaction and approving the binding request. The BEP will bring a mechanism to simplify the above process. In the new mechanism, what anyone can do this is just sending a transaction to BNB Smart Chain.

## 3. Motivation
Current bind mechanism is based on the context that our community members are on the BNB Beacon Chain and they want to extend their tokens to the BNB Smart Chain. However, with the evolution of our community, things changed. In most cases, users issue bep20 on the BNB Smart Chain first without considering whether they will issue BEP2 on the BNB Beacon Chain or not, so a new mechanism to conveniently extend BEP20 assets to the BNB Beacon Chain is required. In addition, the new mechanism will encourage users to extend their assets to the BNB Beacon Chain which is very helpful to flourish the BNB Chain community.

## 4. Status
This BEP is already implemented

## 5. Specification

Two new permissionless methods will be imported into TokenManager contract:
Mirror: If a BEP20 contract is not bound to any BEP2 token, anyone can call the mirror method to automatically issue a BEP2 token and bind them. The user is not required to have any BEP20 token and just needs to pay enough BEP2 issue fee. Besides, the BEP20 contract is even not required to implement getOwner method. After binding, all the initial circulation is on BSC.
Sync: For a BEP20 token which has been mirrored to BC, anyone can call sync method to balance the total supply on BC and BSC. For example, someone mint some BEP20 token, after calling sync method,  the equivalent token will be minted on BC and transferred to the pure-code-controlled-escrow address. If someone burn some BEP20 token, after calling sync method, the equivalent token will be burned on BC from the pure-code-controlled-escrow address.

### 5.1 TokenManager

#### 5.1.1 Mirror

##### 5.1.1.1 Parameters

| **Param Name**    | **Type** | **Description**   |
| ------------ | -------- | ---------------------- |
| BEP20Addr    | Address  | BEP20 contract address |
| ExpiredTime  | uint64   | The deadline to deliver this package on BC |
| msg.value    | uint256  | Sum of cross chain fee and mirror fee |

##### 5.1.1.2 Pre-check

1. Ensure the BEP20 token hasn’t been bound before and is not in mirror pending status.
2. Ensure the BEP20 symbol follows the BEP2 symbol requirements.
3. Ensure the BEP20 name follows the BEP2 name requirements.
4. Ensure the equivalent total supply is no greater than Max BEP2 total supply.
5. Ensure msg.value >= MirrorFee + CrossChainFee and msg.value = N * 10^10
6. Ensure expired time is earlier than one day later and no earlier than two minutes later.

##### 5.1.1.3 Core Mechanism

1. Transfer CrossChainFee to TokenHub
2. Mark the BEP20 token as mirror pending status
3. RLP Encode mirror package:

| **Param Name**    | **Type** | **Description**        |
| ----------------- | -------- | ---------------------- |
| MirrorSender      | Address  | Mirror sender          |
| BEP20Addr         | Address  | BEP20 token address    |
| BEP20Name         | bytes32  | BEP20 token name       |
| BEP20Symbol       | bytes32  | BEP20 token symbol     |
| BEP20Supply       | uint256  | BEP20 total supply     |
| BEP20Decimals     | uint8    | BEP20 decimals         |
| MirrorFee         | uint256  | The mirror fee from users, which will be used to cover issue BEP2 token. |
| ExpiredTime       | uint64   | The package expired time, counted by second |

4. Call CrossChain contract to send a cross chain package.
5. If a BEP20 token is in mirror pending status or already mirrored, reject approveBind on it.

##### 5.1.1.4 Handle ack packages

1. Fail ack package:
    1. RLP decode mirror package.
    2. Refund MirrorFee to mirror sender.
    3. Set the BEP20 pending mirror status to false

2. Ack package

    | **Param Name**    | **Type** | **Description**        |
    | ----------------- | -------- | ---------------------- |
    | MirrorSender      | Address  | Mirror sender          |
    | BEP20Addr         | Address  | BEP20 token address    |
    | BEP20Decimals     | uint8    | BEP20 decimals         |
    | BEP2Symbol        | bytes32  | BEP2 token symbol      |
    | MirrorFee         | uint256  | Mirror fee from sync package |
    | ErrorCode         | uint8    | 1. Expired time is passed <br/>2. Duplicated BEP2 symbol <br/>3. Already bound <br/>4. Unknown reason |
    1. RLP decode ack package.
    2. If ErrorCode is non-zero:
        1. Refund MirrorFee to mirror sender
        2. Emit bound failure event
    3. If ErrorCode is zero:
        1. Transfer SyncFee to TokenHub
        2. Write the bound pair to TokenHub
        3. Mark the bep20 token as bound by mirror
        4. Emit bound success event

#### 5.1.2 Sync

##### 5.1.2.1 Parameters

| **Param Name**    | **Type** | **Description**        |
| ----------------- | -------- | ---------------------- |
| BEP20Addr         | Address  | BEP20 contract address |
| ExpiredTime       | uint64   | The deadline to deliver this package on BC |
| msg.value         | uint256  | Sum of cross chain fee and sync fee. |

##### 5.1.2.2 Pre-check

1. Ensure the BEP20 is bound by mirror.
2. Ensure msg.value >= SyncFee + CrossChainFee and msg.value = N * 10^10
3. Ensure the equivalent total supply on BC doesn’t exceed the maximum limit
4. Ensure expired time is earlier than one day later and no earlier than two minutes later.

##### 5.1.2.3 Core mechanism

1. Transfer CrossChainFee to TokenHub
2. RLP encode sync total supply package:

    | **Param Name**    | **Type** | **Description**        |
    | ----------------- | -------- | ---------------------- |
    | SyncSender        | Address  | Sync sender            |
    | BEP20Addr         | Address  | BEP20 token address    |
    | BEP2Symbol        | bytes32  | BEP2 token symbol      |
    | BEP20Supply       | uint256  | BEP20 total supply     |
    | SyncFee           | uint256  | Sum of cross chain fee and sync fee |
    | ExpiredTime       | uint64   | The package expired time, counted by second |

3. Call CrossChain contract to send a cross chain package.

##### 5.1.2.4 Handle ack packages

1. Fail ack package:
    1. RLP decode sync total supply package.
    2. Refund SyncFee to users.

2. Ack package:

    | **Param Name**    | **Type** | **Description**        |
    | ----------------- | -------- | ---------------------- |
    | SyncSender        | Address  | Sync sender            |
    | BEP20Addr         | Address  | BEP20 token address    |
    | SyncFee           | uint256  | Sync fee from sync package |
    | ErrorCode         | uint8    | 1. Not bound by mirror <br/>2. Expired time is passed <br/>3. Unknown reason |

    1. RLP decode ack package.
    2. If ErrorCode is non-zero:
        1. Refund SyncFee to sync sender
        2. Emit sync failure event
    3. If ErrorCode is zero:
        1. Transfer SyncFee to TokenHub
        2. Emit sync success event

### 5.1.3 Implement Parameter Update Interface

Two governance parameters will be imported into TokenManager contract: MirrorFee and SyncFee. TokenManager contract needs to implement the following method:
function updateParam(string calldata key, bytes calldata value)

| **Key**           | **Value**       | **Value Type**     |
| ----------------- | --------------- | ------------------ |
| "BEP2MirrorFee"   | BEP2 mirror fee | uint256            |
| "BEP2SyncFee"     | BEP2 sync fee   | uint256            |

## 5.2 BC Bridge

### 5.2.1 Mirror Channel

1. RLP decode mirror package. Generate a fail ack package if failed.
2. Ensure expiredTime is not passed.
3. Ensure the bep20 contract is not bound.
4. Convert BEP20 total supply to the total supply on BC and Ensure the total supply doesn’t exceed the maximum limit of BEP2.
5. Issue a new BEP2 token, the suffix should be the hash of oracle payload and current channel sequence. Besides, the new BEP2 token owner will be the pure-code-controlled-escrow address.
6. Transfer all tokens to the pure-code-controlled-escrow address and write BEP20 address and decimals to the BEP2 token attribution table.
7. Unlock mirror fee from peg account to BC fee pool, so that validators can get these fees.
8. If all above steps are successful, generate a success ack package. The mirrorFee in ack package should equal to the value in sync package. Otherwise, generate an ack failure package.

### 5.2.2 Sync Total Supply Channel

1. RLP decode mirror package. Generate a fail ack package if failed.
2. Ensure expiredTime is not passed
3. Convert BEP20 total supply to BEP2 total supply and ensure the total supply doesn’t exceed the maximum limit of BEP2.
4. Mint/Burn
    1. BSC total supply > BC total supply, mint BEP2 and transfer all new minted tokens to the pure-code-controlled-escrow address.
    2. BSC total supply == BC total supply, nothing to do
    3. BSC total supply > BC total supply, burn BEP2 from the pure-code-controlled-escrow address.
5. Unlock sync fee from the pure-code-controlled-escrow address to BC fee pool.
6. If all above steps are successful, generate a success ack package. The mirrorFee in ack package should equal to the value in sync package. Otherwise, generate an ack failure package.

## 5.3 Proposals to Enable New Channels
After BC and BSC are both upgraded, submit a proposal on BC to add two channels:
1. Mirror channel
    1. Channel id: 4
    2. Handler address: 0x0000000000000000000000000000000000001008
    3. Is reward from systemReward: false
2. Sync total supply channel:
    1. Channel id: 5
    2. Handler address: 0x0000000000000000000000000000000000001008
    3. Is reward from systemReward: false


## 6. License
The content is licensed under [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
