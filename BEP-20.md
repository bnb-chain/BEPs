# BEP-20: Issuer Controlled Token Transfer Whitelist

  - [1. Summary](#1-summary)
  - [2. Abstract](#2-abstract)
  - [3. Status](#3-status)
  - [4. Motivation](#4-motivation)
  - [5. Specification](#5-specification)
  - [6. References](#6-references)
  - [7. License](#7-license)

## 1.  Summary 

This BEP describes a proposal for adding and removing addresses from a token issuer controlled whitelist to restrict who can receive tokens. 

_This is not investment or legal advice._

## 2.  Abstract

Whitelists controlled by security token owners can enable regulatory compliance and significantly improve liquidity for private markets. 

To enable this Binance Chain would need to implement a whitelist of addresses maintained by the owner of the contract - the issuer. Only investors who have passed the issuers AML/KYC and accredited investor checks would be added to the whitelist for unrestricted trading. Additional checks would continue to be performed by individual exchanges who are accountable for their own vetting. More complex transfer restrictions such as maximum investment amounts for everyday investors are out of scope for this proposal.

## 3.  Status

This BEP has a [Work in Progress (WIP) status](https://github.com/binance-chain/BEPs/blob/master/BEP1.md#4--bep-workflow).

## 4.  Motivation

Transfer restrictions are required for widespread Security Token adoption. There are trillions of dollars of privately traded securities that can be tokenized - including shares, real estate investment trusts, and funds. But the issuers, promoters of the primary issuance, and exchanges facilitating secondary trading are required by regulators like the SEC to enforce transfer restrictions or face stiff penalties.

1. **Faster Compliant Transactions.** Whitelists would enable compliant token holders unfettered access to trade tokens with others on the whitelist. This whitelisting feature, which is becoming increasingly standard as an on chain solution, allows for a balance of both transactional speed and regulatory protection. This is a keystone feature for security tokens throughout the majority of relevant jurisdictions. Trading without restriction between whitelisted addresses is critical for predictable and fast order book settlement. For example, an electronic matching engine must assure best execution rules for trades; delays and failures caused by non-compliant traders placing orders than cannot be settled create significant complications for order book integrity. Whitelists that pre-approve traders to place orders simplify best execution gauruntees significantly.

2. **Jurisdictional Compliance.** In order for digital asset issuers, exchanges and marketplaces to maintain regulatory compliance, investor restrictions need to be enforced down to the chain level by the digital asset issuer to avoid enforcement action by regulators. Maintaining compliance includes restricting access to non qualified investors, AML/KYC checks, proper treatment of foreign investors, lockup periods and other restrictions like maximum holders and investor specific purchase amounts. Verification of investor transfer qualifications is typically conducted off chain to preserve investor privacy; then enforced on chain with securely controlled offchain investor information available to the issuer. The rules for who can hold or transfer security tokens varies widely even for the same asset transferred on behalf of citizens in the US, Japan, UK, etc. Regulations are primarily defined and enforced by regulatory bodies in the investor's country of citizenship and the issuer's country of formation. For instance, since DAO tokens were considered securities by the SEC, the SEC made it clear that they could have entered the Swiss jurisdiction to enforce protections for US investors in their 2017 ["Report of Investigation Pursuant to Section 21(a) of the Securities Exchange Act of 1934: The DAO"](https://www.sec.gov/litigation/investreport/34-81207.pdf). Issuer controlled whitelists enable regulatory compliance for digital asset issuers.

3. **Faster Vetting** Vetting time for investors, market liquidity and orderbook integrity are interdependent. Some vetting processes for private securities have historically taken months - delaying transactions significantly. By pre-vetting investors and increasing the number of matched orders that will settle without complication, security token markets can become more liquidly tradeable than their historical private market counterparts. Whitelists enable these conditions.

## Whitelist Limitations

The issuer controlled whitelist proposed here only directly addresses the digital asset issuer's regulatory burden for restricting token transfers. In addition to the issuer's responsibility, each exchange will need to confirm the AML/KYC and accreditation status of each trader in keeping with regulations that apply to them. Exchanges and marketplaces are directly accountable for their own vettings. What is gained by the whitelist is pre-approval by the issuer for compliant trades.

Whitelists are only suitable for unrestricted trading between accredited investors that do not violate other restrictions like maximum holders, maximum purchase amounts or trading restrictions between specific jurisdictions. Fine grained control of transfer restricitons will need to be addressed in a future transfer restrictions BEP. These restrictions are especially relevant for unacreddited ("everyday") investors.

## 5.  Specification

### 5.1 Token Attributes For Whitelist

* Tokens have a `whitelist_required_for_transfer` attribute of type `boolean`
* Tokens have a `whitelist` of type `[address]`

### 5.2 Token Whitelist Attribute Access Restrictions
* Only the token owner can set the `whitelist_required_for_transfer` boolean value
* Only the token owner can add and remove adresses from the whitelist
* Anyone can get the list of addresses on the whitelist
* Anyone can check if a specific address is on the whitelist
* Anyone can check the value of `whitelist_required_for_transfer`

### 5.3 Token Transfer Access Restrictions

If `whitelist_required_for_transfer` is `true` then: 
1. Only whitelisted addresses can receive transfers
2. Only whitelisted addresses can place buy or sell orders for the Token

## 6. References

### Stellar Custom Asset Examples

* [Stellar](https://www.stellar.org/) - Implements [Custom Assets](https://www.stellar.org/developers/guides/walkthroughs/custom-assets.html) and relies heavily on off chain servers to enforce rules using a [Compliance Protocol](https://www.stellar.org/developers/guides/compliance-protocol.html) and an AUTH_SERVER. The off chain compliance checks allows the Stellar blockchain to be simpler than Ethereum smart contract enforcement. In the [Interstellar DEX](https://interstellar.exchange/), these checks can be done prior to matching trades. Stellar has the concept of custom assets and whitelists but does not have smart contracts which makes it a much simpler blockchain.
* [Securrency](https://www.securrency.com/) - Securrency’s rules engine enables sophisticated multi-jurisdictional compliance checks. It works for both Stellar and Ethereum. It has a complex reasoning engine for calculating legal restrictions in many jurisdictions. It does this work off chain so it does not need to wait on block time. Then it enforces these restrictions at the contract level on a per trade basis. Features enabling rules engines like Seccurency’s are an attractive and potentially lightweight option to comply with changing and complex regulations. This is a good subject for a future BEP.

### Ethereum Digital Asset Smart Contract Examples

* [Securitize](https://www.securitize.io/) - uses solidity smart contracts for an onchain whitelist. Minimum and maximum holders can be enforced. Whitelisted participants can register multiple addresses representing a single holder. The whitelist is updated by the issuer or trusted parties such as registered exchanges that are authorized by the issuer. Notably the Securitize platform was used for early security token issuance such as BCAP, SPICE, and CityBlock.
* [Polymath](https://polymath.network/) - uses solidity smart contracts for an onchain whitelist. The issuer can update the whitelist.
* [CoinAlpha](https://www.coinalpha.com/home) - Specializes in funds and enforces requirements using solidity smart contracts. [Blog post explaining rationale](https://medium.com/hummingbot/essential-crypto-regs-for-decentralized-finance-10a99e3b13ac). Here’s a repository [implementing a KYC protocol contract](https://github.com/CoinAlpha/kyc-basket-protocol).
* [R-Token by Harbor](https://harbor.com/) provides off chain vetting and on chain enforcement. Here’s an article [describing the architecture](https://medium.com/coinmonks/a-security-token-harbors-r-token-c147ba9557b4). Here’s a link to the [R-token docs](https://github.com/harborhq/r-token/blob/master/README.md).

### Emerging Ethereum Industry Standards

* [ERC-1404](https://erc1404.org/) “Simple restricted token standard” proposed via an [Ethereum Improvement Proposal](https://github.com/ethereum/EIPs/issues/1404). Here’s a great article on the reasoning around implementing ERC-1404 for different projects.
* [Open Zeppelin](https://openzeppelin.org/) open source contracts are used by many token projects for custom token creation. They maintain a [WhitelistCrowdsale](https://github.com/OpenZeppelin/openzeppelin-solidity/blob/v2.1.1/contracts/crowdsale/validation/WhitelistCrowdsale.sol) contract. They also provide the popular Ownable contract for managing functions that can only be performed by the owner of a token.

## 7. License

The content is licensed under [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
