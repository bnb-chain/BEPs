# BEP-7: Non-fungible Tokens on Binance Chain

- [BEP-7: Non-fungible Tokens on Binance Chain](#bep-7-non-fungible-tokens-on-binance-chain)
  - [1. Summary](#1-summary)
  - [2. Abstract](#2-abstract)
  - [3. Status](#3-status)
    - [Couple things to keep in mind](couple-things-to-keep-in-mind)
  - [4. Motivation](#4-motivation)
  - [5. Collection Specification](#5-collection-specification)
    - [5.1 Collection Properties](#51-collection-properties)
    - [5.2 Collection Management Operation](#52-collection-management-operation)
      - [5.2.1 Issue collection](#521-issue-collection)
      - [5.2.2 Increase total supply](#522-increase-total-supply)
  - [6. Token Specification](#6-token-specification)
    - [6.1 Token Properties](#61-token-properties)
    - [6.2 Token Management Operation](#62-token-management-operation)
      - [6.2.1 Issue token](#621-issue-token)
      - [6.2.2 Transfer Tokens](#622-transfer-tokens)
      - [6.2.3 Freeze Tokens](#623-freeze-tokens)
      - [6.2.4 Unfreeze Tokens](#624-unfreeze-tokens)
  - [7. Token Use Case Examples](#7-token-use-case-examples)
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

- Owner: the owner adress of the collection.

- Token Name: Token Name represents the long name of the token - e.g. "BinanceAnnualEvent2019"

- Denom: Denom is the identifier(symbol) of the newly issued collection.

- Total Supply: Total supply is the total number of issued NFT tokens belong to this collection.

- Mintable: A boolean value to indicate whether the owner can increase the totalSupply.

- NFTs: An array contains items in NFT interface(described below).

```go
// Collection of non fungible tokens
type Collection struct {
  Owner         string  `json:"owner"`                    // owner of the collection;
  Name          string  `json:"name"`                     // name of the collection;
  Denom         string  `json:"denom,string,omitempty"`   // the identifier(symbol) of the newly issued collection;
  TotalSupply   int64   `json:"totalSupply"`              // total supply of the NFT in this collection;
  Mintable      bool    `json:"mintable"`                 // can increase total supply or not;
  NFTs          []NFT   `json:"nfts"`                     // NFTs that belong to a collection;
}
```

### 5.2 Collection Management Operation

#### 5.2.1 Issue collection

Issuing collection is to create a new unique collection which contains non-fungible token as children on Binance Chain. The new collection represents ownership of something new, and can also peg to existing NFT token from any other blockchains. **The difficulty of creating a BEP7 collection should be indentical to creating BEP2 token, in order to block scammers.**

| **Field**  | **Type**  | **Description**              |
| :--------- | :-------- | :---------------------------- |
| Owner      | address   | the owner adress of the collection |
| Name       | string    | name of the collection |
| Denom      | string    | The symbol of the collection |
| TotalSupply| int64     | total supply of the NFT in this collection |
| Mintable:  | bool      | true indicates the owner can increase the totalSupply |
| NFTs       | []NFT     | A set of NFT token |

```go
// NewCollection creates a new NFT Collection
func NewCollection(name string, denom string, totalSupply uint64, nfts NFTs) Collection {
  return Collection{
    Name: strings.TrimSpace(name),
    Denom: strings.TrimSpace(denom),
    TotalSupply: uint64(totalSupply),
    NFTs:  NewNFTs([]NFT(nfts)...),
  }
}
```

#### 5.2.2 Increase total supply

This can be performed only when the following conditions are satisfied:

1. Performance is the collection owner.

2. Mintable value of the collection is true

| **Field**  | **Type**  | **Description**              |
| :--------- | :-------- | :---------------------------- |
| Denom      | string    | The symbol of the collection |
| Amount     | int64     | The amount is positive and can have a maximum of 8 digits of decimal and is boosted by 1e8 in order to store as int64. |

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

- collection: The denom of the collection it belongs to.

- ID: Unique id of the token.

- Owner: The owner address.

- MetadataURI(OPTIONAL): Contains more details about the assets which this NFT represents

```go
// Collection of non fungible tokens
type Collection struct {
  Collection    string  `json:"collection"`              // sumbol of the collection it belongs to;
  ID            string  `json:"denom,string,omitempty"`  // unique ID;
  Owner         int64   `json:"owner"`                   // total supply of the NFT in this collection;
  MetadataURI   string  `json:"mintable"`                // can increase total supply or not;
}
```

#### 6.1.1 MetadataURI Example

The metadata extension is OPTIONAL for BEP-7 token. This allows your smart contract to be interrogated for its name and for details about the assets which your NFTs represent.

 ```json
{
    "title": "Asset MetadataURI",
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

This can be performed only when the following conditions are satisfied:

1. Performance is the collection owner.

2. The amount of the minted tokens on the collections has not exceeded the total supply of the collection.

Issuing token is to create a new non-fungible token on Binance Chain. The new non-fungible token represents ownership of something new, and can also peg to existing tokens from any other blockchains.

**Data Structure for Issue Operation**: A data structure is needed to represent the new token:

| **Field**    | **Type** | **Description**                                              |
| :------------ | :--------  | :------------------------------------------------------------ |
| collection    | string     | The denom of the collection it belongs to |
| ID            | string     | Incremental id in the collection it belongs to |
| Owner         | Address    | The owner of this token |
| MetadataURI   | string     | OPTIONAL. Contains more details about the assets which this NFTs represent |

```go
// NewBaseNFT creates a new NFT instance
func NewBaseNFT(ID string, owner address, metadataURI string,
) BaseNFT {
  return BaseNFT{
    Collection:  collection,
    ID:          ID,
    Owner:       owner,
    MetadataURI: strings.TrimSpace(metadataURI),
  }
}
```

#### 6.2.2 Transfer Tokens

Transfer transaction is to send tokens from input addresses to output addresses.

**Message Structure for Transfer Operation**: A data structure is needed to represent the transfer operation between addresses.

| **Field** | **Type** | **Description**              |
| :--------- | :-------- | :---------------------------- |
| Input     | []Input  | A set of transaction inputs  |
| Output    | []Output | A set of transaction outputs |

**Input Data Structure:**

| **Field** | **Type** | **Description**                                              |
| :--------- | :-------- | :------------------------------------------------------------ |
| Address   | Address  | Address for token holders                                    |
| Coins     | []Coin   | A set of sorted coins, one per currency. The symbols of coins are in descending order. |

**Output Data Structure:**

| **Field** | **Type** | **Description**                                              |
| :--------- | :-------- | :------------------------------------------------------------ |
| Address   | Address  | Address for token holders                                    |
| Coins     | []Coin   | A set of sorted coins, one per currency. The denominations of coins are in descending order. |

**Coin Structure:**

| **Field** | **Type** | **Description**                                                 |
| :--------- | :-------- | :------------------------------------------------------------ |
| Denom     | string   | The symbol of a collection                                      |
| ID        | string   | The id of a token in the collection                             |
| Amount    | int64    | The amount is positive and can have a maximum of 8 digits of decimal and is boosted by 1e8 in order to store as int64. |

**Transfer Process:**

- Transferer initiators sign a transfer transaction and make it broadcasted to one of Binance Chain nodes
- The Binance Chain node will check this transaction. If there is no error, then this transaction will be broadcasted to other Binance Chain nodes
- Transfer transaction is committed on the blockchain by block proposer
- Validators will verify the constraints on balance. The transfer tokens and fee will be deducted from the address of the transaction initiators.
- Add the tokens to the destination addresses

#### 6.2.3 Freeze Tokens

A Binance Chain user could freeze some amount of tokens in his own address. The freeze transaction will lock his fund, thus this portion of tokens could not be used for the transactions, such as: creating orders, transferring to another account, paying fees and etc.  

**Data Structure** **for Freeze Operation**: A data structure is needed to represent the freeze operation

| **Field** | **Type** | **Description**                                                 |
| :--------- | :-------- | :------------------------------------------------------------ |
| Denom     | string   | The symbol of a collection - e.g. NNB-B90                       |
| ID        | string   | The id of a token in the collection                             |

**Freeze Process:**

- Address-holder signed a freeze transaction and make it broadcasted to one of Binance Chain nodes
- The Binance Chain node will check this transaction. If there is no error, then this transaction will be broadcasted to other Binance Chain nodes
- Freeze transaction is committed on the blockchain by block proposer
- Validators will verify the transaction initiator’s balance is no less than the frozen amount. The fee will be deducted from the transaction initiator’s address.  
- This amount of tokens in the address of the transaction initiator will be moved from balance to frozen.

#### 6.2.4 Unfreeze Tokens

Unfreezing is to unlock some of the frozen tokens in the user's account and make them liquid again.

**Data Structure** **for Unfreeze Operation**: A data structure is needed to represent the freeze/unfreeze operation

| **Field** | **Type** | **Description**                                              |
| :--------- | :-------- | :------------------------------------------------------------ |
| Denom     | string   | The symbol of a collection - e.g. NNB-B90                       |
| ID        | string   | The id of a token in the collection                             |

**Unfreeze Process:**

- Address-holder signed an unfreeze transaction and make it broadcasted to one of Binance Chain nodes
- The Binance Chain node will check this transaction. If there is no error, then this transaction will be broadcasted to other Binance Chain nodes
- Unfreeze transaction is committed on the blockchain by block proposer
- Validators will verify the transaction initiator’s frozen balance is no less than the required amount. The fee will be deducted from the address of the transaction source.
- This amount of token will be moved from frozen to balance in the transaction initiator’s address.

## 7. Token Use Case Examples

With Non-fungible Tokens, we can expand the token use cases on Binance Chain to be:

- Event Ticket
- VIP Privilege Status
- Collectibles Assets
- more ...

Every token is transferrable, tradable, mintable, burnable and most important, non-fungible.

## 8. License

The content is licensed under [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

## 9. Reference

- [ERC-721 Non-Fungible Token Standard](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md)
- [ERC-165 Standard Interface Detection](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-165.md)
- [ERC-1538 Transparent Contract Standard](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1538.md)
- [ERC-1155 Multi Token Standard](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1155.md)
- [NFT Module on cosmos-sdk](https://github.com/cosmos/cosmos-sdk/issues/4046)
- [NFT Sample Implementation on cosmos-sdk](https://github.com/cosmos/cosmos-sdk/pull/4209)