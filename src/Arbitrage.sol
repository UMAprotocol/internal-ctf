// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

// Challenge:
// You have this contract called arbitrage that has a secret fancy function called doArb().
// This function returns the profit or loss you make from your arb in ETH.
// The arb profits differ based on a variety of environmental factors that you don't know.
// Your job is to design a strategy to use this function to extract as much profit as possible.
// Rules:
// 1. Your strategy can involve offchain techniques and onchain techniques, but you must write any onchain code you
//    intend to use.
// 2. You cannot modify the doArb function, but you are free to create other functions that call it.

contract Arbitrage {
    function doArb() public returns (int256) {
        // Fancy financing here.
    }
}
