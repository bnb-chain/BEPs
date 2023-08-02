# BEP-64: BNB Payment URI Scheme

- [BEP-64: BNB Payment URI Scheme](#bep-64--BNB-Payment-URI-Scheme)
  * [1. Abstract](#1-Abstract)
  * [2. Motivation](#2-Motivation)
  * [3. Specification](#3-Specification)
    + [3.1 General rules for handling](#31-General-rules-for-handling)
    + [3.2 Operating system integration](#32-Operating-system-integration)
    + [3.3 General Format](#33-General-Format)
    + [3.4 ABNF grammar](#34-ABNF-grammar)
    + [3.5 Query Keys](#35-Query-Keys)
  * [4. Rationale](#4-Rationale)
    + [4.1 Payment identifiers, not person identifiers](#41-Payment-identifiers-not-person-identifiers)
    + [4.2 Accessibility (URI scheme name)](#42-Accessibility-URI-scheme-name))
  * [5. Forward compatibility](#5-Forward-compatibility)
  * [6. Backward compatibility](#6-Backward-compatibility)
  * [7. Appendix](#7-Appendix)
    + [7.1 Simpler syntax](#71-Simpler-syntax)
    + [7.2 Examples](#72-Examples)
  * [8. Reference Implementations](#8-Reference-Implementations)
    + [8.1 Binance clients](#81-Binance-clients)
    + [8.2 Libraries](#82-Libraries)

This BEP is derived and extended from bip-0021

## 1. Abstract
This BEP proposes a URI scheme for making BNB Beacon Chain payments.

## 2. Motivation
The purpose of this URI scheme is to enable users to easily make payments by simply clicking links on webpages or scanning QR Codes.

## 3. Specification

### 3.1 General rules for handling

BNB Beacon Chain clients MUST NOT act on URIs without getting the user's authorization.

They SHOULD require the user to manually approve each payment individually, though in some cases they MAY allow the user to automatically make this decision.

### 3.2 Operating system integration
Graphical binance clients SHOULD register themselves as the handler for the "bnb:" URI scheme by default, if no other handler is already registered. If there is already a registered handler, they MAY prompt the user to change it once when they first run the client.

### 3.3 General Format

Binance URIs follow the general format for URIs as set forth in RFC 3986. The path component consists of a binance address, and the query component provides additional payment options.

Elements of the query component may contain characters outside the valid range. These must first be encoded according to UTF-8, and then each octet of the corresponding UTF-8 sequence must be percent-encoded as described in RFC 3986.

### 3.4 ABNF grammar

(See also [a simpler representation of syntax](#71-Simpler-syntax))

```
 binanceurn     = "bnb:" binanceaddress [ "?" binanceparams ]
 binanceaddress = *base58
 binanceparams  = binanceparam [ "&" binanceparams ]
 binanceparam   = [ amountparam / memoparam / assetparam / metadata]

 amountparam    = "amount=" *digit [ "." *digit ]
 memoparam     = "memo=" *qchar
 assetparam   = "asset=" *qchar
 metadata = <optional, base64 encoded 1024 maximum raw bytes>
```

Here, "qchar" corresponds to valid characters of an RFC 3986 URI query component, excluding the "=" and "&" characters, which this BEP takes as separators. And optional metadata field is for extensible purpose, customizable content for different app parsing.

The scheme component ("bnb:") is case-insensitive, and implementations must accept any combination of uppercase and lowercase letters. The rest of the URI is case-sensitive, including the query parameter keys.

### 3.5 Query Keys

* address: binance address

* memo: memo that goes with the transaction on chain ([[#Examples|see examples below]])

* asset: entire asset name, including the "-XXX" random suffix. For BNB, it will be just "BNB", or just don't provide this parameter to take BNB as default value.

* amount: how much of this asset will be transfered

* (others): optional, for future extensions

#### 3.5.1 Transfer amount/size

If an amount is provided, it MUST be specified in decimal.

All amounts MUST NOT have more than 8 decimal digits.

I.e. amount=50.123456789 is invalid.

All amounts MUST contain no commas and use a period (.) as the separating character to separate whole numbers and decimal fractions.

I.e. amount=50.00 or amount=50 is treated as 50, and amount=50,000.00 is invalid.

Binance clients MAY display the amount in any format that is not intended to deceive the user.

They SHOULD choose a format that is foremost least confusing, and only after that most reasonable given the amount requested.

## 4. Rationale

### 4.1 Payment identifiers, not person identifiers
It is not feasible to use a unique address for every transaction on BNB Beacon Chain.
Therefore, the best practices are that using different memos as distinguishers.

### 4.2 Accessibility (URI scheme name)
Should someone from the outside happen to see such a URI, the URI scheme name already gives a description.

A quick search should then do the rest to help them find the resources needed to make their payment.

Other proposed names sound much more cryptic; the chance that someone googles that out of curiosity are much slimmer.

Also, very likely, what he will find are mostly technical specifications - not the best introduction to binance.

## 5. Forward compatibility
Variables which are prefixed with a req- are considered required.  If a client does not implement any variables which are prefixed with req-, it MUST consider the entire URI invalid.  Any other variables which are not implemented, but which are not prefixed with a req-, can be safely ignored.

## 6. Backward compatibility
Currently no URI like `bnb:` is adopted by any exising wallet, all clear here.

## 7. Appendix

### 7.1 Simpler syntax 

This section is non-normative and does not cover all possible syntax.
Please see the BNF grammar above for the normative syntax.

[foo] means optional, &lt;bar&gt; are placeholders

`binance:<address>[?asset=<asset>][?amount=<amount>][?memo=<memo>]`

### 7.2 Examples

Just the address:
 `binance:bnb1ws9c2z9lgu0nyhl6wgm08wl4kdwkunwev06pmr`

Address with specified asset BUSD:
 `binance:bnb1ws9c2z9lgu0nyhl6wgm08wl4kdwkunwev06pmr?asset=BUSD-BD1`

Request 20.30 BNB:
 `binance:bnb1ws9c2z9lgu0nyhl6wgm08wl4kdwkunwev06pmr?amount=20.3`

Request 20.30 BUSD:
 `binance:bnb1ws9c2z9lgu0nyhl6wgm08wl4kdwkunwev06pmr?asset=BUSD-BD1&amount=20.3`

Request 50 BNB with memo as off-chain transaction identifier:
 `binance:bnb1ws9c2z9lgu0nyhl6wgm08wl4kdwkunwev06pmr?amount=50&memo=48clubdonationxx000000001`

Some future version that has variables which are (currently) not understood and required and thus invalid:
 `binance:bnb1ws9c2z9lgu0nyhl6wgm08wl4kdwkunwev06pmr?req-somethingyoudontunderstand=50&req-somethingelseyoudontget=999`

Some future version that has variables which are (currently) not understood but not required and thus valid:
 `binance:bnb1ws9c2z9lgu0nyhl6wgm08wl4kdwkunwev06pmr?somethingyoudontunderstand=50&somethingelseyoudontget=999`

Characters must be URI encoded properly.

## 8. Reference Implementations
### 8.1 Binance clients
* Trust Wallet supports a similar implementation of bip-0021 with binance instead of bitcoin 
### 8.2 Libraries
* Not available
