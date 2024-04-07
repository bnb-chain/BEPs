# BEP-39: Add MEMO to Transfer WebSocket.

- BEP-39: Add MEMO to Transfer WebSocket
  - [1. Summary](#1-summary)
  - [2. Abstract](#2-abstract)
  - [3. Status](#3-status)
  - [4. Motivation](#4-motivation)
  - [5. Specification](#5-specification)
    - [5.1 Websocket](#51-websocket)
  - [6. License](#6-license)

## 1.  Summary 

This BEP describes an improvement to the [Transfer Websocket](https://docs.bnbchain.org/docs/beaconchain/develop/api-reference/dex-api/ws-streams#2-transfer).  

## 2.  Abstract

BEP-39 requests that `MEMO` data field be added to the `/ws/userAddress` websocket. 

Currently the `MEMO` field is not being returned on the websocket, which means that services that rely on `MEMO` to set transaction specifications must then retrieve it from the [Transaction API endpoint](https://docs.bnbchain.org/docs/beaconchain/develop/api-reference/dex-api/paths/#transaction).

This creates unnecessary burden on the API and slows down the transaction processing. 

The solution is to add it to the Transfer Websocket as a data field to stream. 

## 3.  Status

This BEP is already implemented.

## 4.  Motivation

Wallets, exchanges, dApps and other services will set transaction state in the `MEMO` to allow them to be stateless. 

To improve the speed at which the `MEMO` field can be read and processed, it should be added to the websocket so it doesn't burden BNB Beacon Chain Node API endpoints, which are rate-limited. 

## 5.  Specification

###  5.1 Websocket

The following is the update for the `/ws/userAddress` websocket with the added `MEMO` field:

```
{
  "stream": "transfers",
  "data": {
    "e":"outboundTransferInfo",                                                // Event type
    "E":12893,                                                                 // Event height
    "H":"0434786487A1F4AE35D49FAE3C6F012A2AAF8DD59EC860DC7E77123B761DD91B",    // Transaction hash
    "M": "MEMO"                                                                // Memo
    "f":"bnb1z220ps26qlwfgz5dew9hdxe8m5malre3qy6zr9",                          // From addr
    "t":
      [{
        "o":"bnb1xngdalruw8g23eqvpx9klmtttwvnlk2x4lfccu",                      // To addr
        "c":[{                                                                 // Coins
          "a":"BNB",                                                           // Asset
          "A":"100.00000000"                                                   // Amount
          }]
      }]
  }
}
```

## 6. License

The content is licensed under [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
