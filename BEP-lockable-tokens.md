# BEP180: Permisison-based lock for the BEP20 tokens

- [BEP-180: Permisison-based locking extension for the BEP20 Tokens on Binance Smart Chain](#bep180-tokens-locking-extension)
  - [1. Summary](#1--summary)
  - [2. Abstract](#2--abstract)
  - [3. Motivation](#3--motivation)
  - [4. Status](#4--status)
  - [5. Specification](#5--specification)
    - [5.1 Token](#51-token)
      - [5.1.1 Methods](#511-methods)
        - [5.1.1.1 lockedOf](#5111-lockedOf)
        - [5.1.1.2 lockedFor](#5112-lockedFor)
        - [5.1.1.3 lock](#5113-lock)
        - [5.1.1.4 unlock](#5114-unlock)
        - [5.1.1.5 unlockedOf](#5115-unlockedOf)
        - [5.1.1.6 lockFor](#5116-lockFor)
        - [5.1.1.7 unlockFrom](#5117-unlockFrom)
        - [5.1.1.8 approveLock](#5118-approveLock)
        - [5.1.1.9 approveUnlock](#5119-approveUnlock)
        - [5.1.1.10 lockedAllowance](#51110-lockedAllowance)
        - [5.1.1.11 unlockedAllowance](#51111-unlockedAllowance)
        - [5.1.1.12 collect](#51112-collect)
      - [5.1.2 Events](#512-events)
        - [5.1.2.1 Lock](#5121-lock)
        - [5.1.2.2 Unlock](#5121-unlock)
        - [5.1.2.3 LockApproval](#5123-lockApproval)
        - [5.1.2.3 Collate](#5124-collate)
    - [5.2 Implementation](#52-implementation)
  - [6. License](#6-license)

## 1.  Summary
This BEP proposes an interface standard to create lockable tokens on Binance Smart Chain.

## 2.  Abstract
The following standard defines the implementation of the locking API for token smart contracts. It provides the basic functionality to protect tokens from the transfer under specific conditions.

## 3.  Motivation
A standard BEP20 contracts have no ability to be locked from the transfer to third party. In the case of borrowing tokens, the only way is to transfer the tokens to another person and wait for them to be returned. To solve this problem, it is proposed to creatge a standard for locking the transfer of tokens.

## 4.  Status
This BEP is under draft.

## 5.  Specification

### 5.1 Token

**NOTES**:
- The following specifications use syntax from Solidity **0.8.17** (or above)

####  5.1.1 Methods

##### 5.1.1.1 lockedOf
```
function lockedOf(address owner_) public view returns (uint256 balance)
```
- Returns the amount of the all locked tokens for the address.

##### 5.1.1.2 lockedFor
```
function lockedFor(address owner_, address locker_) public view returns (uint256 balance)
```
- Returns the amount of the tokens, owned by the one address and locked by the second one.

##### 5.1.1.3 lock
```
function lock(addres owner_, uint256 amount_) public view returns (bool success)
```
- Lock the choosen amount of the tokens in favor of the caller.

##### 5.1.1.4 unlock
```
function unlock(addres owner_, uint256 amount_) public view returns (bool success)
```
- Unlock the choosen amount of the tokens, locked previously by caller.

##### 5.1.1.5 unlockedOf
```
function unlockedOf(address owner_) public view returns (uint256 balance)
```
- Returns the amount of the tokens for the address, available for lock.

##### 5.1.1.6 lockFor
```
function lockFor(addres locker_, uint256 amount_) public view returns (bool success)
```
- Lock the choosen amount of the tokens owned by the caller in favor of the desired address.

##### 5.1.1.7 unlockFrom
```
function unlockFrom(address locker_, uint256 amount_) public returns (bool success)
```
- Unlock the choosen amount of the tokens owned by the caller which are locked by the selected address.

##### 5.1.1.8 approveLock
```
function approveLock(address locker_, uint256 value_) public returns (bool success)
```
- Allows `locker_` to lock the amount of the tokens multiple times, up to the `value_` amount. If this function is called again it overwrites the current allowance with `value_`.
- **NOTE** - To prevent attack vectors like the one described here and discussed here, clients SHOULD make sure to create user interfaces in such a way that they set the allowance first to 0 before setting it to another value for the same spender. THOUGH The contract itself shouldn’t enforce it, to allow backwards compatibility with contracts deployed before

##### 5.1.1.9 approveUnlock
```
function approveUnlock(address owner_, uint256 value_) public returns (bool success)
```
- Allows `owner_` to unlock it's tokens, locked by you, multiple times, up to the `value_` amount. If this function is called again it overwrites the current allowance with `value_`.
- **NOTE** - To prevent attack vectors like the one described here and discussed here, clients SHOULD make sure to create user interfaces in such a way that they set the allowance first to 0 before setting it to another value for the same spender. THOUGH The contract itself shouldn’t enforce it, to allow backwards compatibility with contracts deployed before

##### 5.1.1.10 lockedAllowance
```
function lockedAllowance(address owner_, address locker_) public view returns (uint256 remaining)
```
- Returns the amount which `owner_` is still allowed to unlock from `locker_`.

##### 5.1.1.11 unlockedAllowance
```
function unlockedAllowance(address owner_, address locker_) public view returns (uint256 remaining)
```
- Returns the amount which `locker_` is still allowed to lock from `owner_`.

##### 5.1.1.12 collect
```
function collect(address owner_, address locker_, uint256 amount_) public view (bool success)
```
- Collect, i.e. transfer tokens from the `owner_` account to the `locker_` in case of decline of repay

#### 5.1.2 Events

##### 5.1.2.1 Lock
```
event Lock(address indexed from_, address indexed to_, uint256 _value)
```
- **MUST** trigger when tokens are locked, including zero value locks.

##### 5.1.2.1 Unlock
```
event Unlock(address indexed from_, address indexed to_, uint256 _value)
```
- **MUST** trigger when tokens are unlocked, including zero value unlocks.

##### 5.1.2.3 LockApproval
```
event LockApproval(address indexed owner_, address indexed locker_, uint256 _value)
```
**MUST** trigger on any successful approving call.

##### 5.1.2.4 Collate
```
event Collate(address indexed owner_, address indexed locker_, uint256 _value);
```
**MUST** trigger on any successful collate call.
Trigger on any collate of funds

### 5.2 Implementation

There are no implementation ready yet

## 6. License
   
The content is licensed under [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
