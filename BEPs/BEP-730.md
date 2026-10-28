<pre>
  BEP: 730
  Title: Recovery of Binance-Peg BEP20 Tokens Stranded at ZK Stack-Derived Smart-Account Addresses
  Status: Draft
  Type: Standards
  Created: 2026-10-26
  Description: Adds a signature-verified recovery function to the Binance-Peg BEP20 implementation so that tokens sent on BSC to an address that only exists as a ZKsync-CREATE2 smart account on a ZK Stack chain can be moved by the account's initial owner.
</pre>

# BEP-730: Recovery of Binance-Peg BEP20 Tokens Stranded at ZK Stack-Derived Smart-Account Addresses

- [BEP-730: Recovery of Binance-Peg BEP20 Tokens Stranded at ZK Stack-Derived Smart-Account Addresses](#bep-730-recovery-of-binance-peg-bep20-tokens-stranded-at-zk-stack-derived-smart-account-addresses)
  - [1. Summary](#1-summary)
  - [2. Abstract](#2-abstract)
  - [3. Status](#3-status)
  - [4. Motivation](#4-motivation)
    - [4.1 The case](#41-the-case)
    - [4.2 The class](#42-the-class)
    - [4.3 Why no on-chain path exists today](#43-why-no-on-chain-path-exists-today)
  - [5. Specification](#5-specification)
    - [5.1 Interface](#51-interface)
    - [5.2 ZKsync CREATE2 address formula](#52-zksync-create2-address-formula)
    - [5.3 EIP-712 domain and claim](#53-eip-712-domain-and-claim)
    - [5.4 OwnerScheme registry](#54-ownerscheme-registry)
    - [5.5 Verification steps](#55-verification-steps)
    - [5.6 Nonce and deadline](#56-nonce-and-deadline)
    - [5.7 Code-less requirement](#57-code-less-requirement)
    - [5.8 Relayer model](#58-relayer-model)
    - [5.9 Events](#59-events)
  - [6. Rationale](#6-rationale)
  - [7. Backward Compatibility](#7-backward-compatibility)
  - [8. Security Considerations](#8-security-considerations)
  - [9. Reference Implementation](#9-reference-implementation)
  - [10. Precedents](#10-precedents)
  - [11. License](#11-license)

## 1. Summary

Binance-Peg BEP20 tokens sent on BSC to the address of an Abstract Global Wallet (or any other ZKsync-CREATE2 smart account) cannot be moved by anyone, because no private key, no EVM deployment, no EIP-7702 delegation and no past BSC hard fork can make that address `msg.sender` on BSC. This proposal adds one function to the Binance-Peg token implementation that moves such a balance to a destination chosen by the account's initial owner, after verifying on-chain that the stranded address is the ZKsync-CREATE2 output of a registered factory, that the deployment salt is the hash of the signer, and that the signer authorised the move with an EIP-712 signature.

## 2. Abstract

A ZK Stack chain (Abstract, zkSync Era and others) derives contract addresses with `keccak256("zksyncCreate2")` as the prefix instead of the EVM's `0xff`, so a smart account deployed there occupies an address that no EVM chain can ever deploy to. When a user copies that address out of a ZK Stack wallet and receives a BSC token at it, the balance is recorded in the token contract's storage under an address that has no key and can never have code on BSC. The token contract is the only place where that storage can be changed.

The Binance-Peg tokens are EIP-1967 upgradeable proxies administered by Binance. The proposal specifies a V2 implementation that adds, without touching existing storage or existing behaviour, an append-only `recoverStrandedZkAccount` entry point. A claim is valid when (a) the stranded address has no code on BSC, (b) it equals the ZKsync-CREATE2 address of a `(factory, salt, bytecodeHash, constructorInput)` tuple, (c) the factory is registered by the token owner together with the rule that binds its salt to the account's initial owner, (d) the salt equals `keccak256(abi.encodePacked(signer))`, and (e) `signer` is recovered from an EIP-712 signature over `(stranded, to, amount, nonce, deadline)`. Anyone may relay the signed claim; the signature fixes the destination and amount. The verification is a hash comparison plus `ecrecover`; no off-chain approval server, no manual review, no consensus change.

## 3. Status

Draft.

## 4. Motivation

### 4.1 The case

All figures below were read from BSC public RPC on 2026-10-25/26 (head block 129,781,795) and from Abstract RPC on 2026-10-25.

- BSC tx `0x512b66bef7392f9d1dd8fc3a9ee9234bd87dfdb7b0cd5c0395010f6576491f20`, block 80,681,471, 2026-02-11 23:25:06 UTC, status 1. `from` is Binance hot wallet `0xe2fc31f816a9b94326492132018c3aecc4a93ae1`. One `Transfer` log: 19,998.0 Binance-Peg USDC (`0x8ac76a51cc950d9822d68b83fe1ad97b32cd580d`, 18 decimals) to `0x6ae0145e60b073e8c47b922f16c0f9e71e3efa86`.
- `balanceOf(0x6ae0…fa86)` at head block 129,781,795 is `0x43c1800260e15b80000` = 19,998.0 tokens. The balance has not moved.
- On BSC, `0x6ae0…fa86` has code length 0, nonce 0 and 0.0014 BNB.
- On Abstract (chain 2741), `0x6ae0…fa86` has 1,632 bytes of code and nonce 11,620: an active Abstract Global Wallet (AGW).
- The address is the ZKsync-CREATE2 output of the AGW `AccountFactory` `0x9b947df68d35281c972511b3e7bc875926f26c1a` with salt `0x9c40f26d0e218dc6219fe7bae7b50af65cd87a6e1da558c4fa7bdaa33fad5185` = `keccak256(0x07c65fe9f29a86b937604fa8d20a3fae19d7be48)`, bytecodeHash `0x0100003316a98e88b9e8931575675eed8e30eee97abeff3816fb98333ab085bc` and constructorInput `abi.encode(0xaa3633b417483f932969edaef7cc4f1068f6faa9)`. Recomputing the formula in §5.2 reproduces `0x6ae0…fa86` exactly. The creation tx on Abstract is `0xcdb63bfcbb7eab1f404dc9de6b79e787048f38307b1abce9fa5557405d7d5b9f`, block 101,456.
- The same inputs through the EVM CREATE2 formula give `0xbe2b2ffe38b18b1094c1cc24126ac140530f8d4f`, which has no code on BSC. No EVM deployment reproduces the stranded address.
- Binance-Peg USDC is an EIP-1967 proxy: implementation slot holds `0xba5fe23f8a3a24bed3236f05f2fcf35fd0bf0b5c` (5,066 bytes), admin slot holds `0xd2f93484f2d319194cba95c5171b18c1d8cfd6c4` (EOA, nonce 175), `getOwner()` returns `0xf68a4b64162906eff0ff6ae34e2bb1cd42fef62d`. The implementation is `BEP20TokenImplementation.sol` from `github.com/bnb-chain/canonical-upgradeable-bep20` (archived read-only on 2022-09-14). Its external surface is standard BEP20 plus `mint(uint256)`, `burn(uint256)`, `transferOwnership`, `renounceOwnership`, `getOwner`. It has no blacklist, no recovery, no permit and no pause function.

### 4.2 The class

Abstract (Igloo Inc) announced on 2026-10-07 that the chain shuts down on 2026-12-15. Its FAQ states: "Do NOT send funds to your Abstract Global Wallet on any other network. Your AGW only exists on Abstract." and that the wallet "does not have a private key for you to export". The Abstract feedback board (feedback.abs.xyz) carries many identical reports of funds sent to an AGW address on Arbitrum, Base and Polygon since January 2025. Abstract's relayed position is that losses on non-ZK-Stack chains are unrecoverable and that ZK Stack chains "may be recoverable in the future". BSC is in the first group. The number of such BSC addresses and the total value stranded are unmeasured; this proposal was written against one case of 19,998 USDC and a public bounty of $15,000 for its recovery (x.com/eth_apple/status/2114351107086647600, 2026-10-25 13:39 UTC).

The AGW SDK (`github.com/Abstract-Foundation/agw-sdk`) accepts only chains 2741, 11124, 324 and 300; `wallet_switchEthereumChain` to any other chain throws "Chain N not supported". The wallet cannot be pointed at BSC, so the balance cannot be spent from the wallet software either.

### 4.3 Why no on-chain path exists today

A BEP20 balance moves when the token contract's `_transfer` runs with the holder as `msg.sender` (or as the `from` of an approved `transferFrom`, which first needs an `approve` with the holder as `msg.sender`). There are exactly four ways an address becomes `msg.sender` on BSC. Each fails for a ZKsync-CREATE2 address:

1. **Private key.** The address is the output of a hash over `(factory, salt, bytecodeHash, constructorInput)`; it was never derived from a key. Nobody holds a key for it, Abstract included.
2. **Code at the address via CREATE or CREATE2.** CREATE from the factory would need the factory to exist at `0x9b94…6c1a` on BSC (it has no code there; it was itself deployed by the ZKsync system `Create2Factory` at `0x0000000000000000000000000000000000010000`, an address no EVM transaction can deploy to) and to reach a specific nonce. CREATE2 on BSC uses `keccak256(0xff ‖ deployer ‖ salt ‖ initcodeHash)`; with the case's inputs it yields `0xbe2b2ffe…8d4f`, not `0x6ae0…fa86`. Hitting `0x6ae0…fa86` by any EVM CREATE2 requires a 160-bit preimage of keccak256.
3. **EIP-7702 delegation ([BEP-441](./BEP-441.md)).** A set-code authorisation must be signed by the address's own key. See (1).
4. **Consensus change.** A hard fork could write code or balances at `0x6ae0…fa86`. BSC hard forks have only ever written code to the reserved system range: every upgrade target in the client's `core/systemcontracts/upgrade.go` (Bruno through Pasteur) resolves to one of the 18 addresses defined in `core/systemcontracts/const.go` (`0x…1000`–`0x…1008`, `0x…2000`–`0x…2007`, `0x…3000`), checked against the `bnb-chain/bsc` source on 2026-10-26. No BSC fork has written code to a user address, and doing so for individual victims does not scale to a class of losses.

What remains is the token contract itself: its storage holds the balance, and the token is an administered upgradeable proxy. A change to the implementation is the only place a fix can live without changing BSC.

## 5. Specification

### 5.1 Interface

The V2 implementation adds the following to `BEP20TokenImplementation`. Names and signatures are normative.

```solidity
struct ZkDeployment {
    address factory;          // ZK Stack deployer of the account (the address that called the ContractDeployer)
    bytes32 salt;             // CREATE2 salt as passed on the ZK Stack chain
    bytes32 bytecodeHash;     // ZKsync-format bytecode hash (version byte 0x01, length in 32-byte words at bytes [2:4])
    bytes   constructorInput; // ABI-encoded constructor arguments as passed on the ZK Stack chain
}

struct RecoveryClaim {
    address stranded;         // the ZKsync-CREATE2 address holding the balance on BSC
    address to;               // destination on BSC
    uint256 amount;           // token amount in base units; 0 means the full balance at execution
    uint256 nonce;            // must equal recoveryNonce(stranded)
    uint256 deadline;         // unix time; claim is invalid when block.timestamp > deadline
}

enum OwnerScheme { NONE, SALT_IS_KECCAK_OF_INITIAL_OWNER }

struct FactoryScheme {
    OwnerScheme scheme;             // NONE = not registered
    bytes32 bytecodeHash;           // the only account bytecode hash accepted for this factory
    bytes32 constructorInputHash;   // keccak256 of the only constructorInput accepted for this factory
}

function setZkFactoryScheme(address factory, OwnerScheme scheme, bytes32 bytecodeHash, bytes32 constructorInputHash) external; // onlyOwner; scheme NONE clears the entry
function zkFactoryScheme(address factory) external view returns (OwnerScheme scheme, bytes32 bytecodeHash, bytes32 constructorInputHash);
function recoveryNonce(address stranded) external view returns (uint256);
function recoverStrandedZkAccount(ZkDeployment calldata d, RecoveryClaim calldata c, bytes calldata signature) external;
function zkCreate2Address(ZkDeployment calldata d) external pure returns (address);

event ZkFactorySchemeSet(address indexed factory, OwnerScheme scheme, bytes32 bytecodeHash, bytes32 constructorInputHash);
event StrandedZkAccountRecovered(address indexed stranded, address indexed signer, address indexed to, uint256 amount, address factory);
```

`onlyOwner` is the existing modifier of `BEP20TokenImplementation` (the account returned by `getOwner()`). All other existing functions are unchanged.

### 5.2 ZKsync CREATE2 address formula

`zkCreate2Address(d)` MUST return

```
address(uint160(uint256(keccak256(abi.encodePacked(
    keccak256("zksyncCreate2"),            // 0x2020dba91b30cc0006188af794c2fb30dd8520db7e2c088b7fc7c103c00ca494
    bytes32(uint256(uint160(d.factory))),  // left-padded to 32 bytes
    d.salt,
    d.bytecodeHash,
    keccak256(d.constructorInput)
)))))
```

i.e. the low 20 bytes of the hash. This is the address derivation of the ZK Stack `ContractDeployer` system contract. It differs from EVM CREATE2 (`keccak256(0xff ‖ deployer ‖ salt ‖ keccak256(initcode))`) in the prefix, the padding of the deployer, and in hashing a bytecode hash plus the hash of the constructor input rather than the hash of the init code.

The implementation does not interpret `bytecodeHash` and does not need the account's bytecode. It only verifies that the tuple hashes to `c.stranded`.

### 5.3 EIP-712 domain and claim

The signed message is an EIP-712 typed structure.

Domain:

| Field | Value |
| --- | --- |
| `name` | the token's `name()` (for Binance-Peg USDC: `"USD Coin"`) |
| `version` | `"1"` |
| `chainId` | `56` |
| `verifyingContract` | the token proxy address (for Binance-Peg USDC: `0x8ac76a51cc950d9822d68b83fe1ad97b32cd580d`) |

Domain type string: `EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)`. For Binance-Peg USDC the resulting domain separator is `0xfc877ab7304c7c158d3fd77b876e283f403d7f06af357978e51071ca51fe27b9`.

Claim type:

```
RECOVERY_CLAIM_TYPEHASH = keccak256("RecoveryClaim(address stranded,address to,uint256 amount,uint256 nonce,uint256 deadline)")
                        = 0x835a1ddd6f21721e0341455f19d4804951b583f81b1c0e0418cb09db6a4e0057
structHash = keccak256(abi.encode(RECOVERY_CLAIM_TYPEHASH, c.stranded, c.to, c.amount, c.nonce, c.deadline))
digest     = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash))
```

`signature` is a 65-byte `(r, s, v)` secp256k1 signature over `digest`. `v` MUST be 27 or 28 and `s` MUST be in the lower half of the curve order; any other encoding MUST revert. `signer = ecrecover(digest, v, r, s)`; `signer == address(0)` MUST revert. The domain separator MUST be computed at call time from the current `chainid()` and `address(this)`, not cached at initialization, so that the proxy and any fork of the chain get the correct value.

`c.amount == 0` means "the full `balanceOf(c.stranded)` at execution time". A non-zero `c.amount` is transferred exactly and MUST revert if it exceeds the balance.

### 5.4 OwnerScheme registry

`zkFactoryScheme(factory)` maps a ZK Stack factory address to a `FactoryScheme`: the rule that binds its CREATE2 salt to the deployed account's initial owner, plus the one account `bytecodeHash` and the one `keccak256(constructorInput)` the factory uses. The registry is written only by `setZkFactoryScheme` (`onlyOwner`) and starts empty; every factory is `NONE` until the token owner registers it. A claim whose `d.factory` maps to `NONE`, whose `d.bytecodeHash` differs from the pinned hash, or whose `keccak256(d.constructorInput)` differs from the pinned hash MUST revert. Pinning leaves the salt as the only claim input not fixed by the registry, and the salt is the hash of the signer, so a claimant can only ever name the address they would own under that factory.

For the AGW `AccountFactory` the pinned values are `bytecodeHash = 0x0100003316a98e88b9e8931575675eed8e30eee97abeff3816fb98333ab085bc` and `constructorInputHash = keccak256(abi.encode(address(0xaa3633b417483f932969edaef7cc4f1068f6faa9)))`, read from the account deployments in §4.1 and §5.4.

The one scheme defined by this proposal is `SALT_IS_KECCAK_OF_INITIAL_OWNER`: the factory derives the salt as `keccak256(abi.encodePacked(initialOwner))` where `initialOwner` is the account's initial signing key. The AGW `AccountFactory` `0x9b947df68d35281c972511b3e7bc875926f26c1a` follows this scheme; it was verified against two deployed AGWs (§4.1 case A and a second account whose owner `0x349e6c340625a76f9c7ef76ed826e66cbd5bd7b4` and salt `0x83110841e6184847ecdb526795e56824ed672100843d4bbb7e5365aa7ea81e10` reproduce `0xDb85b9035a02E0cB60bDd33655612930Ab414838`, creation tx `0x61214b7bd7184b0de73d2f9c9b506eafdf295c92c78970d776b4c131f5980367` block 89,579). The factory enforces this derivation on-chain: on zkSync Era, where the same factory code is deployed, `eth_call` of `deployAccount` with the §4.1 initializer and its original salt returns `0x6ae0…fa86`, while the same initializer with any other salt (`keccak256(0x11…11)`, `0x00…00`) reverts with custom error selector `0x8b3152e6` (measured 2026-10-26; error name unmeasured). The registry entry is the token owner's statement that the scheme holds for the factory, and §8 discusses what a wrong entry would mean.

Factories with other owner-binding rules need a new enum member and a new verification branch; they are out of scope for this proposal. A survey of ZK Stack account factories on zkSync Era (companion file `research/ZK_ACCOUNT_SCHEMES.md`, measured 2026-10-26) found AGW to be the only one that binds the owner into the salt: Safe (575,874 deployments on Era) derives the salt from the initializer and a nonce, Argent and two ERC-4337-style factories carry the owner in the constructor input, and Clave carries it only in Era state. The AGW factory alone accounts for 4,252,187 `ContractDeployed` events on Abstract, so the one scheme in this proposal covers the dominant source of this loss class. Setting a factory back to `NONE` disables claims for it.

### 5.5 Verification steps

`recoverStrandedZkAccount(d, c, signature)` MUST perform all of the following checks and revert if any fails. The order below is the reference implementation's order of effects; implementations MAY reorder pure checks as long as the nonce is consumed only when the whole claim succeeds (a reverted call consumes nothing):

1. `block.timestamp <= c.deadline`.
2. `c.nonce == recoveryNonce[c.stranded]`.
3. `c.to != address(0)`, `c.to != c.stranded`, `c.to != address(this)` (the last two would strand the balance again).
4. `c.stranded` has no code on BSC: `extcodesize(c.stranded) == 0` (see §5.7).
5. `zkCreate2Address(d) == c.stranded`.
6. `zkFactoryScheme[d.factory].scheme != NONE`, `d.bytecodeHash == zkFactoryScheme[d.factory].bytecodeHash`, and `keccak256(d.constructorInput) == zkFactoryScheme[d.factory].constructorInputHash`.
7. Recover `signer` from `signature` over the digest of §5.3; `signer != address(0)`, canonical `s`, `v ∈ {27, 28}`.
8. For `SALT_IS_KECCAK_OF_INITIAL_OWNER`: `d.salt == keccak256(abi.encodePacked(signer))`.
9. `amount = c.amount == 0 ? balanceOf(c.stranded) : c.amount`; `amount > 0`; `amount <= balanceOf(c.stranded)`.
10. `recoveryNonce[c.stranded] += 1`.
11. `_transfer(c.stranded, c.to, amount)` — the existing internal transfer, which emits the standard `Transfer(c.stranded, c.to, amount)` event and keeps `totalSupply` unchanged.
12. `emit StrandedZkAccountRecovered(c.stranded, signer, c.to, amount, d.factory)`.

Steps 4–8 are pure state reads and hashing; the function calls no other contract (the reference implementation reads its own `name()` and `balanceOf()` through two self STATICCALLs).

### 5.6 Nonce and deadline

`recoveryNonce` is per stranded address and increments by one per successful recovery. A claim signed for a nonce that has been consumed can never execute again. A partial claim (`c.amount` less than the balance) consumes the nonce; the remainder needs a new claim at the next nonce. `deadline` bounds how long a signed claim stays executable if it is not relayed. Two consequences signers and wallet software MUST account for: a claim with `amount == 0` moves whatever balance the stranded address holds at execution, including deposits that arrive after signing, so a full-balance claim is a bearer sweep until `deadline`; and the token owner can make an outstanding claim unexecutable by clearing the factory's registry entry and executable again by restoring it, since the signature and nonce are unaffected by the registry. Short deadlines limit both.

### 5.7 Code-less requirement

The function MUST revert if `c.stranded` has code on BSC. An address with code on BSC is a contract (or an EIP-7702 delegated account, whose code is the 23-byte delegation designator) and can already act as `msg.sender`; it needs no recovery path and must not be subject to one. This check also guarantees the function can never move funds from any deployed contract.

### 5.8 Relayer model

The caller of `recoverStrandedZkAccount` is unrestricted. The signature fixes `stranded`, `to`, `amount`, `nonce` and `deadline`, so a relayer can only execute the claim as signed or not at all; it cannot redirect funds or change the amount. This lets a third party pay BSC gas for a victim whose signing key may hold no BNB on BSC (for the §4.1 case, the initial owner's BNB balance on BSC is unmeasured). A relayer that front-runs another relayer with the same signed claim causes the second transaction to revert at step 2; the outcome for the signer is identical.

### 5.9 Events

- `ZkFactorySchemeSet(factory, scheme, bytecodeHash, constructorInputHash)` on every `setZkFactoryScheme` call, including resets to `NONE`.
- `StrandedZkAccountRecovered(stranded, signer, to, amount, factory)` on every successful recovery, in addition to the standard `Transfer(stranded, to, amount)`.

## 6. Rationale

**Token-side, not consensus-side.** The balance lives in the token contract's storage. Changing it there needs an implementation upgrade signed by the existing proxy admin and a registry write signed by the existing token owner. No hard fork, no validator coordination, no code written at a user address. BSC itself is untouched and the change cannot affect any other contract.

**Binance already administers these proxies.** The upgradeability and the `mint`/`transferOwnership` powers in the current implementation exist so that Binance can operate the peg. The same administrator today handles wrong-network recovery requests for CEX deposits by manual review. This proposal moves one well-defined class of those requests on-chain, with a cryptographic proof replacing manual review, and leaves the administrator's existing powers exactly as they are.

**Why initial-owner binding via salt is sound.** On the ZK Stack chain the account was created by the factory with `salt = keccak256(initialOwner)`; that salt is an input to the address. A signer who satisfies `keccak256(signer) == salt` and whose tuple hashes to the stranded address is, by construction of the factory, the account's initial owner. The verification therefore proves the same thing the account's own `validateTransaction` would have proved on the ZK Stack chain at creation: the k1 owner signed. The check is deterministic and needs no snapshot, Merkle tree or off-chain data.

**What it does not cover.** Accounts whose factory does not bind the salt to the owner (registry stays `NONE`); accounts whose signing key was rotated after creation (the initial owner, not the current one, is the one who can claim; see §8); accounts whose initial owner is itself a contract (ERC-1271 is not supported; `ecrecover` only); tokens that are not Binance-Peg upgradeable proxies (this proposal changes one implementation contract; other issuers would need to adopt the same interface). Native BNB at such addresses is not reachable by this mechanism at all, since BNB is not a token contract.

**Why a registry rather than hard-coding the AGW factory.** The ZK Stack address formula is the same for every ZK Stack chain and every factory; only the salt-to-owner rule is factory-specific. A registry lets the token owner enable other factories with the same scheme without another implementation upgrade, and lets it disable one if its scheme turns out not to hold.

**Why `amount == 0` means full balance.** The signer typically wants everything out and does not know the exact balance at execution (a further deposit may land before the claim executes). Full-balance semantics avoid a second claim for dust.

## 7. Backward Compatibility

The change is an implementation upgrade behind the existing EIP-1967 proxy. The storage layout of `BEP20TokenImplementation` (`_balances`, `_allowances`, `_totalSupply`, `_name`, `_symbol`, `_decimals`, `_owner`, `_mintable`, and the `Initializable` flags) is preserved; the two new mappings (`zkFactoryScheme`, `recoveryNonce`) are appended after the existing variables. No existing function changes signature or behaviour. Existing holders, allowances, integrations and indexers see no difference; a recovery appears on-chain as an ordinary `Transfer` from the stranded address plus one new event. `totalSupply` is unchanged by a recovery. The upgrade does not require a hard fork and does not touch any system contract.

The V2 implementation MUST keep the original variable order and types and MUST be checked against the deployed implementation's storage layout before the upgrade transaction is sent. The current implementation is `pragma solidity ^0.6.0`; a V2 that stays on 0.6 reads `chainid()` via inline assembly, as that compiler has no `block.chainid`.

## 8. Security Considerations

**A tuple hashing to an existing address proves ZK origin, not ownership.** Anyone can produce the tuple for any ZK Stack account from the chain's public data. The address check (§5.5 step 5) establishes only that the address is the ZKsync-CREATE2 output of that factory with that salt. Ownership is established only by step 8 together with step 7: the salt is the hash of the recovered signer. With the factory's `bytecodeHash` and `constructorInputHash` pinned in the registry (§5.4), the salt is the only input a claimant chooses, and step 8 fixes it to the hash of their own key; the set of addresses any one key can ever claim under a factory therefore has exactly one member. Without pinning an attacker could vary the bytecode hash and constructor input freely and grind for any funded address, a multi-target search that is still a keccak256 preimage problem but with a smaller security margin; pinning removes that surface entirely.

**Owner rotation.** An AGW's k1 owner can be changed after deployment. The salt binds the initial owner only. If the key was rotated, the initial owner can still claim and the current owner cannot. For the §4.1 case the current owner on Abstract is unmeasured. This is a known limit, not a defect of the proof: the token contract cannot read Abstract state, and the initial owner is the only owner that is provable from the address alone.

**Compromise of the initial owner key.** A party holding the initial owner's key can claim to any destination. This is the same exposure the key already has for every balance it controls; the proposal adds the stranded balance to that key's reach and nothing more.

**Replay.** The EIP-712 domain includes `chainId` and the token proxy address, so a signature is valid for one token on one chain. The per-stranded-address nonce makes each signature usable once. Signatures for the Binance-Peg USDC proxy cannot be replayed against a different Binance-Peg token even though both share the implementation, because `verifyingContract` differs.

**Malleability.** `s` is restricted to the lower half of the curve order and `v` to 27/28, so each digest has one accepted signature encoding. Since the nonce is consumed on success this is defence in depth, not a correctness requirement.

**Phishing of claim signatures.** A claim is a plain EIP-712 message that a wallet will display with the type name `RecoveryClaim`, the stranded address, the destination, the amount and the deadline. A user who signs a `RecoveryClaim` presented by a malicious site with the attacker's `to` loses the stranded balance to the attacker. The exposure is limited to balances at the user's own stranded addresses (step 8 ties the claim to the signer), it cannot reach the signer's ordinary balances, and the message is readable. Wallet vendors SHOULD show `RecoveryClaim` fields verbatim.

**Registry governance.** `setZkFactoryScheme` is held by the token owner, the same key that can already `mint`. Registering a factory under `SALT_IS_KECCAK_OF_INITIAL_OWNER` when that factory does not in fact derive the salt from the initial owner would let whoever chose the salt on the ZK Stack chain claim BSC balances of an account they do not control on that chain. For the AGW factory the derivation was verified on two accounts and the factory's on-chain enforcement of it was measured on zkSync Era (§5.4); the token owner SHOULD repeat that check before registering any factory. A wrong entry can be reset to `NONE`. The registry adds no power over non-stranded balances: step 4 excludes every address with code, and steps 5, 6 and 8 exclude every address that is not the ZK-CREATE2 output of the registered factory with its pinned bytecode and constructor input and the signer's hash as salt. A registry entry with a wrong pinned hash simply makes claims for that factory revert.

**Deadline.** A signed claim that is not relayed stays valid until `deadline`. Signers SHOULD set a short deadline; the signature is otherwise a bearer instruction to move the stranded balance to `to`.

**Reentrancy and external calls.** The function calls no other contract (two STATICCALLs to itself only); `_transfer` is the existing internal bookkeeping. The nonce is incremented before the transfer.

**Upgrade risk.** The usual EIP-1967 upgrade risks apply: the proxy admin key (`0xd2f9…d6c4`, an EOA) can point the proxy at any implementation. This proposal does not change that; it specifies what the next implementation should contain.

## 9. Reference Implementation

A reference implementation is provided in the `contracts/` directory of the companion repository <https://github.com/vpjonny/pegrecover>: `contracts/src/` holds the V2 implementation built on the vendored originals `contracts/src/vendor/BEP20TokenImplementation.sol`, `contracts/src/vendor/BEP20UpgradeableProxy.sol` and `contracts/src/vendor/IBEP20.sol` from `bnb-chain/canonical-upgradeable-bep20`; `contracts/test/` holds its tests. The tests (70, all passing on 2026-10-26 against a BSC mainnet fork at block 129,782,171; transcript in `contracts/README.md`, independent review in `contracts/REVIEW.md`) (a) reproduce `0x6ae0145e60b073e8c47b922f16c0f9e71e3efa86` and `0xDb85b9035a02E0cB60bDd33655612930Ab414838` from their deployment tuples, (b) reject the EVM-CREATE2 address `0xbe2b2ffe38b18b1094c1cc24126ac140530f8d4f` for the same inputs, (c) execute a full-balance and a partial claim against a fork of the Binance-Peg USDC proxy at the state of §4.1, and (d) reject wrong nonce, expired deadline, unregistered factory, salt/signer mismatch, non-canonical signatures and stranded addresses with code. The repository URL will be added to this section when the implementation is published.

## 10. Precedents

**BC Fusion `TokenRecoverPortal` ([BEP-299](./BEP-299.md), [BEP-333](./BEP333.md)).** After the Beacon Chain halted, the `TokenRecoverPortal` system contract at `0x0000000000000000000000000000000000003000` released Beacon Chain assets on BSC to users who presented a Merkle proof of their snapshot balance together with a signature from the Beacon Chain account and an approval signature. It is a claims portal: a contract verifies a proof and a signature and then pays out from a pool it controls. It did not rewrite balances inside user accounts, did not write code at user addresses, and did not require users to hold a BSC key for the original address. This proposal follows the same pattern — proof plus signature releases a balance that no key can otherwise reach — with two differences: the proof is a deterministic hash derivation that needs no snapshot or Merkle tree, and the releasing contract is the token itself rather than a system contract, because the funds already sit in the token's storage.

**BSC hard forks and user addresses.** BSC hard forks have written code only to the reserved system contract range (`0x…1000` to `0x…3000`). No BSC fork has written code or altered balances at a user address. The on-chain governance module ([BEP-297](./BEP297.md)) exists for parameter and system-contract changes. Nothing in this proposal requires either.

**Wrong-network deposit recovery.** Binance recovers wrong-network deposits to its own exchange addresses by manual review (its public support process; terms and fees are outside this document). This proposal is the on-chain equivalent for the Binance-Peg tokens: the administrator enables a verifiable rule once instead of reviewing cases one by one.

## 11. License

The content is licensed under [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
