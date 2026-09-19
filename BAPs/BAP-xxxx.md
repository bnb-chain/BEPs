<pre>
  BAP: xxxx
  Title: Four-Asset Reserve Shares and Atomic Native-Token Entry
  Status: Draft
  Type: Application
  Created: 2026-09-19
  Author: MemeDAQ (@kontulbunder-oss)
</pre>

# Four-Asset Reserve Shares and Atomic Native-Token Entry

## 1. Summary

Define interoperable interfaces for four-asset reserve shares, proportional in-kind redemption, and atomic BNB entry with component-token refunds, including an optional launchpad integration.

## 2. Abstract

A basket share is a transferable token representing a proportional claim on specified on-chain component reserves. This proposal describes quantity-based issuance and redemption, net-receipt accounting, and a gateway that acquires components with BNB and refunds unused assets in the same transaction. Wallets and launchpads can use the same basket identity and share interface without treating a token name, index score, or displayed USD valuation as a reserve claim.

MemeDAQ provides the reference implementation, dIDX, and a launchpad that uses registered reserve shares as the quote asset of newly launched Meme pools. Its project repository is named **BEP-888**; that is a project identifier, not a request to preassign an official BEP or BAP number. This application-layer submission uses a provisional BAP number in accordance with the repository's process.

## 3. Motivation

Tokens sharing a Meme theme often have separate acquisition and management flows. A user seeking combined participation must otherwise trade and track each token individually. A reserve basket can offer one position backed by those components and a shared community entry point, while preserving the identities of the original tokens and pools.

Integrators also need precise answers to operational questions: which assets back a share; whether previews are gross or net of transfer fees; who receives refunds when payer and receiver differ; whether a page selection changes existing holdings; and whether a newly launched Meme inherits reserve redemption rights. A documented interface and accounting model reduce these ambiguities across wallets, gateways, and launchpads.

A future basket of several Broccoli-themed tokens illustrates combined theme participation. It would not merge their existing liquidity pools or guarantee improved community coordination. Arbitrary theme creation and general N-asset baskets are outside this four-asset version.

## 4. Specification

The terms MUST, MUST NOT, SHOULD, and MAY express requirements for this proposed interface profile. The proposal requires no consensus or execution-client changes.

### 4.1 Asset and share identity

A basket MUST have exactly four distinct component contract addresses in a stable order. The share MUST implement the base ERC-20 interface. Integrators MUST identify a composition by its chain ID and share contract address, not by its name or symbol.

The reference implementation fixes components at construction and has no administrator reserve withdrawal, rebalance, component replacement, or upgrade entry point. An adjacent registry MAY restrict which baskets a launchpad accepts; registry membership MUST NOT change an existing share's reserve rights.

### 4.2 Core interface

The following interface omits inherited ERC-20 methods:

```solidity
interface IFourAssetReserveShares {
    function assets() external view returns (address[4] memory);
    function accountedReserves() external view returns (uint256[4] memory);
    function reserves() external view returns (uint256[4] memory);
    function previewMint(uint256 shares) external view returns (uint256[4] memory);
    function previewRedeem(uint256 shares) external view returns (uint256[4] memory);
    function deposit(
        uint256[4] calldata amounts, uint256 minShares, uint16 maxSurplusBps,
        address receiver, uint256 deadline
    ) external returns (uint256 shares);
    function redeem(
        uint256 shares, uint256[4] calldata minAmounts,
        address receiver, uint256 deadline
    ) external returns (uint256[4] memory received);

    event Initialized(uint256[4] received, address indexed receiver);
    event Deposited(address indexed payer, address indexed receiver,
        uint256 shares, uint256[4] received);
    event Redeemed(address indexed payer, address indexed receiver,
        uint256 shares, uint256[4] received);
}
```

### 4.3 Accounting and initialization

Let `S` be total share supply, `R_i` the internally accounted component reserve, and `A_i` its actual basket balance. All quantities are integers in each asset's smallest unit. The currently redeemable reserve is:

```text
B_i = min(R_i, A_i)
```

`accountedReserves()` returns `R_i`; `reserves()` returns `B_i`. Unaccounted donations MUST NOT raise `B_i`. A shortfall reduces the value available to all shares proportionally.

Initialization in the reference implementation is restricted to a constructor-bound initializer and can occur only once. It measures actual net receipts of at least `1e6` units of every component, then issues `1e18` share units. Of these, `1e6` are permanently locked at `address(0xdead)` and the rest are delivered to the receiver. Shares have 18 decimals. This establishes neither a USD peg nor a fixed dollar value per share.

### 4.4 Proportional deposit

For each component, the basket MUST measure `d_i`, its actual receipt from the current transfer, using balance differences. A deposit with a zero redeemable reserve MUST revert. The share calculation and required net receipts are:

```text
m = min_i floor(d_i * S / B_i)
required_i = ceil(m * B_i / S)
```

`minShares` MUST be positive and `m` MUST meet it. `maxSurplusBps` MUST be at most 1000. Each component MUST satisfy:

```text
d_i - required_i <= floor(d_i * maxSurplusBps / 10000)
```

An accepted direct deposit sets the accounted reserve to `B_i + d_i` and issues `m` shares. Accepted surplus remains in the basket. The core deposit function does not refund it.

`previewMint(shares)` returns rounded-up **net** component receipts needed for the requested shares. It does not account for the sender's additional gross input needed when an incoming transfer is taxed. Previewing alone does not execute or guarantee a deposit.

### 4.5 In-kind redemption

The basket MUST burn only the caller's shares and calculate:

```text
gross_i = floor(shares * B_i / S)
```

`previewRedeem(shares)` returns these gross amounts. Execution MUST measure the receiver's net increase and compare it with each `minAmounts[i]`. A component that deducts more than the intended gross amount from the basket MUST cause a revert.

A zero component output is skipped. A nonzero component that refuses transfer can cause the entire redemption to revert; this profile does not provide a skip-frozen-component or administrator rescue operation. In-kind redemption MUST NOT require a USD price feed.

Both deposit and redemption MUST validate a nonzero receiver distinct from the basket and an unexpired deadline. Execution and its accounting changes MUST be atomic and protected against reentrant entry.

### 4.6 Atomic native-token entry

A refund gateway MUST expose the basket it serves and bind its underlying purchase gateway and Meme router. The reference entry interface is:

```solidity
function mintFromBnb(
    uint256[4] calldata budgets, uint256[] calldata limits,
    uint256 minShares, uint16 maxSurplusBps,
    address meme, uint256 minMemeOut, address receiver, uint256 deadline
) external payable returns (
    uint256 shares, uint256 memeOut, uint256[] memory legs,
    uint256[4] memory tokenRefunds, uint256 bnbRefund
);

event Refunded(address indexed payer, uint256 bnb, uint256[4] tokenNetAmounts);
```

Each budget MUST be positive and their sum MUST NOT exceed `msg.value`. Per-leg limits follow the purchase gateway's deployment-bound route order and count, discoverable through `route(i)` and `legCount()` on the purchase gateway.

The gateway MUST:

1. Record pre-existing component balances and acquire the four components through its configured routes.
2. Calculate the available share target from this call's actual acquisitions and current basket reserves.
3. Deposit only the proportional rounded-up quantities, with zero surplus tolerance, and require the issued shares to equal the target.
4. Deliver the new shares to `receiver`, or use only those new shares for the optional Meme purchase.
5. Clear temporary allowances and refund unused component tokens and unspent BNB to `msg.sender`, even if the share receiver differs.

Refunded components MUST NOT be implicitly sold back into BNB. `tokenRefunds` and the refund event report recipient net amounts. Pre-existing gateway balances MUST NOT subsidize the current caller or be included in refunds. A failed purchase, missed limit, incompatible transfer behavior, expired deadline, or failed refund MUST revert the whole operation.

The `maxSurplusBps` argument is retained for reference ABI compatibility and MUST be at most 1000, but this refund entry always deposits with zero surplus tolerance. An asset that taxes transfers into the basket may therefore be incompatible with this entry despite support for measured net receipts in direct deposits.

### 4.7 Optional launchpad and exit integration

A launchpad MAY create a new Meme pool quoted in a registered basket share. A Meme purchaser then pays with that share; a seller receives that share. Holding the launched Meme alone MUST NOT be described as an entitlement to redeem the basket. Redemption rights belong to the share contract.

The reference gateway also supports an atomic BNB-to-components-to-shares-to-Meme purchase when `meme` is nonzero. Such a purchase requires a positive `minMemeOut`. With a zero Meme address, the receiver receives shares instead.

Conversion of shares back to BNB is a separate gateway path. It pulls the user's approved shares, redeems them, and executes component sales subject to per-leg and final BNB output limits. It depends on external liquidity as well as component transferability. User interfaces SHOULD separate approval, execution, confirmation, and refreshed balances, and MUST distinguish BNB conversion from in-kind redemption.

Launch fees, pool taxes, platform-token policy, and restrictions imposed by a particular registry are application configuration, not universal requirements of this proposal.

### 4.8 Valuation and frontend conventions

The USD value of redeemable reserves divided by share supply is reference NAV. An index level based on weighted component price changes is a different measurement. Neither is an executable quote.

Interfaces SHOULD display the valuation source, read time, selected share address, and output constraints. They MUST NOT silently switch a user's existing holding to another composition. A temporary read failure SHOULD preserve a clearly labelled previous observation or show unavailable data rather than inventing a current price.

Additional proportional minting does not by itself increase NAV per share. Core reserve issuance and in-kind redemption depend on quantities, while USD-based launch pricing and conversion routes have separate price and liquidity dependencies.

## 5. Rationale

This profile combines existing building blocks rather than claiming the invention of basket investing. Its practical contribution is a consistent reserve-share integration boundary: measured quantities, explicit rounding, payer-directed raw refunds, and clear launchpad quote-asset semantics.

Four fixed components give the first profile a bounded ABI and explicit routes. Quantity-based core accounting avoids using a manipulable USD estimate to allocate reserve ownership. Returning components avoids the extra cost and liquidity dependency of selling small leftovers. Making each composition a separate share contract keeps entitlements explicit.

## 6. Compatibility and future work

The share remains compatible with base ERC-20 transfers and allowances. This proposal does not claim single-asset ERC-4626 compatibility and does not alter existing tokens or pools.

The reference basket registry manages five candidates with four assets per basket; binding the fifth candidate and registering a new composition are owner-managed actions. The deployed default currently uses four Meme tokens. Arbitrary community baskets, N-asset arrays, migrations, and additional platform-token compositions require further implementation and readiness checks. They MUST NOT be represented as already available merely because their names appear in a UI.

The current core basket is immutable. Any migration to a new profile requires an explicit new contract and user flow; changing website configuration alone cannot migrate reserve rights.

## 7. Reference implementation and tests

The open-source reference implementation is [MemeDAQ / BEP-888](https://github.com/kontulbunder-oss/BEP-888), including the basket, purchase and refund gateways, launchpad, pool hook, router, registry, interfaces, and tests. The project also provides [Chinese rationale and examples](https://github.com/kontulbunder-oss/BEP-888/blob/main/docs/INNOVATION.zh-CN.md).

Reference revision: [`b91455001711d961dffb79bfede3f4617a6b5278`](https://github.com/kontulbunder-oss/BEP-888/tree/b91455001711d961dffb79bfede3f4617a6b5278).

- [Core basket source](https://github.com/kontulbunder-oss/BEP-888/blob/b91455001711d961dffb79bfede3f4617a6b5278/src/index/DidxBasket.sol)
- [Atomic refund entry](https://github.com/kontulbunder-oss/BEP-888/blob/b91455001711d961dffb79bfede3f4617a6b5278/src/index/DidxRefundGateway.sol)
- [Launchpad integration](https://github.com/kontulbunder-oss/BEP-888/blob/b91455001711d961dffb79bfede3f4617a6b5278/src/MemeDaqLaunchpad.sol)
- [Deployment snapshot and binding checks](https://github.com/kontulbunder-oss/BEP-888/blob/b91455001711d961dffb79bfede3f4617a6b5278/deployments/bsc-mainnet.json)
- [Validation and reproduction instructions](https://github.com/kontulbunder-oss/BEP-888/blob/b91455001711d961dffb79bfede3f4617a6b5278/docs/VALIDATION.md)

On BSC (chain ID 56), the default dIDX share is `0x5C36146A69abFd68346d801AfB911B97C18eb4b5` and the refundable entry is `0xc1359a0eDbdB727cd2686498be7A7403959C7C27`. These are deployment examples, not standardized global addresses.

The published local run has 42 passing tests, zero failures, and one optional historical-fork test skipped. Three fuzz tests each ran 256 inputs. Coverage includes net-transfer accounting, rounding, donations, losses, frozen-transfer rollback, payer/receiver separation, refund failures, isolation between compositions, and launch-pool integration.

## 8. Security considerations

Component administrators, transfer restrictions, transfer taxes, and external pool liquidity remain dependencies. A share is a proportional reserve claim, not principal protection or a fixed USD promise. The core has no emergency component bypass; adding one would require an explicitly different specification.

Gateways need per-route limits and final output limits against adverse execution and MEV. Integrators SHOULD simulate the complete call and obtain user approval for its minimum outputs and deadline. Replacing a failed quote with zero minimums is not a suitable fallback.

Previews may become stale, and net receipts can differ from gross transfers. Implementations must isolate historical balances, validate receiver and payer treatment, bound surplus, and prevent reentrant changes during multi-asset operations. External registries, launch settings, and buyback infrastructure have separate administrative authorities; absence of a basket owner does not imply an administration-free system.

The tests and deployment comparisons are reproducibility evidence, not a complete independent security review or assurance of future external-token behavior.

## 9. License

This proposal document is dedicated to the public domain under [CC0](https://creativecommons.org/publicdomain/zero/1.0/). The separately linked reference implementation retains its GPL-2.0-or-later license and the licenses of its dependencies.
