# BEP23: Continuous WalletConnect

- [BEP-23: Continuous WalletConnect](#bep-23--continuous-walletconnect)
  * [1. Summary](#1-summary)
  * [2. Abstract](#2-abstract)
  * [3. Status](#3-status)
  * [4. Motivation](#4-motivation)
  * [5. Specification](#5-specification)
    + [5.1 Continuous Signing Wallet](#51-continuous-signing-wallet)
    + [5.2 Secure Auto Sign in the Mobile Wallets](#52-secure-auto-sign-in-the-mobile-wallets)
    + [5.3 Web Wallet Continuous Connection](#53-web-wallet-continuous-connection)
  * [6. License](#6-license)

## 1. Summary

This BEP proposes revised function specs of [WalletConnect](#https://docs.walletconnect.org/tech-spec) Wallets and DApp sides to improve user experience on trading via Wallet Connect.

## 2. Abstract

Revised Wallet Connect communication steps are proposed. After users’ consent, Mobile or other Wallet can continuously sign requested transactions from Web Wallet without promoting to user for confirmation, as long as the transactions satisfy the predefined and agreed conditions.

## 3. Status

DRAFT

## 4. Motivation

Wallet Connect is a great protocol to ease the use of DApp and make Web Wallet much safer. However, it is not designed for trading and brings a few inconveniences for traders:
The connection is a short term of the transient. Once the mobile phone app switches to the background, e.g. disturbed by a phone or screen timeout, the connection will be cut off. The users “unlocked” wallet would be locked again and cannot perform any actions.
Even the connection is there, every order or cancel will require traders to unlock the mobile phone (after inputting password or touch/face ID), and click the button, which is quite time-consuming in a fast ticking market.

Here a longer, continuous-time period is required as a “secure slot” for traders to send, and cancel orders freely and safely.

## 5. Specification

### 5.1 Continuous Signing Wallet
Upon scanning the QR code, or after getting the first transaction to confirm, the mobile Wallet can ask for the below optional input parameters. After the wallet may directly sign the requested transactions without asking users to review and confirm the trade. 
Please note: Only NewOrder and Cancel transaction types are allowed. Transfer and other transaction types are not allowed at all.

| Name | Type | Content | 
|------|------|---------|
| Timeout Window | int64 | time in minutes. It stands for these minutes, mobile Wallet will not ask for confirmation but directly sign the requested transactions.|
If yes, the “Timeout Window” will be renewed after the last user transaction. |
| Allowed Symbols | string | A string of different asset symbols, separated by “,” (comma). Only the trading pairs that have base asset contained by this string can be traded. |
| Allowed Order Size | int64 | Only the orders that have a smaller quantity than this number are directly signed. |
| Allowed Total Quantity | int64 | The total quantity of the orders should be no larger than the value defined here |
| Allowed Number of Orders | int64 | Total number of order is allowed |
| Cancel Is Relaxed | bool | If yes, the “Allowed Symbols” and “Allowed Order Size” and “Allowed Total Quantity” and “Allowed Number of Orders” are NOT applicable to limit the Cancel action, i.e. all the cancels can be signed within the “Timeout Window”. |

After users agree on the above parameters or default, the mobile Wallet will keep a non-disconnect connection with the Bridge server, even when the application is switched to the background. Once there is an incoming request to sign a transaction, the below logic is executed:
```
1. Is it still within any “Timeout Window”? If yes, go to step 2; otherwise prompt for user consent;
2. Is it a NewOrder or Cancel transaction, if yes, go to step 3 or 4; otherwise prompt for user consent;
3. If it is NewOrder, if the base asset of the trading pair is one of “Allowed Symbols” and order quantity is less than or equal to “Allowed Order Size” and total order quantity is smaller than “Allowed Total Quantity” and the number of orders should be smaller than “Allowed Number of Orders”, sign the transaction and refresh the time window if “Refreshable” is true; otherwise, prompt for user consent;
4. If it is NewOrder, if the base asset of the trading pair is one of “Allowed Symbols” and order quantity is less than or equal to “Allowed Order Size” and total order quantity is smaller than “Allowed Total Quantity” and the number of orders should be smaller than “Allowed Number of Orders”, or “CancelIsRelaxed” is true, sign the transaction and refresh the time window if “Refreshable” is true; otherwise, prompt for user consent;
```

### 5.2 Secure Auto Sign in the Mobile Wallets

As in the above proposal, many transactions may be signed automatically without prompting users for confirmation. As the DApp (Web Wallet) and Bridge Server are not 100% safe, here 2 additional verifications are proposed. Mobile Wallets should implement one or both of them.

#### 5.2.1 Mandatory First Transaction Sign for Each Trading Pair

This is best-effort enforcement to prevent malware in the browsers or comprised devices from forging transactions to cheat the mobile wallets to sign. So even though the users have provided consent, mobile wallets still ask for confirmation for the first NewOrder or Cancel on each Trading Pair.

#### 5.2.2 Voice Notification

In order to not to blindly and silently sign the transactions, users can enable mobile wallets to always automatically play a voice sound upon each transaction signed. Simple voice notification of “NewOrder signed” and “Cancel signed” is useful enough to remind users for forged transactions. Even though this is a post-event notification,  together with the user settings on orders size/number and trading pair, the security level is covered in majority cases.

### 5.3 Web Wallet Continuous Connection
Even the mobile wallets can keep the connection with Bridge Server, it also requires the DApp side (Web Wallet) can manage to connect with Bridge Server on the same topic. As users may often refresh the pages to resolve trading API issues or trading page instability. After each time the page is refreshed, the DApp should:
look up the topic in the localsession storage, and connect to the Bridge Server with the same topic
after the re-connection is established, confirm with Bridge Server whether mobile wallet is still connected. If the mobile wallet is not connected any more (through several times of check, to ensure the disconnection is there), DApp may stop connecting and ask for user to re-establish the whole process. This is to prevent mobile wallet connection is lost, and this is a new part of communication not included in the official Wallet Connect protocol. 

## 6. License
The content is licensed under [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

