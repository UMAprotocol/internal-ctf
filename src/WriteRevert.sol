// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Challenge:
// 1. The WriteRevert contract is extremely simple. It takes a value and stores it. Anyone can call this function.
// 2. Your task is to populate the TriggerWriteRevert contract with three distinct methods (or as many as you can find) that will cause the WriteRevert contract to revert.
// 3. The first rule is that you _must_ call the setValue function. You cannot call functions that do not exist.
// 4. The second rule is that OOG (out of gas) reverts don't count.
// 5. Good luck!

contract WriteRevert {
    uint256 public value;

    function setValue(uint256 _value) public {
        value = _value;
    }
}

contract TriggerWriteRevert {
    function forceRevert1() public {
        // Your code here!
    }

    function forceRevert2() public {
        // Your code here!
    }

    function forceRevert3() public {
        // Your code here!
    }
}
