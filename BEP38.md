# BEP-38: Non-interactive Multi-Signature Wallet

- BEP-38: Non-interactive Multi-Signature Wallet
  - [1. Summary](#1-summary)
  - [2. Abstract](#2-abstract)
  - [3. Status](#3-status)
  - [4. Motivation](#4-motivation)
  - [5. Specification](#5-specification)
    - [5.1 CLI](#51-cli)
    - [5.2 API](#52-api)
  - [6. Developer Notes](#6-developer-notes)
     - [6.1 Setup](#61-Setup)
     - [6.2 Configuration](#62-configuration) 
     - [6.3 Start](#63-start) 
  - [7. License](#6-license)
  
## 1.  Summary 

This BEP describes a new feature that builds on the [multi-signature module](https://hub.cosmos.network/docs/gaiacli.html#multisig-transactions) that is part of the Cosmos Gaia mainnet. 
The essence of this feature is that there is no interactivity required in the use of the multi-signature, and is closer in function to the [Etheruem Gnosis Multi-signature](https://github.com/gnosis/MultiSigWallet). 

## 2.  Abstract

While mult-sig transfer of coins utilizes the built-in multisig features of
Cosmos, this implementation expands that to create an infrastructure that allows non-interactive multisig transactions.

The complete workflow of a multisig transaction as follows:
 1. Create a multisig wallet, specifying the name, minimum number of
    signatures for a transaction to take place, and the pub keys associated with the wallet.
 2. Transfer funds to this wallet.
 3. Create a transaction request to send funds from the multisig wallet to
    another address.
 4. Multiple owners of the multisig wallet sign the transaction.
 5. Once enough signatures have been made, send the funds.
 6. Update the transaction request with the `txhash` of the transfer of funds.
 
 ## 3.  Status

This BEP is under specification.

## 4.  Motivation

Currently to sign a multi-sig transaction, multiple parties must come together and interact to both create the multi-signature and spend funds from it. 
The output of the interaction with the multi-sig account returns a json file that must be signed locally and shared around (by email, pgp chat or other methods).

The non-interactive version of this described in this BEP instead uses Blockchain key-value store to store a basic amount of state that outlines the multi-signature account. 
The result of this is that parties do not need to cooperate or interact and instead can sign the wallet independently and at different times. 
Additionally state-less wallet interfaces can be built that connect to Binance Chain with nothing but a connected wallet. 

This is a substantially better user experience, as shown in this demo video:

[DEMO VIDEO](https://www.dropbox.com/s/s0c6mcor8l5c0ym/Multisig.m4v?dl=0)

[SOURCE CODE](https://github.com/cbarraford/cosmos-multisig)

Screenshots:

Create new multi-signature account:
![](https://snag.gy/SwGfkb.jpg)

View multi-sig accounts:
![](https://snag.gy/ltJBTF.jpg)

Make a transaction:
![](https://snag.gy/O14XIu.jpg)

View Transactions:
![](https://snag.gy/K8HqoR.jpg)


> Note: It is suggested that Binance charge fees to users to user non-interactive multi-signature features since Binance Chain must store state. 
This fees will increase the utility of the BNB token. 

## 5.  Specification

###  5.1 CLI
The cli tool has a series of queries and transaction that you can use. In
theory, you could interact with this blockchain fully using the cli, but REST
was the intended purpose.

#### 5.1.1 Create a wallet
This command is used to create a multisig wallet. Pubkeys should be comma
separated (no spaces).
```
msgicli tx multisig create-wallet [name] [min-signatures-required] [pub-keys], [addresses] [flags]
```

#### 5.1.2 Get a wallet
Get wallet info by wallet address
```
msgicli query multisig get-wallet [address] [flags]
```

#### 5.1.3 Query wallets
Search for a list of wallets by public key
```
msgicli query multisig query-wallets [pub_key] [flags]
```

#### 5.1.4 Create a transaction
This command creates a transaction request to move funds out of a multisig
wallet.
```
msgicli tx multisig create-transaction [from] [to] [coins] [signers] [flags]
```

#### 5.1.5 Get transaction
Retrieve transaction request information by uuid
```
msgicli query multisig get-transaction [uuid] [flags]
```

#### 5.1.6 Query transactions
Get a list of transaction requests by wallet address.
```
msgicli query multisig query-transactions [wallet_address] [flags]
```

#### 5.1.7 Add signature to transaction
This command adds a signature to a transaction request.
TODO: remove need to supply `pubkey_base64`. This info is available via the
account info (`/auth/accounts/<address>`). 
```
msgicli tx multisig save-transaction-signature [uuid] [pubkey] [pubkey_base64] [signature] [signers] [flags]
```

#### 5.1.8 Add TxHash to transaction
Once the transaction is completed and funds sent, save the `txhash` in the
transaction request to mark it as completed.
```
msgicli tx multisig complete-transaction [uuid] [transaction_id] [signers] [flags]
```

### 5.2 API
There are corresponding API endpoints for each of the CLI commands above.

#### 5.2.1  `POST /multisig/wallet`
Create a wallet

```
{
    "name": "demo 1",
    "base_req": {"chain_id":"msigchain", "from": "msigXXXXXX"},
    "min_sig_tx": 2,
    "pub_keys": [...],
    "signers": [...]
}
```

#### 5.2.2 `GET /multisig/wallet/<address>`
Get a wallet

#### 5.2.3 `GET /multisig/wallets/<pubkey>`
List wallets that contain specified public key

#### 5.2.4 `POST /multisig/transaction`
Create a transaction request

```
{
    "base_req": {"chain_id":"msigchain", "from": "msigXXXXXX"},
    "from": "msigXXXX",
    "to": "msigXXXX",
    "amount": 3,
    "denom": "msigtoken",
    "signers": [...]
}
```

#### 5.2.5 `GET /multisig/transaction/<uuid>`
Get a transaction request by uuid

#### 5.2.6 `GET /multisig/transactions/<address>`
List transaction by wallet address

#### 5.2.7 `POST /multisig/transaction/sign`
Add signature for a transaction request

```
{
    "base_req": {"chain_id":"msigchain", "from": "msigXXXXXX"},
    "uuid": "02206ab8-ef05-4ecc-8e81-4430405e929a",
    "signature": "1KRP93NJ85SxygGucoS7MqV39INDG/TYZzRP9NVzS4k/J7zn5kus1r3SoIXkyHgYEZmnaIyr26liL7uez45Uiw",
    "pub_key": "msigp1addwnpepq0wx75hs3jpepjlvvee4r8gmuuxnmjzk6k5jkjps7n9rr3y4v0quqqy456c",
    "pub_key_base64": "A/HRtDdV5mtPOMFhDDRRqb0s60q8rVJ+3AqSWd3PkOWx",
    "signers": [...]
}
```

#### 5.2.8 `POST /multisig/sign/multi`
With given signatures, generate a multi-signature. 
"Signatures" must be a list of tx signatures for pub keys of the wallet. Order
is important here, and must align with the pub key order of the wallet.
"Slots" is a string of zeros and ones representing which pubkeys of the wallet
are included in the list of signatures, and which are not. Zeros are not
include, ones are included.
The resulting json response will include the multisig signature.

```
{
    "Signatures": [...],
    "Slots": "011",
}
```

#### 5.2.9 `POST /multisig/transaction/complete`
Complete a transaction supplying the `txhash` of the transfer of funds.

```
{
    "base_req": {"chain_id":"msigchain", "from": "msigXXXXXX"},
    "uuid": "02206ab8-ef05-4ecc-8e81-4430405e929a",
    "TxID": "939HDJ300...",
    "signers": [...],
}
```

#### 5.2.10 `POST /multisig/broadcast`
Broadcast a message (same as to `/txs` in the cosmos SDK).

# 6 Developer Notes

## 6.1 Types

### 6.1.1 `MultiSigWallet`
`MultiSigWallet` is a type to store multisignature wallet information. This
type includes...
 * `Name` - the custom name of the wallet. This makes it easier for users to
   identify each wallet and its purpose.
 * `MinSigTx` - the minimum number of regular user signatures required before
   a transaction can be sent.
 * `Address` - The receiving address to send coins into this wallet.
 * `PubKeys` - A list of public keys associated with this wallet that has the
   ability to sign transactions. Order of public keys is important.

** Notes ** Wallets cannot be deleted, nor can they be overwritten or change
once created.

### 6.1.2 `Transaction`
`Transaction` is a type to store a transaction request information to move
funds out of a multisig wallet. 
 * `UUID` - a unique identifier (follow uuid standards) 
 * `From` - an multisig wallet address to send the funds from
 * `To` - a wallet address to send the funds to
 * `Coins` - an array of coins to be sent from the multisig wallet. Currently
   only one coins (one denom) can be sent at this time.
 * `Signatures` - the signed signatures of this transaction from the public
   keys associated with the multisig wallet
 * `TxID` - the transaction hash from the blockchain referencing this
   transaction on the blockchain. This is written as a last step to signify
the transaction is complete.
 * `CreatedAt` - The block height when this transaction request was first
   created. This helps the UI sort the transaction list, but also acts a means
to cleanup old transaction requests from history (ie deleting transaction
requests after X blocks have passed).

## 6.2 Setup
Ensure you have a recent version of go (ie `1.121) and enabled go modules
```
export GO111MODULE=on
```
And have `GOBIN` in your `PATH`
```
export GOBIN=$GOPATH/bin
```

### 6.2.1 Install
Install via this `make` command.

```bash
make install
```

Once you've installed `msigcli` and `msigd`, check that they are there.

```bash
msigcli help
msigd help
```

### 6.2.2 Configuration

Next configure your chain.
```bash
# Initialize configuration files and genesis file
# moniker is the name of your node
msigd init <moniker> --chain-id msigchain


# Copy the Address output here and save it for later use
# [optional] add "--ledger" at the end to use a Ledger Nano S
msigcli keys add jack

# Copy the Address output here and save it for later use
msigcli keys add alice

# Add both accounts, with coins to the genesis file
msigd add-genesis-account $(msigcli keys show jack -a) 1000msig,100000000stake
msigd add-genesis-account $(msigcli keys show alice -a) 1000msig,100000000stake

# Configure your CLI to eliminate need for chain-id flag
msigcli config chain-id msigchain
msigcli config output json
msigcli config indent true
msigcli config trust-node true

msigd gentx --name jack
```

## 6.3 Start
There are three services you may want to start.

### 6.3.1 Daemon
This runs the backend
```bash
msigd start
```

### 6.3.2 API Service
Starts an HTTP service to service requests to the backend.
```bash
msigcli rest-server
```

### 6.3.3 CORS Proxy
For making requests in a browser to the API backend, you'll need to start a
proxy in front of the API service to give proper CORS headers. 
For development purposes, a service is provided in `/scripts/cors`

```bash
cd scripts/cors
npm start
```

## 7. License

The content is licensed under [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
