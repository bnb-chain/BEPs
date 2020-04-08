# BEP70: List and Trade BUSD Pairs

- [BEP-70: List and Trade BUSD Pairs](#bep-70-list-and-trade-buse-pairs)
  - [1.  Summary](#1--summary)
  - [2.  Abstract](#2--abstract)
  - [3.  Status](#3--status)
  - [4.  Motivation](#4--motivation)
  - [5.  Specification](#5--specification)
    - [5.1 Proposing and Listing](#51-proposing-and-listing)
      - [5.1.1 Current Restriction](#511-current-restriction)
      - [5.1.2 Proposed Changes](#512-proposed-changes)
    - [5.2 Trading Fee Calculation](#52-trading-fee-calculation)
  - [6. License](#6-license)

## 1. Summary
This BEP describes a proposal for listing and trading BUSD pairs without explicit dependency on the native token BNB.

## 2. Abstract
BUSD, as one of the most influential stable coins worldwide and the most dominant stable coin on Binance Chain, is playing an important role for trading and communicating with fiat currencies. Listing and trading BUSD pairs on Binance Chain will facilitate token owners and exchange traders, making the markets more liquid and healthier. 

However, on Binance Chain now, if you want to trade between your token and BUSD , you must firstly list a trading pair between BNB and the token you have, which could be unnecessary sometimes. 

This BEP proposes the solutions for listing and trading BUSD pairs without explicit dependency on BNB.

## 3. Status
Draft

## 4. Motivation
The purpose of this BEP are   
1. Relaxing the restriction of listing, and  
2. Providing another channel for exchanging stable coins,     
leading to more diversified choices for token owners and exchange traders.

## 5. Specification
### 5.1 Proposing and Listing
#### 5.1.1 Current Restriction
Currently, for listing a trading pair between AAA and BUSD, there are following prerequisites:
+ Existed trading pair between AAA and BNB
+ Existed trading pair between BUSD and BNB
For more information about governance proposal, please refer to the following page:   
[https://docs.binance.org/governance.html](https://docs.binance.org/governance.html)

#### 5.1.2 Proposed Changes
For proposing and listing BUSD trading pairs, BUSD must be the base asset or quote asset. It means the BaseAssetSymbol or QuoteAssetSymbol must be BUSD-BD1 on the mainnet, and QuoteAssetSymbol or BaseAssetSymbol does not have to be BNB. 

|     **Name**        | **Type**    |    **Description**        |
| ------------------- | ----------- | ------------------------  |
| BaseAssetSymbol     | string      | base asset symbol, use BUSD symbol for BUSD pair |
| QuoteAssetSymbol    | string      | quote asset symbol, use BUSD symbol for BUSD pair |

With the proposed changes, for listing a trading pair between AAA and BUSD, the chain will not ask for the existence of any trading pair between AAA and BNB. The main restriction will be:
+ Existed trading pair between BUSD and BNB, which is already satisfied on mainnet now.

### 5.2 Trading Fee Calculation
To calculate the trading fees, the price of BNB denominated in BUSD will be used if needed.
For more information about trading fees, please refer to the following page:  
[https://docs.binance.org/trading-spec.html](https://docs.binance.org/trading-spec.html)


## 6. License
The content is licensed under [CC0](https://creativecommons.org/publicdomain/zero/1.0/).