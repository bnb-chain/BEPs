<pre>
  BEP: XXX
  Title: One-Block Finality
  Status: Draft
  Type: Standards
  Created: 2026-01-12
  Description: Enable one-block finality by determining finality through in-memory vote pools, without waiting for votes to be included in block headers.
</pre>

# BEP-XXX: One-Block Finality

- [BEP-XXX: One-Block Finality](#bep-xxx-one-block-finality)
	- [1. Summary](#1-summary)
	- [2. Abstract](#2-abstract)
	- [3. Motivation](#3-motivation)
	- [4. Specification](#4-specification)
	- [5. Security](#5-security)
	- [6. Backward Compatibility](#6-backward-compatibility)
	- [7. License](#7-license)

## 1. Summary

This BEP proposes an optimization to the Fast Finality mechanism introduced in [BEP-126](./BEP126.md), allowing nodes to finalize blocks immediately upon receiving 2/3+ validator votes in memory, without waiting for these votes to be included in subsequent block headers.

## 2. Abstract

[BEP-126](./BEP126.md) introduced Fast Finality on BNB Smart Chain, where a block becomes finalized after two subsequent blocks include vote attestations. This BEP decouples finality from block production by enabling **in-memory finality determination**.

Under the current design:
* A block is **justified** when its attestation appears in the next block's header
* A block is **finalized** when both it and its direct child are justified
* Finality requires **at least 2 subsequent blocks**

This BEP proposes:
* A block is **justified** when ⅔+ validators' votes are received in the local vote pool
* A **justified** block is **immediately finalized** when ⅔+ validators' votes for its direct child are received
* This enables **one-block finality** under typical network conditions
* Block headers continue to include attestations as per BEP-126 for backward compatibility

This change maintains all security guarantees of BEP-126 while significantly reducing finality latency.

## 3. Motivation

In BEP-126, finality depends on votes being included in subsequent block headers. However, validators vote within milliseconds while blocks are produced every 0.45 seconds. This means finality waits for block production even when ⅔+ validators have already voted.

**Key Insight**: Once a node receives ⅔+ valid votes in its vote pool, it has sufficient cryptographic evidence to determine finality immediately.

This BEP enables **one-block finality** by decoupling finality determination from block production, while maintaining all BEP-126 security guarantees.

## 4. Specification

We extend [BEP-126](./BEP126.md) finality rules to support in-memory determination:

**Notation** (from BEP-126):
* `V`: total number of active validators
* `s`: source block hash (latest justified block)
* `t`: target block hash (block being voted for)
* `h(x)`: height of block x
* `<v, s, t, h(s), h(t)>`: validator v's vote message
* `votes(B)`: set of valid votes in local vote pool with target B

**Extended Justification Rule**:

A block B is **justified** if:
1. It is the root block, **OR**
2. ⅔+ validators' attestation for B appears in block h(B)+1's header (original BEP-126), **OR**
3. The local vote pool contains valid votes for B from at least `⌈2/3 × V⌉ + 1` validators (**new**)

Formally:
```
B is justified ⟺ (B is root) ∨ (attestation(B) ∈ header(h(B)+1)) ∨ (|votes(B)| ≥ ⌈2/3 × V⌉ + 1)
```

**Extended Finalization Rule**:

A block B is **finalized** if:
1. It is the root block, **OR**
2. B is justified **AND** B's direct child (h(B)+1) is justified

This remains unchanged from BEP-126, but now benefits from immediate justification.

**Practical Effect**: When ⅔+ votes for block N+1 arrive, both:
* Block N+1 becomes justified (via rule 3)
* Block N becomes finalized (assuming N was already justified)

**Implementation Note**: Nodes should check for finality after receiving each vote, and emit finality events for newly finalized blocks.

## 5. Security

This BEP preserves all BEP-126 security guarantees. Finality determination moves from on-chain (header attestations) to off-chain (vote pool), but both rely on the same cryptographic proof.

**Key Property**: Once ⅔+ valid votes for a block exist, that block is cryptographically finalized. All future finalized blocks must include it as an ancestor, per BEP-126 accountable safety. Observation timing does not change this property.

**Network Delay Scenario**: Block N+1 header includes attestation for N (N justified). Most nodes receive ⅔+ votes for N+1, immediately observing N as finalized. A proposer with network delay does not receive these votes.

**Safety Analysis**:
1. **Chain consensus preserved**: The proposer produces block N+2 with parent N+1. Chain structure N → N+1 → N+2 is valid
2. **N is finalized or ancestor**: Once ⅔+ votes for N+1 exist, N is cryptographically finalized. N+2 and all future finalized blocks include N as ancestor
3. **No conflicting finality possible**: BEP-126 voting rules prevent ⅓+ validators from voting for conflicting chains. Since voting rules are unchanged, observation timing cannot create safety violations

## 6. Backward Compatibility

This BEP is **fully backward compatible**. It does not change consensus rules, block validation, block headers, or vote aggregation.

Finality determination is a client-side optimization. Upgraded nodes observe faster finality via in-memory vote pools, while non-upgraded nodes continue using header-based finality. Network stability is unaffected.

This can be deployed as a client upgrade without requiring network-wide coordination or hard fork activation.

## 7. License

The content is licensed under [Creative Commons CC0 1.0 Universal License](https://creativecommons.org/publicdomain/zero/1.0/).

