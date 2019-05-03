# BEP-5 Token Resources [IMPROVEMENT]


- BEP-5 Token Resources
  * [1.  Summary](#1--summary)
  * [2.  Abstract](#2--abstract)
  * [3.  Status](#3--status)
  * [4.  Motivation](#4--motivation)
  * [5.  Specification](#5--specification)
    + [5.1 Token Resource](#51-token-resource)
    + [5.2 URI Specification](#52-uri-specification)
    + [5.3 JSON SCHEMA](#53-json-schema)
    + [5.4 Hosting](#54-hosting)
    + [5.5 Token Resource Management](#55-token-resource-management)
      - [5.5.1 Add Token Resource](#551-add-token-resource)
      - [5.5.2 Handling Token Resources](#552-handling-token-resources)
      - [5.3.3 Placeholder URI](#553-placeholder-uri)
      - [5.3.4 Founderless Projects](#554-founderless-projects)
  * [6. License](#6-license)


## 1.  Summary

This BEP describes an improvement to the [BEP-2 Token standard](https://github.com/binance-chain/BEPs/blob/master/BEP2.md) to add resources for token management on the Binance Chain.

## 2.  Abstract

The BEP-5 Proposal describes a common set of rules for adding token resources to BEP-2 tokens on the Binance Chain ecosystem. It adds the following detail of a token on Binance Chain:

- What information can be added to a BEP-2 Token (BEP-5 Token Resource)
- What actions can be performed to manage BEP-5 Token Resources on Binance Chain



## 3.  Status

This BEP is a work in progress (WIP).

## 4.  Motivation

BEP-2 tokens currently specify their `Name`, `Address`, `Symbol`, `Supply` and `Mintable` status. However, no other information can be added, which results in either Binance or wallet developers hosting additional information that is not distributed widely across the ecosystem and can become siloed.

> As an example, icons for tokens allow easier identification of tokens in wallets and dapps, and should be sourced from somewhere. Currently developers host their own copies of token logos, or retrieve them from CoinMarketCap paid API.

In order to facilitate a rich ecosystem of tokens and the standardising of information around them, tokens should be allowed to add a resource pointer that allows retrieving of basic (and extensible) token information.

The resource pointer will be a Uniform Resource Identifier (URI) that queries for resources.

## 5.  Specification

### 5.1 Token Resource

BEP-2 Tokens can be deployed to Binance Chain via the BEP-2 token issuing process.

A token resource can be added as part of the listing command:

```
- Source Address: Source Address is the owner of the issued token.

- Token Name: Token Name represents the long name of the token - e.g. "MyToken".

- Symbol: Symbol is the identifier of the newly issued token.

- Total Supply: Total supply will be the total number of issued tokens.

- Mintable: Mintable means whether this token can be minted in the future, which would increase the total supply of the token

- URI: Token URI returns a URL that specifies Token Resources

```


### 5.2 URI Specification

The Token URI points to a URL that is hosted by project teams that returns a JSON file:

```json
{
  "description": "Token is a decentralised project that is building the future of payments",
  "website": "https://token.io",
  "icon": "https://token.io/icon.png",
  "contact": {
    "website": "https://token.io",
    "twitter": "https://twitter.com/token",
    "telegram": "https://t.me/token",
    "support": "https://support.token.io/",
    "blog": "https://medium.com/token"
  },
  "media": {
    "icon": "https://token.io/icon.png",
    "icon_large": "https://token.io/icon_large.png",
    "logo": "https://token.io/logo.png",
    "logo_large": "https://token.io/logo_large.png",
  },
  "other": {
    "****": "****",
  }
}
```

### 5.3 JSON SCHEMA

The following are the implementation standards to allow wallets and dapps to standardise displaying of resources.

There are four mandatory data resources to be returned to be compatible with BEP-5, specified as `required`. The rest are optional but will enhance the project's view data in dapps.

**Required**
```
{
  "description": "Token is a decentralised project that is building the future of payments"
  "website": "https://token.io"
  "icon": "https://token.io/icon.png"
}
```
Description:
- A short paragraph that describes the token
- Max 200 character string.

Website:
- A url that points to the project website

Icon:
- A URL which returns a square image file
- Image file to be 256px * 256px square PNG file with transparent background
- (JPEG/JPG) can also be used
- Smaller files are not preferred

**Optional**
Optional data is specified under Contact, Media and Other
- Anything can be added to the data
- URLs, strings or numbers are preferred


### 5.4 Hosting

The JSON Resource can be hosted and maintained anywhere, such as github or on the token project's website.


###  5.5 Token Resource Management

#### 5.5.1 Add Token Resource

Token issuer creates a new token on Binance Chain and specifies the URI.

**Data Structure for Token Resources**:

The data structure to be added to the existing BEP-2 Data Structure is:

| **Field**    | **Type** | **Description**                                              |
| :------------ | :-------- | :------------------------------------------------------------ |
| URI | string | The resource url to return BEP-5 Token Resources. Max of 120 characters.


The data in the URI field can be updated by the token owner at any time and will incur a fee to be set by Binance Chain Validators.


**Update Process:**
URIs can be updated by the token issuer at any time.

- Issuer signs an on-chain transaction that specifies the new URI using the Binance Chain SDK API, RPC or CLI.

Example of CLI command:
```
./bnbcli token uri --symbol TKN-099 --uri "new-URI"
```

#### 5.5.2 Handling Token Resources

**Retrieving Resources:**
Once the URI is updated for the token and the resource is being hosting the required data can then be queried by the wallet or DAPP, such as `token.icon` or `token.media.logo` which will return a URL to retrieve the hosted files.

The DAPP developer can then choose to display the resources as required.

**Invalid Resources:**
If the project team do not add a URI, or the resource can not be successfully retrieved then the DAPP will query for the default Binance Chain resource placeholder.

#### 5.5.3 Placeholder URI

Binance may host a placeholder resource JSON file at a known endpoint, such as https://binance.org/placeholder.json which returns a URI such as the following:

```json
{
  "description": "Binance Chain Token",
  "website": "https://binance.org",
  "icon": "https://binance.org/icon.png"
}
```

This can be used by DAPP developers to display placeholder images in case of broken project resources.

#### 5.5.4 Founderless Projects

Some projects have no known founders, such as Bitcoin and Grin. URIs for these projects can be maintained by Binance.


## 6. License

The content is licensed under [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
