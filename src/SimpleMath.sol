// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Bank {
    // User -> Token -> Balance
    mapping(address => mapping(address => uint256)) public balances;

    function deposit(address token) public payable {
        balances[msg.sender][] += msg.value;
    }

}