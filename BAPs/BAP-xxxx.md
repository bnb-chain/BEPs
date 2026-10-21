```
BAP: xxxx
Title: Agent Lifecycle Protocol and BNB Smart Chain Binding
Status: Draft
Type: Application
Created: 2026-10-21
Description: Interoperable lifecycle, identity, wallet policy, runtime portability, and commerce conventions for economically autonomous agents.
```

# BAP-xxxx: Agent Lifecycle Protocol and BNB Smart Chain Binding

- [1. Summary](#1-summary)
- [2. Abstract](#2-abstract)
- [3. Motivation](#3-motivation)
- [4. Specification](#4-specification)
  - [4.1 Scope and Dependency Selection](#41-scope-and-dependency-selection)
  - [4.2 Chain and Deployment Manifest](#42-chain-and-deployment-manifest)
  - [4.3 Identity and Wallet Binding](#43-identity-and-wallet-binding)
  - [4.4 Lifecycle Registry](#44-lifecycle-registry)
  - [4.5 Finality and Transaction Recovery](#45-finality-and-transaction-recovery)
  - [4.6 Wallet and Payment Behavior](#46-wallet-and-payment-behavior)
  - [4.7 Discovery and Optional Commerce](#47-discovery-and-optional-commerce)
  - [4.8 BAP-578 Compatibility](#48-bap-578-compatibility)
- [5. Rationale](#5-rationale)
- [6. Backwards Compatibility](#6-backwards-compatibility)
- [7. Test Cases](#7-test-cases)
- [8. Reference Implementations](#8-reference-implementations)
- [9. Security Considerations](#9-security-considerations)
- [10. References](#10-references)
- [11. License](#11-license)

## 1. Summary

This proposal defines the Agent Lifecycle Protocol (ALP) v0.4-draft and its BNB Smart Chain application profile, allowing independently supplied identities, wallets, payment services, and runtimes to operate one agent under explicit owner authority.

## 2. Abstract

ALP composes agent registration, cryptographic wallet binding, policy-controlled spending, HTTP payments, runtime migration, and optional escrow commerce into a verifiable lifecycle. An implementation moves through DRAFT, PROVISIONED, REGISTERED, ACTIVE, SUSPENDED, and RETIRED states, with evidence and recovery requirements for every transition.

The [protocol specification](assets/bap-alp/protocol.md) is normative and contains eight modules: CORE, DISC, A2A, RT, VERIFY, COMM, CONF, and SCHEMA. This BAP supplies the BSC binding; together they are the proposed standard. It makes no changes to consensus, block validity, gas accounting, or existing ERC interfaces. No hard fork is required. The proposal number is provisional pending assignment through the repository's application proposal process.

## 3. Motivation

Agent frameworks can communicate and call tools, but deployment across independent providers still requires custom agreements about identity, spending authority, funding failures, and runtime handover. A payment retry can duplicate a purchase; an incomplete registration can advertise an unusable agent; a migration can leave two processes spending the same wallet. These failures cross component boundaries and cannot be resolved by a communication protocol alone.

ALP standardizes those boundaries. Owners retain control over permitted expenditure. Counterparties can verify the agent's current identity and lifecycle state. Runtime providers can exchange an agent without acquiring its owner key or silently resetting its obligations.

## 4. Specification

The terms MUST, MUST NOT, SHOULD, SHOULD NOT, and MAY follow RFC 2119 and RFC 8174. Requirements in this section supplement [ALP v0.4-draft](assets/bap-alp/protocol.md); a BSC implementation MUST satisfy both.

### 4.1 Scope and Dependency Selection

The baseline profile comprises ALP-CORE, ALP-DISC, ALP-SCHEMA, and ALP-CONF. An implementation MUST additionally implement ALP-RT to claim Portable Runtime conformance, ALP-A2A to advertise A2A interoperability, and ALP-COMM to advertise Commerce conformance. Certified Toolchain conformance requires ALP-VERIFY.

| Dependency | Use | Requirement |
| --- | --- | --- |
| ERC-8004 identity registry | Agent identifier and wallet-control verification | Required; exact source revision and deployment ABI pinned in binding manifest |
| x402 | Self-funding payment rail | Required for this profile; wire version and EVM scheme pinned in manifest |
| ERC-3009 | Signed token transfer authorizations | Required only when selected by the payment scheme and supported by the asset |
| ERC-8183 | Escrow job interface | Required for Commerce profile; exact revision and contract ABI pinned |
| BEP-441 / EIP-7702 | Delegated EOA execution | Optional wallet implementation |
| BEP-414 | EOA gas sponsorship | Optional transaction submission path |
| BAP-578 | NFA representation | Optional compatibility adapter |

A reference to a draft ERC does not imply finalization. Conformance is relative to the exact revisions in a published manifest, never to an unversioned latest release. The protocol does not require an agent to hold native gas when all selected operations have a working relay or sponsorship path; ERC-3009 alone does not sponsor registration, deployment, or arbitrary escrow transactions.

### 4.2 Chain and Deployment Manifest

A BSC binding MUST use `eip155:56` for mainnet or `eip155:97` for testnet. Other networks, including opBNB, require separately identified bindings. The manifest MUST identify:

- Network identifier; identity registry address, source revision, ABI digest, and expected deployed code or proxy implementation identity.
- Lifecycle Registry address and deployment identity, implementing the semantics of section 4.4.
- Each payment token by address, decimals, supported authorization scheme, and EIP-712 domain where applicable. A symbol such as USDC is insufficient evidence of support.
- Payment facilitator endpoints, supported wire versions, fee model, finality rule, and retry/reconciliation behavior.
- Optional commerce contracts, evaluator adapters, and their exact ABI and implementation identities.
- An immutable digest of every dependency specification and binding document used by the deployment.

Mutable proxies MUST declare their upgrade authority. Implementation changes MUST invalidate cached compatibility verification until revalidated. This proposal assigns no canonical contract addresses and asserts no existing mainnet deployment.

### 4.3 Identity and Wallet Binding

The canonical identifier is `(agentRegistry, agentId)` as defined by the selected ERC-8004 revision; for BSC, `agentRegistry` includes `eip155`, chain ID, and registry address. Identifiers MUST NOT be inferred from names or endpoint URLs.

The registrar MUST verify the current ERC-721 owner and use the registry's wallet-control proof mechanism, including EIP-712 or ERC-1271 as appropriate. It MUST read back the finalized `agentWallet`. Setting arbitrary metadata or merely publishing a wallet address is insufficient. The owner wallet and dedicated agent spending wallet are distinct roles; an automatic registry default to the owner address does not satisfy ALP's dedicated-wallet requirement.

An identity transfer or wallet-binding change MUST invalidate all cached sessions and spending delegations. The agent MUST stop accepting work and suspend before re-establishing owner-approved policy and runtime authority. Identity transfer MUST NOT revive a retired identity or transfer old wallet secrets to the new owner.

### 4.4 Lifecycle Registry

A deployment MUST supply an application contract with a record keyed by the full identity tuple. It MUST store the current state, monotonically increasing sequence, controller address, owner and wallet snapshots, current authority epoch, evidence commitment, and permanent retirement flag. Authority epochs MUST never decrease and MUST match the fenced lease service before activation or resume. An authority change while ACTIVE MUST first close intake and signing and enter SUSPENDED. The record begins at REGISTERED; DRAFT and PROVISIONED are durable local provisioning states, not claims that a registry identity already exists.

For first registration the registry MUST verify the current identity owner, nonzero verified agent wallet, and owner authorization of the controller. Only the current owner can appoint or replace a controller. An owner change MUST freeze controller operations other than safe suspension until the new owner reauthorizes them. Anyone MAY trigger suspension when an on-chain owner mismatch or unset/changed wallet is provable against the record. Changes MUST use expected-sequence comparison and emit an event containing the identity, previous and next states, sequence, evidence commitment, controller, and block context.

The registry MUST reject invalid state edges, stale sequences, unauthorized updates, and every update that would leave RETIRED. The current owner MAY suspend or retire directly. The authorized controller MAY activate, resume, suspend, or retire subject to the protocol's evidence requirements. Contract-level access control does not prove off-chain evidence is true: clients MUST verify that evidence under their trust policy. Owners SHOULD use a controller that checks the required evidence deterministically.

A retirement flag MUST be immutable, including across upgrades. A mutable ERC-8004 metadata field alone cannot provide this guarantee. Implementations MUST document registry upgrade powers; an unrestricted upgrade that can erase retirement is nonconforming. Multiple registry deployments are different trust domains: verifiers MUST pin the owner-approved lifecycle registry and MUST NOT switch registries to ignore a retirement. Historical retirement in that trust domain remains authoritative after ownership transfer.

### 4.5 Finality and Transaction Recovery

Bindings MUST define how they obtain and independently check BSC finality, including trusted RPC assumptions, supported finality APIs or proofs, and behavior when providers disagree. A receipt or fixed elapsed time MUST NOT be described as verified finality without the declared rule. A finalized checkpoint records chain ID, block number, block hash, transaction hash, and receipt status.

Pending or uncertain transactions MUST remain pending in the operation journal. A client MUST reconcile transaction receipt, authorization consumption, and resulting contract state before retrying. A reorg before finality invalidates dependent transition evidence. If a purported finalized result is contradicted, the runtime MUST fail closed, suspend signing and task intake, and require reconciliation. Registration, funding, activation, and retirement claims MUST NOT advance on unresolved evidence.

### 4.6 Wallet and Payment Behavior

Signing MUST be isolated from model-accessible tools and memory. The wallet binding MUST enforce owner-approved caps, allowed assets, counterparties, destination contracts, method selectors, and authorization expiry. BEP-441 permits delegation but supplies none of these controls by itself. BEP-414 sponsorship decisions are independent of ALP's spending policy.

The signer MUST atomically reserve expenditure across every concurrent runtime and rail sharing the wallet. The x402 authorization MUST be checked against the requested resource, network, token, beneficiary, maximum amount, validity window, and operation identifier. Settled payment and delivered provider credit are separate facts; neither implies the other. See ALP-CORE for reservation, retry, and credit reconciliation requirements.

### 4.7 Discovery and Optional Commerce

Agents MUST expose ALP-DISC's authenticated descriptor and handshake. Their registry registration file MUST advertise the descriptor through its supported service mechanism. Advertising a new service name is an ALP convention, not an upstream ERC extension registration.

Commerce implementations MUST preserve the selected ERC-8183 job states and caller permissions. Additional disputes are evaluator-adapter state, never a silent replacement of the underlying job state machine. At creation, an ALP-COMM adapter MUST commit settlement terms and implement permissionless timeout resolution. Retirement MUST NOT confiscate, redirect, or erase escrow obligations.

### 4.8 BAP-578 Compatibility

An adapter MAY link an NFA token to an ALP identity. It MUST publish both full contract coordinates, prove authorization by both current owners, and prevent conflicting links within its declared registry. BAP-578 `Active`, `Paused`, and `Terminated` map to ALP ACTIVE, SUSPENDED, and RETIRED only after the corresponding ALP transition requirements hold. DRAFT, PROVISIONED, and REGISTERED have no equivalent BAP-578 status. An NFA transfer MUST invalidate the adapter's cached ownership authority. ALP conformance MUST NOT require a second NFT or a learning module.

## 5. Rationale

The chain-neutral protocol keeps lifecycle invariants independent of a cloud, wallet vendor, or settlement network. The BSC binding makes deployment assumptions explicit without turning BSC-specific services into universal requirements. A permanent lifecycle registry provides stronger retirement semantics than mutable descriptive metadata. Optional profiles let an agent use self-funding without implementing a marketplace or A2A transport.

Application-level composition fits the BAP process. BEP-441 and BEP-414 are optional infrastructure; neither standardizes the lifecycle. BEP-703 remains an independent payment-capacity proposal and is not a prerequisite.

## 6. Backwards Compatibility

This proposal changes no existing contract interface or transaction format. Legacy agents remain usable but MUST NOT claim ALP conformance without passing the applicable requirements. ERC-8004 and ERC-8183 adapters MUST retain the pinned upstream semantics. Future incompatible dependency revisions require an explicitly versioned binding and new conformance evidence.

## 7. Test Cases

The [conformance matrix](assets/bap-alp/conformance.md) specifies required positive and adversarial scenarios. The [example descriptors and schema](assets/bap-alp/schemas.json) are machine-readable artifacts, not evidence of a deployed implementation. Implementations MUST publish reproducible results before claiming a conformance profile.

## 8. Reference Implementations

This submission is a protocol draft. It does not include a production runtime, signer, facilitator, lifecycle contract implementation, deployed addresses, or an audited escrow adapter. An implementation claiming this BAP MUST publish its bindings, deployment manifest, and applicable conformance results. No certification organization or external standards-body adoption is asserted by this proposal.

## 9. Security Considerations

Prompt injection can influence payment requests; signing policy MUST remain deterministic and independent of model judgment. Counterparty allowlists do not prevent an allowed provider from returning malicious data or an overpriced quote. Policy MUST bound values and methods as well as addresses.

Signed authorizations can remain executable after a runtime stops. Suspension, migration, and retirement MUST reconcile or invalidate them; process termination and secret deletion alone are insufficient. Native keys, allowance operators, smart-account modules, and recovery paths all belong in the authority inventory.

Registry ownership is not proof of service quality. Runtime receipts are assertions by their signers, not trustless proofs of execution. Artifact verification does not establish functional correctness. Finality, issuer freezes, token upgrades, RPC censorship, evaluator misconduct, and unavailable services remain deployment risks and MUST be stated in the binding.

Private prompts, keys, credentials, and deliverables MUST NOT be published as lifecycle evidence. Evidence commitments SHOULD use salted hashes where sensitive low-entropy values could otherwise be guessed.

## 10. References

- [ALP v0.4-draft](assets/bap-alp/protocol.md)
- [BAP process](README.md) and [BEP-1](../BEPs/BEP1.md)
- [ERC-8004](https://eips.ethereum.org/EIPS/eip-8004), [ERC-8183](https://eips.ethereum.org/EIPS/eip-8183), [ERC-3009](https://eips.ethereum.org/EIPS/eip-3009)
- [x402](https://github.com/coinbase/x402), [A2A](https://github.com/a2aproject/A2A), [MCP](https://modelcontextprotocol.io/specification/)
- [BEP-441](../BEPs/BEP-441.md), [BEP-414](../BEPs/BEP-414.md), [BAP-578](BAP-578.md), [BEP-703](../BEPs/BEP-703.md)
- [RFC 2119](https://www.rfc-editor.org/rfc/rfc2119), [RFC 8174](https://www.rfc-editor.org/rfc/rfc8174), [RFC 8785](https://www.rfc-editor.org/rfc/rfc8785)

## 11. License

The content is licensed under [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
