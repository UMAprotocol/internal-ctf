// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Poker
 * @dev A contract to track poker winnings and owed money
 * Admin can update player balances and players can deposit/withdraw funds
 */
contract Poker is Ownable {
    // Mapping to track each player's balance
    mapping(address => int256) public playerBalances;

    // Events
    event BalanceUpdated(
        address indexed player,
        int256 newBalance,
        int256 previousBalance
    );
    event Deposit(address indexed player, uint256 amount);
    event Withdrawal(address indexed player, uint256 amount);
    event AdminBalanceUpdate(address indexed player, int256 newBalance);

    // Errors
    error InsufficientBalance();
    error InvalidAmount();
    error PlayerNotFound();

    /**
     * @dev Allows admin to update a player's balance
     * @param player The address of the player
     * @param newBalance The new balance for the player (can be negative for owed money)
     */
    function updatePlayerBalance(
        address player,
        int256 newBalance
    ) external onlyOwner {
        if (player == address(0)) revert PlayerNotFound();

        int256 previousBalance = playerBalances[player];
        playerBalances[player] = newBalance;

        emit AdminBalanceUpdate(player, newBalance);
        emit BalanceUpdated(player, newBalance, previousBalance);
    }

    /**
     * @dev Allows players to deposit ETH into the contract
     */
    function deposit() public payable {
        if (msg.value == 0) revert InvalidAmount();

        emit Deposit(msg.sender, msg.value);
    }

    /**
     * @dev Allows players to withdraw their balance
     */
    function withdraw() external {
        int256 balance = playerBalances[msg.sender];

        uint256 withdrawAmount = uint256(balance);

        if (balance <= 0) revert InsufficientBalance();

        // Check if contract has enough ETH
        if (address(this).balance < withdrawAmount)
            revert InsufficientBalance();

        // Transfer ETH to player
        (bool success, ) = payable(msg.sender).call{value: withdrawAmount}("");
        if (!success) revert();

        // Reset player balance to 0 after withdrawal
        playerBalances[msg.sender] = 0;

        emit Withdrawal(msg.sender, withdrawAmount);
        emit BalanceUpdated(msg.sender, 0, balance);
    }

    /**
     * @dev Allows players to withdraw a specific amount (up to their balance)
     * @param amount The amount to withdraw
     */
    function withdrawAmount(uint256 amount) external {
        if (amount == 0) revert InvalidAmount();

        uint256 balance = uint256(playerBalances[msg.sender]);

        if (balance <= 0 || balance < amount) revert InsufficientBalance();

        // Check if contract has enough ETH
        if (address(this).balance < amount) revert InsufficientBalance();

        // Transfer ETH to player
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        if (!success) revert();

        // Update player balance
        playerBalances[msg.sender] = balance - int256(amount);

        emit Withdrawal(msg.sender, amount);
        emit BalanceUpdated(msg.sender, balance - int256(amount), balance);
    }

    /**
     * @dev Receive function to accept ETH
     */
    receive() external payable {
        deposit();
    }
}
