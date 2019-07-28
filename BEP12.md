# BEP12: Introduce Customized Scripts and Transfer Memo Validation
## Summary
This BEP describes a new feature that enables addresses to customize scripts, and introduces the a validation script for transfer transaction memo.
## Abstract
In some circumstances, users may want to specify some additional functions or/and validations on some transactions.

Taking exchange for example, for Bitcoin and Ethereum, exchanges create unique addresses for each client. It costs them too much effort to manage secret files and collect tokens to cold wallet. So now, for new blockchain platforms, exchanges tend to use a single address for client deposit and require clients to input memo (or call it “tag”) to identify client account information.

However, this user experience change causes a lot of problems for both exchange customer support and clients. Clients may be panic if they forget to input the correct memo and exchange cannot allocate the fund to their account. The exchange support have to verify the client deposit in other ways.

For all transfer transactions which are depositing tokens to exchanges, it would be nice if Binance Chain can reject those that have no valid memo. Thus clients won’t be panic for losing tokens and exchanges supports won’t suffer from the heavy working load.

Here a script model is introduced into Binance Chain. And each address can add new functions by associate itself with one or more predefined scripts. The memo validation is one first type of the scripts to introduce here.

## Status
This BEP is under implementation.
## Motivation
This memo validation can be used for any membership based deposit/charge business model.

This BEP also proposes an important infrastructure for customized scripts. In the future, more amazing features will be built on it.
## Specificaion
### Add Flags into Address Structure
```
type Account struct {
  auth.BaseAccount                 `json:"base"`
  Name                 string      `json:"name"`
  FrozenCoins          sdk.Coins   `json:"frozen"`
  LockedCoins          sdk.Coins   `json:"locked"`
  Flags                uint64      `json:”flags”`
}
```
Each address represents an account. The account structure is shown as above. We will add a new field named “flags” into “Account”. Its data type is 64bit unsigned int. Each bit will represent a script, which means an account can specify at most 64 scripts. The flags of all existing accounts are zero. Users can send transactions to update their account flags.
### New Transaction: SetAccountFlags
Parameters for Updating Account Flags

|       | Type           | Description |
|-------|----------------|-------------|
| From  | sdk.AccAddress | Address of target account |
| Flags | uint64         | New account flags |

With this transaction, users can set their account flags to any values. But setting a bit which has no bonded script will not have any effect, unless a new script is bonded to it in the future.

By default, all accounts’ flags are zero which means no script is specified. Suppose there are two available scripts(marked as A and B), and the lowest bit is bonded to script A and the second lowest bit is bonded to script B. If an address set its account flags to 0x03, then two scripts are enabled. If only script B is expected, then account flags should be set to 0x02.

Besides, the account flags changes will take effect since the next transaction.

### 0x1: Memo Check Script for Transfer
This script is aimed to ensure the transfer transactions have valid memo if the receivers require this.

Firstly, this script will check the following conditions:

- The transaction type is send.
- The target address is the receiving address.

Then this script will ensure that the transaction memo is not empty and the memo only contains digital letters. This is the pseudocode:

```
func memoValiation(addr, tx) error {
if tx.Type != “send” {
    return nil
}
if ! isReceiver(tx, addr) {
   return nil
}
if  tx.memo.length == 0 {
    return err(“tx memo is empty”)
}
if !isAllDigital(tx.memo) {
    return err(“tx memo contains non digital character”)
}
return nil
}
```

### 0x2: Whitelisted Sender
This script is used to ensure transfer transactions have valid recipients.
The script will reject transfers to addresses that are not currently whitelisted.

Firstly, this script will check the following conditions:

- The transaction type is send.
- The from address has flag 0x2

Pseudocode:
```
func whitelistValidation(addr, tx) error {
    if tx.Type != "send" {
        return nil
    }
    if ! isSender(tx, addr) {
        return nil
    }
    if ! isRecipientWhitelisted(addr, tx) {
        return err("recipient not whitelisted")
    }
    return nil
}
```


#### New Transaction: WhitelistRecipient
Parameters for adding a whitelisted recipient

|       | Type           | Description |
|-------|----------------|-------------|
| From  | sdk.AccAddress | Sender Address        |
| To    | sdk.AccAddress | Whitelisted Recipient |


#### New Transaction: UnwhitelistRecipient
Parameters for removing a whitelisted recipient

|       | Type           | Description |
|-------|----------------|-------------|
| From  | sdk.AccAddress | Sender Address        |
| To    | sdk.AccAddress | Whitelisted Recipient |

### Scalability
In the future, more scripts will be supported and existing scripts might need to be updated, so we must take scalability into consideration in the implementation.

## License
All the content is licensed under [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
