# BEP-7: Non-fungible Tokens on Binance Chain

- [BEP-7: Non-fungible Tokens on Binance Chain](#bep-7-non-fungible-tokens-on-binance-chain)
  - [1. Summary](#1--summary)
  - [2. Abstract](#2--abstract)
  - [3. Status](#3--status)
    - [Couple things to keep in mind](couple-things-to-keep-in-mind)
  - [4. Motivation](#4--motivation)
  - [5. Collection Specification](#5--specification)
    - [5.1 Collection Properties](#51--collection-properties)
    - [5.2 Collection Management Operation](#52--token-management-operation)
        - [5.2.1 Issue collection](#521--issue-collection)
  - [6. Token Specification](#5--token-specification)
    - [6.1 Properties](#52--token-properties)
    - [6.2 Token Management Operation](#62--token-management-operation)
        - [6.3.1 Issue token](#631--issue-token)
        - [6.3.2 Transfer Tokens](#632--transfer-tokens)
        - [6.3.3 Freeze Tokens](#633--freeze-tokens)
        - [6.3.4 Unfreeze Tokens](#634--unfreeze-tokens)
        - [6.3.5 Mint Tokens](#635--mint-tokens)
        - [6.3.6 Burn Tokens](#636--burn-tokens)
  - [7. Token Use Case Examples](#7--token-use-case-examples)
  - [8. License](#8-license)
  - [9. Reference](#9-reference)

## 1. Summary

This BEP describes a proposal for non-fungible tokens(NFTs) management on the Binance Chain.

## 2. Abstract

BEP-7 Proposal describes a common set of rules for non-fungible token within the Binance Chain ecosystem. It introduces the following details of a non-fungible token on Binance Chain:

- What information makes a non-fungible token on Binance Chain
- What actions can be performed on a non-fungible token on Binance Chain

### Couple things to keep in mind

- This BEP won't contain "how to implement" in terms of implmentation on the Binance Chain codebase, e.g. which module NFT should be in (this kind of discussion is happening on [cosmos-sdk/issues/4046](https://github.com/cosmos/cosmos-sdk/issues/4046)), because that should be happening in the PR(against to Binance Chain, when it's fully open source, so that dev can send out PR.

- Apparently Binance chain doens't have solidity-such smart contract implemented, so don't expect to see many smart contract implmenations like what you can see in [EIP-721](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md) in this BEP.

## 3. Status

This BEP is under drafting.

## 4. Motivation

Design and issue non-fungible asset on the Binance Chain, as one of the basic economic foundations of the blockchain.

## 5. Collection Specification

### 5.1 Collection Properties

- Token Name: Token Name represents the long name of the token - e.g. "BinanceAnnualEvent2019"

- Symbol: Symbol is the identifier of the newly issued collection.

- Total Supply: Total supply is the total number of issued NFT tokens belong to this collection.

- NFTs: An array contains items in NFT interface(described below)

```go
// Collection of non fungible tokens
type Collection struct {
  Name          string  `json:"name"`
	Symbol        string  `json:"symbol,string,omitempty"` // name of the collection;
  TotalSupply   int64   `json:"totalSupply"`             // total supply of the NFT in this collection;
	NFTs          NFTs    `json:"nfts"`                    // NFTs that belong to a collection;
}
```

### 5.2 Collection Management Operation

#### 5.2.1 Issue collection

Issuing collection is to create a new unique collection which contains non-fungible token as children on Binance Chain. The new collection represents ownership of something new, and can also peg to existing NFT token from any other blockchains.

| **Field**  | **Type**  | **Description**              |
| :--------- | :-------- | :---------------------------- |
| Name       | string    | name of the collection |
| Symbol     | string    | symbol of the collection |
| TotalSupply| int64     | total supply of the NFT in this collection |
| NFTs       | []NFT     | A set of NFT token |

```go
// NewCollection creates a new NFT Collection
func NewCollection(name string, symbol string, totalSupply uint64, nfts NFTs) Collection {
	return Collection{
    Name: strings.TrimSpace(name),
		Symbol: strings.TrimSpace(symbol),
    TotalSupply: uint64(totalSupply),
    NFTs:  NewNFTs([]NFT(nfts)...),
	}
}
```

**Symbol Convention:**

[Symbol][.B]-[Suffix]

Explanations: Suffix is the first 3 bytes of the issue transaction’s hash. It helps to remove the constraint of requiring unique token names. If this token pegs to an existing blockchain, there should be an additional suffix of “.B”.

**Issue Process:**

- Issuer signed an issue transaction and make it broadcasted to one of Binance Chain nodes
- This Binance Chain node will check this transaction. If there is no error, then this transaction will be broadcasted to other Binance Chain nodes
- Issue transaction is committed on the blockchain by block proposer
- Validators will verify the constraints on total supply and symbol and deduct the fee from issuer’s account
- New token’s symbol is generated based on the transaction hash. It is added to the issuer’s address and token info is saved on the Binance Chain

## 6. Token Specification

### 6.1 Token Properties

To be compatibile to other NFT on other blockchain as much as possible. Excepts to Id and Owner, Name, Description, ImageURI, and TokenURI are all described in 

- Id: Unique id of the token.

- Owner: The owner address.

- Metadata(OPTIONAL): Contains more details about the assets which this NFT represents

```go
// BaseNFT non fungible token definition
type BaseNFT struct {
	ID          string         `json:"id,omitempty"` // id of the token; not exported to clients
	Owner       sdk.AccAddress `json:"owner"`        // account address that owns the NFT
	Metadata    object         `json:"metadata"`     // more details about the assets which this NFT represents
}
```

#### 6.1.1 Metadata Example

 This is the example of what the "Metadata" can contain, compliant to [ERC721 Metadata JSON Schema](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md)

 ```json
{
    "title": "Asset Metadata",
    "type": "object",
    "properties": {
        "name": {
            "type": "string",
            "description": "Identifies the asset to which this NFT represents"
        },
        "description": {
            "type": "string",
            "description": "Describes the asset to which this NFT represents"
        },
        "image": {
            "type": "string",
            "description": "A URI pointing to a resource with mime type image/* representing the asset to which this NFT represents. Consider making any images at a width between 320 and 1080 pixels and aspect ratio between 1.91:1 and 4:5 inclusive."
        },
        "tokenURI": {
            "type": "string",
            "description": "A URI pointing to a resource with more token related metadata that doesn't belong on chain."
        }
    }
}
```

#### 6.2 Token Management Operation

#### 6.2.1 Issue token

Issuing token is to create a new non-fungible token on Binance Chain. The new non-fungible token represents ownership of something new, and can also peg to existing tokens from any other blockchains.

#### 6.2.2 Transfer Tokens

#### 6.2.3  Freeze Tokens

A Binance Chain user could freeze some amount of tokens in his own address. The freeze transaction will lock his fund, thus this portion of tokens could not be used for the transactions, such as: creating orders, transferring to another account, paying fees and etc.  

#### 6.2.4  Unfreeze Tokens

Unfreezing is to unlock some of the frozen tokens in the user's account and make them liquid again.

#### 6.2.5 Mint Tokens

Mint transaction is to increase the total supply of a mintable token. The transaction initiator must be the token owner.

#### 6.2.6 Burn Tokens

Burn transaction is to reduce the total supply of a token. The transaction initiator must be the token owner. 

## 7. Token Use Case Examples

With Non-fungible Tokens, we can expand the token use cases on Binance Chain to be:

- Event Ticket
- VIP Privilege Status
- Collectibles Assets
- more ...

Every token is transferrable, tradable, mintable, burnable and most important, non-fungible.

## 8. License

The content is licensed under [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

## 9. References

- [Ethereum eip-721](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md)
- [NFT Module on cosmos/cosmos-sdk](https://github.com/cosmos/cosmos-sdk/issues/4046)
- [NFT Sample Implementation #4209 on cosmos/cosmos-sdk](https://github.com/cosmos/cosmos-sdk/pull/4209)

