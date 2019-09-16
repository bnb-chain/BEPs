# BEP48: Changes to default cancellation and partial fill

## Summary

This BEP proposes changes to the fee structure for cancellation and to the default order expiration.

## Abstract

This overhauls the fee structure for cancellation to solve a few economic issues.
First, it charges a fee proportional to how long the order was alive before fill or cancellation, replacing the fixed cancellation fee.
Second, it allows fees to be charged for orders fulfilled and partially filled if the trading fee was smaller than the due cancellation fee.

## Status

This BEP is a draft.

## Motivation

There should never be any incentive for a project to fake volume.
However, it is currently possible to circumvent cancellation fees by partially filling your own orders.
Because there is no fee for cancelling a partially filled order, by placing an order of lot size, it is profitable to fake volume before relocating your order.
By charging the difference between the cancellation fee and the filled fee

Currently, orders automatically expire after 3 days.
Often these are orders in the extreme of the order book designed to service foolish market orders.
While automatic expiration disincentivizes these orders from cluttering the state, there seems to be room to increase this duration.
The wasted application space caused by long-term no-fill orders is directly proportional to the duration before expiration.
There is also a small fixed cost for validating and documenting the order in the first place.
By charging a larger cancellation fee the longer the cancelled order was alive, the network can allow market makers to provide narrower spreads and casual traders to place orders with longer durations.

To allow onboarding from exchanges or applications that do not provide users with BNB, the fee structure should generally allow payments in tokens besides BNB.
This is possible because all tokens tradeable on the DEX require a pair with BNB.
Such a fee preference should be standardized between the transactions that accept fees in alternative currencies.

## Specification

### Terms
* The **maker** is the placer of an order that is being cancelled
* The **taker** is a trader who fully or partially fills an order placed by a **maker**
* Some fees are **preferrentially payable in BNB**, meaning that they are paid in BNB if possible, or otherwise in a greater value-amount of another token paired with BNB.

### Parameters
* **NewOrderFee** - The fee for placing a new order

Suggested: 0.00000020 BNB

* **MaxCancellationFee** - The fee paid when an order expires with no fill

Suggested: 0.00002000 BNB minus **NewOrderFee**

* **TradingFee** - The fee paid when completing a trade, as a proportion of the BNB-value of its filled volume.
Multiplying the TradingFee with an order's size determines the order's **MaxTradingFee**.

Suggested: 0.02% preferrentially payable in BNB

* **BNBPreference** - The proportion for fees preferrentially payable in BNB when paid in BNB compared to other tokens.

Suggested: 50%

* **MaxOrderExpiration** - The maximum amount of time that an order will stay open before automatically cancelled.

Suggested: 7 days

### NewOrder
The fee for placing a New Order is changed from a deceptively zero fee to include an initial order fee, **NewOrderFee**, preferrentially payable in BNB.
Additionally, if the **MaxCancellationFee** is greater than the **MaxTradingFee**, the account must also lock the difference, preferrentially payable in BNB.
This locked fee is freed when the order is cancelled and consumed to pay for cancellation in the event the order is cancelled.
This allows the **TradingFee** parameter to be arbitrarily low in relation to the **MaxCancellationFee**, and prevents microtrades from cluttering.

### FillOrder
Any order fulfillment results in **TradingFee** paid both by the **maker** and the **taker**.

### CloseOrder and CancelOrder
A fulfilled or cancelled order pays an additional fee that is the difference between the due cancellation fee and the total **TradingFee** paid by the order.
If the difference is zero or negative, no additional fee is due.

The due cancellation fee is the **MaxCancellationFee** multiplied by the duration the order was open and divided by the **MaxOrderExpiration** 
Therefore if the order automatically expired by being open for the **MaxOrderExpiration**, it would pay the full **MaxCancellationFee**.

## License

The content is licensed under [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
