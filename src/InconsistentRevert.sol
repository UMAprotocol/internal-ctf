// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Challenge:
// 1. In block 100, 1 ETH is sent to an address (without calldata, simple transfer), it reverts.
// 2. In block 600, 1 ETH is sent to the same address (without calldata, simple transfer), no revert.
// 3. In block 1000, 1 ETH is sent to the same address (without calldata, simple transfer), it reverts.
// 4. Your task is to provide an example of how you could orchestrate this.
// 5. The only rule is that you _cannot_ use a contract with a fallback function or receive function.
// 6. Note: block space was intentionally left between these transactions for you to use.