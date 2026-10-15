```
BEP: <TBD>
Title: Post Quantum Algorithm Registry and Versioned Envelopes
Status: Draft
Type: Standards
Created: 2026-10-15
Description: Define a single algorithm registry and a self describing versioned envelope for post quantum keys, signatures and commitments on BNB Chain, so that every later phase of the post quantum roadmap dispatches on a declared identifier instead of on field width.
```

# BEP-draft: Post Quantum Algorithm Registry and Versioned Envelopes

- [1. Abstract](#1-abstract)
- [2. Motivation](#2-motivation)
- [3. Specification](#3-specification)
  - [3.1 Algorithm registry](#31-algorithm-registry)
  - [3.2 Object kinds](#32-object-kinds)
  - [3.3 Versioned envelope](#33-versioned-envelope)
  - [3.4 Decoding](#34-decoding)
  - [3.5 Validation](#35-validation)
  - [3.6 Governance of the registry](#36-governance-of-the-registry)
- [4. Rationale](#4-rationale)
- [5. Backward Compatibility](#5-backward-compatibility)
- [6. Security Considerations](#6-security-considerations)
- [7. Reference Implementation](#7-reference-implementation)
- [8. Copyright](#8-copyright)

## 1. Abstract

This BEP delivers the crypto agility foundation named in the BNB Chain post quantum roadmap (BEP-713, Phase 0). It defines one registry of 16 bit identifiers for post quantum signature schemes, key encapsulation mechanisms and commitment functions, and one self describing envelope that carries an object together with the identifier of the scheme that produced it. A verifier reads the identifier, looks up the fixed rules for that scheme and object kind, and dispatches, rather than inferring the algorithm from the width of a field. Nothing in this BEP changes consensus behaviour. It is the format on which the Phase 2 account and signature work, and the Phase 3 pairing work, are intended to build.

## 2. Motivation

BSC encodes which algorithm is in use implicitly almost everywhere, by field position and length. A 65 byte signature is ECDSA because nothing else fits. A 48 byte vote key is BLS12-381 for the same reason. A verifier cannot be told to use a different algorithm, so a field can only be replaced wholesale, which is a fork. EIP-4844 is the one place BSC already declares the scheme explicitly, through the leading byte of a versioned hash, and that is the pattern this BEP generalises.

Allocating identifiers once, before the Phase 2 and Phase 3 formats ship, is cheap. Allocating them after those formats are in use is a second fork. BEP-708 already carries a `kem-group` identifier with its own registry. Without a shared registry, the Phase 2 transaction type would define a second convention and Phase 3 a third. This BEP provides the single convention.

## 3. Specification

The key words MUST, MUST NOT, REQUIRED, SHALL, SHOULD and MAY are to be interpreted as in RFC 2119.

### 3.1 Algorithm registry

An algorithm identifier is a 16 bit unsigned integer. The initial registry is

| Identifier | Scheme | Class | Standard |
| --- | --- | --- | --- |
| `0x0000` | reserved, never valid | | |
| `0x0001` | ML-DSA-44 | signature | FIPS 204 |
| `0x0002` | ML-DSA-65 | signature | FIPS 204 |
| `0x0003` | ML-DSA-87 | signature | FIPS 204 |
| `0x0004` | SLH-DSA-SHA2-128s | signature | FIPS 205 |
| `0x0005` | FN-DSA-512 | signature | FIPS 206 draft |
| `0x0101` | ML-KEM-768 | kem | FIPS 203 |
| `0x0201` | SHA3-256 | commitment | FIPS 202 |
| `0x0202` | KECCAK-256 | commitment | Ethereum Keccak |

Identifiers above `0x8000` are reserved for private and experimental use and MUST NOT appear in consensus data. All other unlisted values are reserved for future BEPs.

### 3.2 Object kinds

An object kind is an 8 bit unsigned integer naming what the payload is.

| Kind | Meaning | Valid classes |
| --- | --- | --- |
| `0x01` | public key | signature, kem |
| `0x02` | signature | signature |
| `0x03` | commitment digest | commitment |
| `0x04` | KEM ciphertext | kem |
| `0x05` | key seed | signature |

A decoder MUST reject an envelope whose object kind is not valid for the class of its identifier.

### 3.3 Versioned envelope

A versioned envelope is

```
envelope = version || algId || kind || body
version  = 0x01            // 1 byte, this envelope format version
algId    = uint16          // 2 bytes, big endian, from the registry
kind     = uint8           // 1 byte, object kind
body     = scheme defined  // the object bytes
```

The four byte header is fixed. An encoder MUST set `version` to `0x01`. Future header changes take a new version value.

### 3.4 Decoding

A decoder MUST perform these steps in order and MUST abort on the first failure.

1. The envelope is at least four bytes.
2. `version` equals `0x01`.
3. `algId` is present in the registry and is not `0x0000`.
4. `kind` is valid for the class of `algId` per 3.2.
5. `len(body)` satisfies the length rule for `(algId, kind)` in 3.5.

A decoder MUST NOT infer the algorithm from `len(body)`. The identifier is authoritative and the length is only a check.

### 3.5 Validation

Each `(algId, kind)` pair has a fixed length rule. Fixed length objects require an exact length. FN-DSA-512 signatures are variable and require a length within the inclusive band.

| Scheme | public key | signature | seed | ciphertext |
| --- | --- | --- | --- | --- |
| ML-DSA-44 | 1312 | 2420 | 32 | |
| ML-DSA-65 | 1952 | 3309 | 32 | |
| ML-DSA-87 | 2592 | 4627 | 32 | |
| SLH-DSA-SHA2-128s | 32 | 7856 | | |
| FN-DSA-512 | 896 | 617 to 666 | | |
| ML-KEM-768 | 1184 | | | 1088 |
| SHA3-256 | | | | |
| KECCAK-256 | | | | |

A commitment digest body (`kind 0x03`) is exactly 32 bytes.

An implementation MAY additionally apply the scheme level validation that the underlying standard defines, for example the FIPS 203 Section 7.2 modulus check on an ML-KEM-768 encapsulation key, or the FIPS 204 Algorithm 6 recomputation on an ML-DSA private key. Where it does, a failing object MUST be rejected and the envelope treated as invalid.

### 3.6 Governance of the registry

A new identifier is added by a BEP that gives the scheme, the class, the standard reference and the length rule for every object kind it supports. An identifier is never reused for a different scheme. A scheme is deprecated by a BEP that marks its identifier deprecated, and consensus code MUST then reject new objects under it while continuing to verify existing ones until a wind down BEP removes them.

## 4. Rationale

A 16 bit identifier matches the `kem-group` width already used in BEP-708 and leaves ample room. A one byte object kind keeps a public key and a signature of the same scheme distinct without a second identifier. The four byte header is a small fixed cost against the multi kilobyte post quantum objects it describes. The design copies the EIP-4844 precedent that BSC already trusts, and lifts it from one commitment type to the whole post quantum surface.

## 5. Backward Compatibility

This BEP adds an encoding and changes no existing format, so it has no effect until a later BEP adopts it. Existing ECDSA and BLS fields are untouched. A later phase that adopts the envelope does so in its own new format, never by rewrapping a field already in use.

## 6. Security Considerations

The identifier is authoritative, which removes the class of confusion where an object of one scheme is accepted as another because their lengths coincide. A decoder rejects an unknown identifier rather than guessing, so a downgrade to a weaker reserved scheme fails closed. The envelope carries no secret and provides no integrity of its own, so it MUST be used inside a context that authenticates it, for example a signed transaction or an authenticated handshake, exactly as the bare fields are today. Length validation is a defence against truncation and padding, not a substitute for the scheme level checks in 3.5.

## 7. Reference Implementation

A reference encoder, decoder and registry with test vectors are provided with this proposal. The decoder follows Section 3.4 exactly and refuses to dispatch on length. The test vectors cover a valid envelope for every registry entry and rejection of a wrong version, an unknown identifier, a mismatched object kind, and every out of band length.

## 8. Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
