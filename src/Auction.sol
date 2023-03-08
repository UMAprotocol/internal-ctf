// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Challenge: 
// 1. The AuctionLogic contract is deployed.
// 2. The UpgradableAuction contract is deployed by someone else with the address of the AuctionLogic contract set as logic.
// 3. Other people bid.
// 4. Your task is to drain everyone else's bids and take back your own.
contract UpgradableAuction {
    address public admin;
    address public logic;

    constructor (address _logic) {
        admin = msg.sender;
        logic = _logic;
    }

    function setAdmin(address _admin) public {
        require(msg.sender == admin, "only admin");
        admin = _admin;
    }

    function setLogic(address _logic) public {
        require(msg.sender == admin, "only admin");
        logic = _logic;
        (bool success,) = logic.delegatecall(abi.encodeWithSignature("init()"));
        require(success);
    }

    fallback(bytes calldata data) external payable returns (bytes memory) {
        (bool success, bytes memory returnData) = logic.delegatecall(data);
        require(success, string(returnData));
        return returnData;
    }
}

contract AuctionLogic {
    address highestBidder;
    uint256 expiryTime;
    mapping(address => uint256) public bids;

    function init() public {
        require(expiryTime == 0, "Contract already initialized");
        highestBidder = address(0);
        expiryTime = block.timestamp + 10 days;
    }

    function bid() public payable {
        bids[msg.sender] += msg.value;
        if (bids[msg.sender] > bids[highestBidder]) {
            highestBidder = msg.sender;
        }
    }

    function withdraw() public {
        require(msg.sender != highestBidder, "Highest bidder cannot withdraw");
        uint256 amount = bids[msg.sender];
        bids[msg.sender] = 0;
        (bool success,) = msg.sender.call{value: amount}("");
        require(success);
    }

    function winner() public view returns (address) {
        require(block.timestamp > expiryTime, "Auction not yet ended");
        return highestBidder;
    }
}
