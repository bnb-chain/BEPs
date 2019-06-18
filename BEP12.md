# BEP12: Introduce customized validation scripts and transfer memo validation
## Summary
This BEP describes a new feature that enables users to customize validation scripts, and introduces the first validation script for transaction memo.
## Abstract
In some circumstance, users may want to specify some additional validations on some transactions. 

Taking exchange for example, for Bitcoin and Ethereum, exchanges create unique addresses for each clients. It costs them too much effort to manage secret files and collect tokens to cold wallet. So now, for new blockchain platform, exchanges tend to use a single address for client deposit and require clients to input memo to identify client account information. 

However, this user experience change causes a lot of problems for both exchange customer support and clients. Clients may be panic if their tokens are missing and exchange supports have to verify the client deposit transactions manually. 

For all transfer transactions which are intend to deposit tokens to enchanges, it would be nice if binance chain can reject these who have no valid memo. Thus clients won’t be panic for losing tokens and exchanges supports won’t suffer from heavy working load.
## Status
This BEP is WIP.
## Motivation
Currently, only exchanges can benefit from this BEP. However, this BEP proposes an important infrastructure for customized validation functions. In the future, more amazing features will be built on it. 
## Specificaion
### Add Verification Flags into AppAccount
```
type AppAccount struct {
  auth.BaseAccount    `json:"base"`
  Name                string          `json:"name"`
  FrozenCoins         sdk.Coins       `json:"frozen"`
  LockedCoins         sdk.Coins       `json:"locked"`
  Flags               uint64          `json:”flags”`
}
```
We will add new field named “flags” into “AppAccount”. Its data type is 64bit unsigned int. The highest bit represents if there are validation functions are associated with this account. The rest of each bit will represent a validation function, which means an account can specify at most 63 validation functions. By default, all accounts’ flags are zero. Users can send transactions to update their account flags.
### New Transaction to Update Account Flags
Parameters for Updating Account Flags

|       | Type           | Description | 
|-------|----------------|-------------|
| From  | sdk.AccAddress | Address of target account |
| Flags | uint64         | New account flags | 

For a valid value of flags, it should satisfy the following two requirements: 

- The highest bit can’t be binded to any validation function, it should indicate if lower bits are all zero:
(flags & 0x8000 0000 0000 0000 == 0) == (flags & 0x7FFF FFFF FFFF FFFF == 0)
- If a bit has no binded validation function, its value must be 0.

Users are free to set their account flags to any valid values. The account flags changes will take effect since the next height. 
 
### Memo validation
“AnteHandler” is the entrance of customized validation functions. To minimize the impact to performance, the following methods will be taken:

- Only in check mode, the validation functions can be called. 
- To reduce the cost of function call, account flags will be checked before calling validation functions.

### Validations Entrance
Firstly, this validation will check if the following conditions can be met:

- The transaction type is send.
- The address is the receiving address.

Then the validation function will ensure that the transaction memo is not empty and the memo only contains digital character. This is the pseudocode:

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

### Impact to Upgrade
For initial version, we just need to make a decision on which height binance chain will support the new transaction to update account flags.

In the future, more validation functions will be supported and existing validation functions might need to update, which means we must take scalability into consideration. 

Steps to add a new validation function:

- Implement a new validation functions and call it from entrance
- Update account flags validation to allow corresponding bits to be 1 since specified height. 

Steps to update an existing validation function:

- Add updated validation code.
- Specify since which height the new code will take effect.

## License
All the content is licensed under [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
