// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MyERC20 {
    uint256 private _totalSupply;

    string public name;
    string public symbol;
    uint8 public immutable decimals;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 initialSupply
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        _mint(msg.sender, initialSupply);
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _getBalance(account);
    }

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256) {
        return _getAllowance(owner, spender);
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        _setAllowance(msg.sender, spender, amount);
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool) {
        uint256 currentAllowance = _getAllowance(from, msg.sender);
        require(currentAllowance >= amount, "ERC20: insufficient allowance");
        unchecked {
            _setAllowance(from, msg.sender, currentAllowance - amount);
        }

        _transfer(from, to, amount);
        return true;
    }

    function _transfer(address from, address to, uint256 amount) internal {
        require(to != address(0), "ERC20: transfer to zero");

        uint256 fromBal = _getBalance(from);
        require(fromBal >= amount, "ERC20: insufficient balance");

        unchecked {
            _setBalance(from, fromBal - amount);
            _setBalance(to, _getBalance(to) + amount);
        }

        emit Transfer(from, to, amount);
    }

    function _mint(address to, uint256 amount) internal {
        require(to != address(0), "ERC20: mint to zero");

        _totalSupply += amount;
        _setBalance(to, _getBalance(to) + amount);
        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal {
        uint256 fromBal = _getBalance(from);
        require(fromBal >= amount, "ERC20: burn exceeds balance");

        unchecked {
            _setBalance(from, fromBal - amount);
            _totalSupply -= amount;
        }
        emit Transfer(from, address(0), amount);
    }

    /// @dev Directly sets `account`’s balance (use with care).
    function _setBalance(address account, uint256 newBalance) internal {
        assembly ("memory-safe") {
            let slot := account
            sstore(slot, newBalance)
        }
    }

    /// @dev Returns current balance of `account`.
    function _getBalance(address account) internal view returns (uint256) {
        uint256 bal;
        assembly ("memory-safe") {
            let slot := account
            bal := sload(slot)
        }
        return bal;
    }

    /// @dev Directly sets allowance from `owner` to `spender`.
    function _setAllowance(
        address owner,
        address spender,
        uint256 newAmount
    ) internal {
        assembly ("memory-safe") {
            let slot := add(owner, spender)
            sstore(slot, newAmount)
        }
    }

    /// @dev Returns allowance from `owner` to `spender`.
    function _getAllowance(
        address owner,
        address spender
    ) internal view returns (uint256) {
        uint256 ret;
        assembly ("memory-safe") {
            let slot := add(owner, spender)
            ret := sload(slot)
        }
        return ret;
    }
}
