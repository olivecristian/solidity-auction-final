// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Implements a basic auction where bids must be 5% higher than the previous one.
// Includes full refund for losers with 2% fee, partial refund of old bids, and emergency withdraw.
 
contract Auction {

    // Struct to store each bid: who bid and how much
    struct Bid {
        address bidder;
        uint256 value;
    }

    // Tracks the total and last bid of each participant
    struct MyBids {
        uint256 last;
        uint256 accumulated;
    }

    Bid[] public bids; // All bids made in the auction
    mapping(address => MyBids) public myBids; // Tracks user bids

    address public owner; // Owner of the contract
    uint256 public endDate; // Timestamp when auction ends
    uint256 public initialValue = 1 ether; // Minimum value to start
    bool public ended; // Tracks if auction is already finalized

    // Events to notify frontend or blockchain observers
    event NewOffer(address indexed bidder, uint256 amount);
    event AuctionEnded(address winner, uint256 amount);
    event PartialRefund(address indexed bidder, uint256 amount);
    event EmergencyWithdraw(address to, uint256 amount);

    // Only the contract owner can call the function
    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    // Allows execution only while auction is active
    modifier whenActive() {
        require(block.timestamp < endDate, "Auction not active");
        _;
    }

    // Allows execution only after auction ends
    modifier whenNotActive() {
        require(block.timestamp >= endDate, "Auction still running");
        _;
    }

    // Constructor sets auction duration and owner
    constructor() {
        owner = msg.sender;
        endDate = block.timestamp + 7 days;
    }

    // Main bidding function
    function bid() external payable whenActive {
        require(msg.value > 0, "Bid must be greater than zero");

        uint256 bidQuantity = bids.length;
        uint256 minValue = bidQuantity == 0 ? initialValue : bids[bidQuantity - 1].value * 105 / 100;

        require(msg.value >= minValue, "Insufficient bid");

        // Extend auction if last 10 minutes
        if (block.timestamp > endDate - 10 minutes) {
            endDate += 10 minutes;
        }

        // Save bidder data
        myBids[msg.sender].last = msg.value;
        myBids[msg.sender].accumulated += msg.value;

        // Save bid
        bids.push(Bid(msg.sender, msg.value));

        emit NewOffer(msg.sender, msg.value);
    }

    // Returns the current winner (last bidder)
    function showWinner() external view returns (address) {
        uint256 bidQuantity = bids.length;
        require(bidQuantity > 0, "No bids yet");
        return bids[bidQuantity - 1].bidder;
    }

    // Returns the list of all bids
    function showBids() external view returns (Bid[] memory) {
        return bids;
    }

    // Finalizes the auction and returns deposits to losers minus 2%
    function retDeposit() external whenNotActive onlyOwner {
        require(!ended, "Auction already finalized");
        ended = true;

        uint256 bidQuantity = bids.length;
        address payable to;
        uint256 value;

        address winner = bids[bidQuantity - 1].bidder;

        for (uint256 i = 0; i < bidQuantity; i++) {
            to = payable(bids[i].bidder);

            if (to != winner) {
                value = myBids[to].accumulated;
                value = value * 98 / 100;

                if (value > 0) {
                    myBids[to].accumulated = 0;
                    to.transfer(value);
                }
            }
        }

        // Send remaining balance (the 2%) to the owner
        value = address(this).balance;
        to = payable(msg.sender);
        to.transfer(value);

        emit AuctionEnded(winner, bids[bidQuantity - 1].value);
    }

    // Allows participant to withdraw all previous bids except the last one
    function partialRefund() external whenActive {
        uint256 value = myBids[msg.sender].accumulated - myBids[msg.sender].last;
        require(value > 0, "Nothing to refund");

        myBids[msg.sender].accumulated = myBids[msg.sender].last;
        address payable to = payable(msg.sender);
        to.transfer(value);

        emit PartialRefund(msg.sender, value);
    }

    // Allows the owner to withdraw funds in case of emergency
    function emergencyWithdraw() external onlyOwner {
        uint256 value = address(this).balance;
        require(value > 0, "No balance available");

        payable(owner).transfer(value);
        emit EmergencyWithdraw(owner, value);
    }
}
