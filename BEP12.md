# BEP12: Implement Memo Validation
## Summary
This BEP describes a new feature that enables users to customize additional memo validation.
## Abstract
For Bitcoin and Ethereum, exchanges create unique addresses for each clients. It costs them too much effort to manage secret files and collect tokens to cold wallet. So now, for new blockchain platform, exchanges tender to use a single address for client deposit and require clients to input memo to identify client account information. 

However, this user experience change causes a lot of problems for both exchange customer support and clients. Clients may be panic when their tokens are missing and exchange supports have to verify the client deposit transactions manually. This is caused by that many users don’t realize that memo is required or they just forget to do that. What’s worse, sometimes their wallets don’t support transaction memo at all.

It would be wonderful if binance chain can filter out these transactions which have no valid memo on binance chain. Thus clients will panic for losing money when they make a mistake in filling memo. 
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
We will add new field named “flags” into “AppAccount”. Its data type is 64bit unsigned int. The highest bit represents if there are valiation functions are associated with this account. The rest of each bit can represent a validation function, which means an account can specify at most 63 validation functions. By default, all accounts’ flags are zero. Users can send transactions to update their account flags.
### New Transaction to Update Account Flags
Parameters for Updating Account Flags

|       | Type           | Description | 
|-------|----------------|-------------|
| From  | sdk.AccAddress | Address of target account |
| Flags | uint64         | New account flags | 

For a valid value of flags, it should satisfiy the following requirements:
 
- The highest bit should indicate if lower bits are all zero

	```
	bool isHighestFlagsBitZero = (flags & 0x8000 0000 0000 0000 == 0)
	bool isLowerFlagsBitsAllZero = (flags & 0x7FFFF FFFF FFFF FFFF == 0)
	isHighestFlagsBitZero == isLowerFlagsBitsAllZero
	```
- If a bit has no binded validation function, its value must not be 1.

Users are free to set their account flags to any valid values. The account flags changes will take effect since the next height.
 
### Memo validation
Firstly, this validation will check if the following conditions can be met:
The transaction type is send.
The address is the receiving address.
Then the validation function will ensure that the transaction memo is not empty and the memo only contains digital character. 
This is the pseudocode:

```
func memoValiation(address, tx) error {
	if tx.Type != “send” {
	    return nil
	}
	if ! isReceiver(tx, account.address) {
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

### Validations Entrance
“AnteHandler” is the entrance of all customized validation functions. To minimize the impact to performance, only when the running mode is check mode and the highest bit of account flags is 1, then the validation functions will be called. To reduce the cost of function call, we will check account flags before calling validation functions. This is the pseudocode:

```
func anteHandler(tx) error {
    …
    if mode == CheckMode {
        err = customizedValiation(tx)
        if err != nil {
            return err
        }
    }
    ...
}
func customizedValiation(tx) error {
    for addr in tx.involvedAddress() {
          account = getAccount(addr)
          if isHighestFlagsBitZero(account.Flags) {
              return nil
          } 
          if (account.Flags & MemoCheck ) { // MemoCheck = 0x01
              err := memoValiation(addr, tx)
              if err != nil {
                 return err
              }
          }
          …
          // Other validation functions
          ....
    }
}

```
### Impact to Upgrade
For initial version, we just need to make a decision on which height binance chain will support setting account flags.

In the future, more validation functions will be supported and existing validation functions might need to update, which means we must take scalability into consideration. 

Steps to add a new validation function:

- Implement new validation functions and call them from **customizedValiation**
- Upgrade account flags validation to allow corresponding bits to be 1 since specified height. 

Steps to update an existing validation functions:

- Add validation function code.
- Specify since which height the logic will take effect.

## License
All the content is licensed under [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
