```
BAP: xxxx
Title: Post Quantum Evidence Anchor Standard
Status: Draft
Type: Application
Created: 2026-10-15
```

# BAP-xxxx: Post Quantum Evidence Anchor Standard

- [BAP-xxxx: Post Quantum Evidence Anchor Standard](#bap-xxxx-post-quantum-evidence-anchor-standard)
  - [1. Summary](#1-summary)
  - [2. Abstract](#2-abstract)
  - [3. Motivation](#3-motivation)
  - [4. Specification](#4-specification)
    - [4.1 Commitment](#41-commitment)
    - [4.2 Anchor event](#42-anchor-event)
    - [4.3 Interface](#43-interface)
    - [4.4 Verification](#44-verification)
  - [5. Rationale](#5-rationale)
  - [6. Backward Compatibility](#6-backward-compatibility)
  - [7. Security Considerations](#7-security-considerations)
  - [8. Reference Implementation](#8-reference-implementation)
  - [9. Copyright](#9-copyright)

## 1. Summary

A standard way for an application on BNB Smart Chain to anchor a post quantum commitment to an off chain record, so that a third party can later prove the record existed in one exact form at a block time, without the record itself ever reaching the chain.

## 2. Abstract

Regulated firms and AI agent operators increasingly need durable evidence that a record existed and was not altered. This standard defines a fixed commitment format and a single anchor event. An application computes a salted SHA3-256 fingerprint of a record on its own systems, binds it to the signer and a declared record kind, and writes only that 32 byte commitment on chain. The record stays private. A verifier reconstructs the commitment from the record and matches it against the event.

The commitment is a keccak256 preimage of public values, so the standard is useful today. It is also ready for the post quantum account keys described in the BNB Chain roadmap, since the signer field binds the anchor to whichever account scheme is active.

## 3. Motivation

BNB Chain already standardises AI agents through BAP-578. An agent that acts on behalf of a user needs to show, later and to an auditor, exactly what it did and when. Anchoring a hash on chain gives that proof a public, time ordered home that no single party can rewrite. Keeping the record off chain keeps the data private and the cost constant, one event per batch of up to 1,048,576 records.

## 4. Specification

The key words MUST, MUST NOT, SHOULD and MAY are to be interpreted as in RFC 2119.

### 4.1 Commitment

For a record `R`, a 16 byte random salt `s`, a signer address `a` and a record kind `k` encoded as a bytes32, the fingerprint and commitment are

```
fingerprint = sha3_256(s || R)
commitment  = keccak256(abi.encode(fingerprint, a, k))
```

`fingerprint` is computed off chain. `commitment` is the value written on chain. An application MUST use a fresh salt for every record and MUST NOT publish the salt or the record on chain.

### 4.2 Anchor event

A conforming contract MUST emit exactly this event for every anchored commitment.

```
event Anchored(
    address indexed signer,
    bytes32 indexed kind,
    bytes32 commitment,
    uint64  batchSize,
    uint256 timestamp
);
```

`signer` is the account that authorised the anchor. `kind` is the declared record kind. `commitment` is the value from 4.1. `batchSize` is the number of records covered by a Merkle root when the commitment is a root, or 1 for a single record. `timestamp` is the block timestamp.

### 4.3 Interface

```
interface IPostQuantumEvidenceAnchor {
    event Anchored(
        address indexed signer,
        bytes32 indexed kind,
        bytes32 commitment,
        uint64  batchSize,
        uint256 timestamp
    );

    function anchor(bytes32 commitment, bytes32 kind, uint64 batchSize) external;

    function anchored(bytes32 commitment) external view returns (uint256 timestamp);
}
```

`anchor` records a commitment and emits the event. `anchored` returns the block timestamp at which a commitment was first recorded, or zero if it was never recorded.

### 4.4 Verification

A verifier holding the record, the salt, the signer address and the record kind recomputes the commitment as in 4.1 and reads `anchored(commitment)`. A non zero timestamp proves the record existed in that exact form at or before that time. For a batch, the verifier checks that the record's fingerprint is a leaf of the Merkle root committed on chain, using the standard sorted pair keccak256 construction.

## 5. Rationale

The commitment binds the fingerprint to the signer and the record kind so that the same fingerprint anchored by two parties yields two distinct commitments, which prevents one party claiming another party's anchor. A single event keeps indexing simple for wallets and explorers. Anchoring a Merkle root keeps the cost of a large batch at one transaction.

## 6. Backward Compatibility

This standard adds a new application contract and changes no existing contract or protocol rule. It is independent of the account signature scheme, so it continues to work unchanged when post quantum account keys are activated.

## 7. Security Considerations

The record never leaves the application, so the chain never holds private data. The salt makes the fingerprint resistant to a dictionary attack on low entropy records. keccak256 and SHA3-256 both retain about 128 bits of security against a quantum search, so the commitment is sound against a future quantum adversary. The standard proves existence and integrity. It does not prove correctness of the record or authority to create it, which are the concern of other tools.

## 8. Reference Implementation

A reference contract and a verification library are provided with this proposal. The contract stores the first seen timestamp per commitment, rejects a zero commitment and rejects a batch size of zero, and holds no owner, no upgrade path and no privileged function.

## 9. Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
