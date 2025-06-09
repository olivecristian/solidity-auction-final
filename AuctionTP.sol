// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Auction {
    struct Biders {
        uint256 value;
        address bider;
    }

    address public owner;
    Biders public winner;
    Biders[] public biders;
    mapping(address => uint256[]) public biddingHistory;
    mapping(address => uint256) public deposits;

    uint256 public startTime;
    uint256 public stopTime;
    uint256 public commission = 2;
    bool public ended;

    event NewOffer(address indexed bider, uint256 amount);
    event AuctionEnded(address winner, uint256 amount);

    modifier isActive() {
        require(block.timestamp < stopTime, "Auction has ended.");
        _;
    }

    modifier onlyAfterEnd() {
        require(block.timestamp >= stopTime, "Auction is still active.");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can execute this.");
        _;
    }

    constructor() {
    owner = msg.sender;
    startTime = block.timestamp;
    stopTime = startTime + 45 minutes;
}


    function bid() external payable isActive {
        require(msg.value > 0, "Bid must be greater than zero.");

        if (winner.value == 0 || msg.value >= (winner.value * 105) / 100) {
            // Extend time if bid is made in the last 10 minutes
            if (stopTime - block.timestamp <= 10 minutes) {
                stopTime += 10 minutes;
            }

            // Save the new bid
            biders.push(Biders(msg.value, msg.sender));
            biddingHistory[msg.sender].push(msg.value);
            deposits[msg.sender] += msg.value;

            winner.value = msg.value;
            winner.bider = msg.sender;

            emit NewOffer(msg.sender, msg.value);
        } else {
            revert("Bid must exceed current highest by at least 5%");
        }
    }

    function showWiner() external view onlyAfterEnd returns (Biders memory) {
        return winner;
    }

    function showOffers() external view returns (Biders[] memory) {
        return biders;
    }

    function refund() external onlyAfterEnd {
        require(msg.sender != winner.bider, "Winner cannot claim refund.");
        uint256 refundAmount = deposits[msg.sender];
        require(refundAmount > 0, "Nothing to refund.");

        deposits[msg.sender] = 0;
        payable(msg.sender).transfer(refundAmount);
    }

    function finalizeAuction() external onlyOwner onlyAfterEnd {
        require(!ended, "Auction already finalized.");
        ended = true;

        uint256 winningAmount = winner.value;
        uint256 fee = (winningAmount * commission) / 100;
        uint256 netAmount = winningAmount - fee;

        payable(owner).transfer(netAmount);

        emit AuctionEnded(winner.bider, winner.value);
    }

    function partialRefund() external isActive {
        uint256[] storage bids = biddingHistory[msg.sender];
        require(bids.length > 1, "No partial refund available.");

        uint256 refundable = 0;

        for (uint256 i = 0; i < bids.length - 1; i++) {
            refundable += bids[i];
            bids[i] = 0;
        }

        require(refundable > 0, "No refundable balance.");
        deposits[msg.sender] -= refundable;
        payable(msg.sender).transfer(refundable);
    }
}
