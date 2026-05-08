# BAP-XXX: Token Name Registry Standard (UNIQUE Registry)

**BAP:** XXX
**Title:** Token Name Registry Standard on BNBChain
**Status:** Draft
**Type:** Application
**Created:** May 5, 2026
**Author:** Spigg (@Spigg1115)
**Contract:** 0x1dDE1B992cdD5a11E77e02Eb6A16a0F64770d9cd
**Website:** https://uniqueregistry.io
**GitHub:** https://github.com/Spigg1115/uniqueregistry

---

## Abstract

This BNB Chain Application Proposal (BAP) introduces the **Token Name Registry Standard**, a permanent, neutral, on-chain registry for token names deployed on BNBChain. It defines a standard interface that launchpads, AI agent platforms, and token issuers can use to register, verify, and check the availability of token names across the entire BNBChain ecosystem.

The standard is already implemented and deployed at `0x1dDE1B992cdD5a11E77e02Eb6A16a0F64770d9cd` on BNB Smart Chain Mainnet (April 18, 2026). This proposal seeks formal recognition as the ecosystem-wide standard for token name identity on BNBChain.

---

## Motivation

BNBChain processes over **10,000 new token creations per day**, with peaks above 13,000. Of all tokens ever created on BNBChain launchpads, only **1.34%** graduate to a DEX listing. The remaining 98.66% are noise: clones, rugs, and ephemeral projects.

The current environment creates three structural problems:

**1. Clone Token Epidemic**
When a token gains traction, clone tokens with identical names and tickers appear within minutes. Users buy the wrong token. Builders lose their community before they can build it. Trust in the ecosystem erodes.

**2. No Cross-Platform Protection**
Existing solutions such as Four.meme's 72-hour name lock are temporary and platform-specific. A name protected on one launchpad remains unprotected on all others. There is no permanent, cross-platform, on-chain standard today.

**3. AI Agents at Machine Speed**
BNBChain now hosts over **150,000 AI agents** (as of April 2026), representing a 43,750% increase since January 2026. One in every three AI agents on any blockchain runs on BNBChain. Platforms including Four.meme's Agentic Mode and Bullshot.io already deploy tokens autonomously via AI agents. Without a name registry, these agents create name collisions at a scale and speed that no human moderation can address.

A standard is needed. UNIQUE Registry provides it.

---

## Specification

### Overview

The Token Name Registry Standard defines a minimal interface for:
- Checking whether a token name is already registered (`isTaken`)
- Registering a token name permanently on-chain (`registerTicker`)
- Verifying established projects retroactively (`certifyOG`)
- Recording official and strategic registrations (`certifyRecord`)

All names are normalized to uppercase before storage, ensuring case-insensitive uniqueness across the registry.

### Interface

```solidity
interface IUNIQUERegistry {

    /// @notice Check if a token name is already registered
    /// @param name The token name to check (case-insensitive)
    /// @return bool True if the name is taken, false if available
    function isTaken(string calldata name) external view returns (bool);

    /// @notice Register a token name via a partner launchpad (Tier 1)
    /// @param name The token name to register
    /// @dev Payable. Fee: 0.1 BNB. Split 50/50 between launchpad and protocol.
    function registerTicker(string calldata name) external payable;

    /// @notice Register an OG Verified name for an existing project (Tier 2)
    /// @param name The token name to certify
    /// @param project The wallet address of the original project
    /// @dev Requires manual verification by the UNIQUE team. Fee: 0.05 BNB.
    function certifyOG(string calldata name, address project) external payable;

    /// @notice Official protocol registration (Tier 3)
    /// @param name The token name to certify
    /// @param project The wallet address of the project
    /// @dev Free. Reserved for strategic partnerships and official use.
    function certifyRecord(string calldata name, address project) external;

    /// @notice Emitted when a name is successfully registered
    event TokenRegistered(string indexed name, address indexed registrant, uint256 timestamp);

    /// @notice Emitted when a name is certified (OG or official)
    event TokenCertified(string indexed name, address indexed project, uint8 tier);

}
```

### Registration Tiers

| Tier | Path | Fee | Split | Certification Stamp |
|------|------|-----|-------|---------------------|
| 1 | Partner Launchpad | 0.1 BNB | 50% launchpad / 50% protocol | UNIQUE Certified |
| 2 | OG Verified | 0.05 BNB | 100% protocol | OG Verified |
| 3 | certifyRecord() | Free | N/A | Official / Strategic |

### Name Normalization

All names are converted to uppercase and stripped of special characters before storage. This prevents near-duplicate registrations (e.g. "pepe" and "PEPE" map to the same key).

```solidity
function normalizeName(string memory name) internal pure returns (string memory) {
    bytes memory b = bytes(name);
    for (uint i = 0; i < b.length; i++) {
        if (b[i] >= 0x61 && b[i] <= 0x7A) {
            b[i] = bytes1(uint8(b[i]) - 32);
        }
    }
    return string(b);
}
```

### Security

- **ReentrancyGuard** applied to all payable functions
- **48-hour TimeLock** on all changes to fees and contract ownership
- **Gated access** on Tier 3 registrations via role-based access control
- Contract is MIT-licensed, verified, and open-source on BscScan

---

## Rationale

### Why a neutral third-party standard?

A standard owned by any single launchpad would not be adopted by competitors. Four.meme would not use PancakeSwap's registry, and vice versa. The value of this standard comes precisely from its neutrality. UNIQUE Registry belongs to no launchpad, which is what allows it to function as a true ecosystem-wide standard.

### Why on-chain?

Off-chain databases and platform-level locks can be changed, expire, or be discontinued. An on-chain registry is immutable, permanent, and publicly verifiable by anyone at any time via BscScan. It provides a source of truth that no centralized party can modify.

### Why now?

With AI agents already deploying tokens autonomously on BNBChain at scale, the absence of a name registry standard will produce exponential name collisions. A standard must be established before this wave accelerates further.

---

## Backwards Compatibility

This standard is fully additive. It does not modify, interfere with, or require changes to any existing token, launchpad, or smart contract on BNBChain. Tokens that do not register continue to function exactly as before. The registry is opt-in by design.

Existing established projects can register retroactively through the OG Verified tier (Tier 2) at any time.

---

## Reference Implementation

The reference implementation is deployed and verified on BNB Smart Chain Mainnet:

- **Contract:** `0x1dDE1B992cdD5a11E77e02Eb6A16a0F64770d9cd`
- **BscScan:** https://bscscan.com/address/0x1dDE1B992cdD5a11E77e02Eb6A16a0F64770d9cd
- **GitHub:** https://github.com/Spigg1115/uniqueregistry
- **Whitepaper:** https://raw.githubusercontent.com/Spigg1115/uniqueregistry/main/UNIQUE_Registry_Whitepaper.pdf
- **Website:** https://uniqueregistry.io

### AI Agent Integration Pattern

```solidity
// Recommended pattern for AI agent platforms
if (!uniqueRegistry.isTaken(tokenName)) {
    uniqueRegistry.registerTicker{value: 0.1 ether}(tokenName);
    deployToken(tokenName);
} else {
    deployToken(generateAlternativeName());
}
```

---

## Adoption Roadmap

| Phase | Status | Description |
|-------|--------|-------------|
| Contract Deployment | Complete | Live on BNBChain Mainnet since April 18, 2026 |
| OG Registrations | Active | Established projects securing their names |
| Launchpad Integrations | In Progress | Partner launchpads integrating the standard |
| Security Audit | Planned | Third-party audit funded from protocol revenues |
| V2 Protocol | Planned | KOL referral system, V1 migration, full audit |

---

## Copyright

Copyright and related rights waived via CC0.
