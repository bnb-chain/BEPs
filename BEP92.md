# BEP-92: Implementation of SHA3-256 FIPS 202 hash and EcRecover Uncompressed public key precompiled contracts

- [BEP-92: Implementation of SHA3-256 FIPS 202 hash precompiled and EcRecover Uncompressed public key precompiled](#bep-92)
  - [1. Summary](#1-summary)
  - [2. Abstract](#2-abstract)
  - [3. Status](#3-status)
  - [4. Motivation](#4-motivation)
  - [5. Specification](#5-specification)
  - [6. Gas Consumption](#6-gas)
  - [7. Test Data](#7-testdata)
  - [8. License](#6-license)
  
## 1. Summary

This BEP describes a proposal for Implementation of SHA3-256 as precompiled for BSC

## 2. Abstract

BEP-92 Proposal describes a addition of implementation of SHA3-256 FIPS 202 hash and EcRecover Uncompressed public key methods as precompiled native contracts

## 3. Status

This BEP is a Work in Progress(WIP). 

## 4. Motivation

This BEP proposing to enable more interoperability capablilities for Binance Smart Chain to verify sha3-256 based blockchains in the likes of ICON republic.

- In order to validate the merkle tree data from blockchains which uses SHA3-256 hashing functions.
- Used to recover & validate public key from signatures of validators.
- Any blockchain using SHA3-256 FIPS 202 standard will need these preompiles interoperate with EVM based blockchains. Hence the need for both hashing & recover functions based on SHA3-256.

## 5. Specification

Ethereum based virtual machines uses Keccak-256 hashing algorithm to evaulate blocks, but most of the modern blockchains adapted SHA3-256,(slightly different padding rule) as part of [NIST FIPS 202](#https://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.202.pdf).

## 6. Gas

SHA3-256 is in the same family as keccak256. Hence the gas price consumption for hash operation will be similar to existing Keccak operation.
Hence,
```
Gsha3 = 30 
(Paid for each SHA3 operation.)
Gsha3word = 6 
(Paid for each word (rounded up) for input data to a SHA3 operation)
```
Reference:
[Ethereum:Yellow Paper](https://www.win.tue.nl/~mholende/seminar/references/ethereum_yellowpaper.pdf) - appendix G (Fee Schedule)

## 7. TestData

Test data to be used to validate the output of the proposed precompiled contract functions.

sha3fips
params
```
data : ‘0x0448250ebe88d77e0a12bcf530fe6a2cf1ac176945638d309b840d631940c93b78c2bd6d16f227a8877e3f1604cd75b9c5a8ab0cac95174a8a0a0f8ea9e4c10bca’
returns : ‘0xc7647f7e251bf1bd70863c8693e93a4e77dd0c9a689073e987d51254317dc704’
```

ecrecoverPublicKey
params
```
hash : ‘0xc5d6c454e4d7a8e8a654f5ef96e8efe41d21a65b171b298925414aa3dc061e37’
v : ‘0x00’
r : ‘0x4011de30c04302a2352400df3d1459d6d8799580dceb259f45db1d99243a8d0c’
s : ‘0x64f548b7776cb93e37579b830fc3efce41e12e0958cda9f8c5fcad682c610795’
returns : ‘0x0448250ebe88d77e0a12bcf530fe6a2cf1ac176945638d309b840d631940c93b78c2bd6d16f227a8877e3f1604cd75b9c5a8ab0cac95174a8a0a0f8ea9e4c10bca’
```

## 6. License

The content is licensed under [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
