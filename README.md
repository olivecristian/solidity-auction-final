Solidity Final Project – AuctionTP.sol

Final project for Module 2 – Solidity Course
Author: Cristian Olivé – June 2025
Contract deployed on Sepolia
Contract address:
https://sepolia.etherscan.io/address/0x1401c25ccE343932d92e752bA5eF9E2D52153ff8#code
Description
This smart contract implements an auction mechanism with the following features:
- Accepts bids for a limited period (45 minutes).
- Requires each new bid to exceed the current highest bid by at least 5%.
- If a valid bid is placed during the last 10 minutes, the auction is extended by 10 more minutes.
- Allows non-winning participants to withdraw their deposits after the auction ends.
- Applies a 2% commission on the winning amount, which is transferred to the contract creator.
Constructor
The constructor initializes the contract with the creator's address and sets the auction duration to 45 minutes.
constructor() {
    owner = msg.sender;
    startTime = block.timestamp;
    stopTime = startTime + 45 minutes;
}
Contract Functions
bid()
Allows users to place a bid. The bid must be greater than zero and at least 5% higher than the current highest bid. If placed within the last 10 minutes, the auction is extended.
showWiner()
Returns the current highest bidder and their bid amount.
showOffers()
Returns a list of all bids placed during the auction.
refund()
Allows non-winning users to withdraw their funds after the auction ends.
partialRefund()
Allows participants to withdraw their previous bids (except the most recent one) while the auction is still active.
finalizeAuction()
Can only be executed by the owner. Finalizes the auction and transfers the winning amount minus the 2% commission to the owner.
Variables
owner: address of the contract creator.
startTime: timestamp marking the beginning of the auction.
stopTime: timestamp marking the end of the auction.
commission: fixed commission percentage (2%).
winner: structure containing the best bid and the leading bidder.
biders[]: array containing all placed bids.
deposits: mapping associating each address with its total deposited ETH.
biddingHistory: mapping that records the bid history per address.
ended: boolean indicating whether the auction has been finalized.
Events
NewOffer(address bider, uint256 amount): Emitted when a new valid bid is placed.
AuctionEnded(address winner, uint256 amount): Emitted when the auction is successfully finalized.
Repository Files
AuctionTP.sol: source code of the smart contract.
README.md: this documentation file.
Notes
- The contract was developed using Solidity version 0.8.0 or higher.
- It is deployed and verified on the Sepolia test network.
