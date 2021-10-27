# BEP-96: Private Transaction Support on BSC

## 1. Summary

This BEP proposes a new RPC endpoint that allows nodes to accept and validate transactions privately. Private transactions are still handled by the validator in the same way as regular public transactions but are not being forwarded to other peers.


## 2. Abstract

Currently, all BSC transactions are being propagated publicly via the P2P network, which allows adversarial trading bots to examine pending transactions before they land on-chain. This BEP describes a solution which enables validators to receive transactions privately without broadcasting them to the public network.

## 3. Status

The [proposed implementation] is ready. 

## 4. Motivation

Nowadays, with the popularity of Decentralized Finance (DeFi), Decentralized Exchanges like PancakeSwap and 1inch Exchange account for 20% of the transactions in BSC, and such token swap transactions are usually subject to frontrunning and sandwich attacks. As a result, ordinary traders may often experience a less desired high slippage and lose potential profit. The implementation of private transaction is crucial to attract institutional and retail traders to the BSC ecosystem.


## 5. Specification

`eth_sendPrivateRawTransaction` RPC endpoint:
Similar to the existing `eth_sendRawTransaction` endpoint, this new endpoint adds the signed transaction to the transaction pool, while the transaction would not be broadcasted to BSC node's peers


## 6. License

All the content is licensed under [CC0].



[proposed implementation]: https://github.com/bloXroute-Labs/bsc/pull/1
[CC0]: https://creativecommons.org/publicdomain/zero/1.0/
