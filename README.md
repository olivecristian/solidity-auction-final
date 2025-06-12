# 🧾 Solidity Final Project – AuctionTP.sol

> Final project for Module 2 – Solidity Course  
> Author: Cristian Olivé – June 2025

---

## 📍 Verified Contract on Sepolia

**Contract Address:**  
[0x41c5652233f38dd63e53d1681b8680fb1ecd2a77](https://sepolia.etherscan.io/address/0x41c5652233f38dd63e53d1681b8680fb1ecd2a77#code)

---

## ⚙️ Description

This smart contract implements an auction mechanism that:

- Accepts bids for a limited time (7 days).
- Requires each new bid to be at least **5% higher** than the current highest bid.
- Extends the auction by **10 minutes** if a valid bid is placed in the last 10 minutes.
- Allows partial refunds for users who bid multiple times.
- Returns deposits to all non-winning bidders (98%) when finalized.
- Applies a **2% commission** that goes to the contract owner.

---

## 🛠️ Constructor

```solidity
constructor() {
    owner = msg.sender;
    endDate = block.timestamp + 7 days;
}
```

Initializes the auction with the deployer's address and sets the duration.

---

## 🧠 Functions

### `bid()` external payable

Places a bid. It must be higher than 0 and at least 5% above the last bid.  
If placed in the last 10 minutes, the auction is extended by 10 more minutes.

### `showWinner()` external view returns (address)

Returns the current highest bidder.

### `showBids()` external view returns (Bid[] memory)

Returns the list of all bids.

### `partialRefund()` external

Allows users to withdraw the amount of their previous bids except the last one.

### `retDeposit()` external onlyOwner

Can only be called by the owner after the auction ends.  
Distributes 98% of deposits to non-winning bidders and keeps 2% commission.

### `emergencyWithdraw()` external onlyOwner

Allows the owner to withdraw the entire contract balance in case of emergency.

---

## 📦 Variables

- `owner`: Address of the contract owner.
- `endDate`: Timestamp when the auction ends.
- `initialValue`: Starting price (1 ether).
- `ended`: Whether the auction has been finalized.
- `bids`: Array of all bids.
- `myBids`: Mapping of user addresses to their last and total bids.

---

## 📢 Events

- `NewOffer(address bidder, uint256 amount)`  
Emitted when a valid bid is placed.

- `AuctionEnded(address winner, uint256 amount)`  
Emitted when the auction ends successfully.

- `PartialRefund(address bidder, uint256 amount)`  
Emitted when a participant withdraws old bids.

- `EmergencyWithdraw(address to, uint256 amount)`  
Emitted when the owner withdraws all contract funds.

---

## ✅ Notes

- The contract is written in Solidity ^0.8.20.
- Verified and deployed on the Sepolia testnet.
- Includes security checks, modifiers, and full event logging.
