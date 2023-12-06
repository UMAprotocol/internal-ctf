pragma solidity ^0.8.21;

import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {ECDSA} from "openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";

interface Callback {
    function depositCallback(address user, uint256 amount) external;

    function withdrawCallback(address user, uint256 amount) external;

    function sendCallback(address from, address to, uint256 amount) external;
}

contract Venmo {
    using SafeERC20 for IERC20;

    IERC20 public immutable token;

    mapping(address => uint256) public balances;

    constructor(IERC20 _token) {
        token = _token;
    }

    function deposit(uint256 amount, Callback callback) external {
        _deposit(msg.sender, amount, callback);
    }

    function withdraw(uint256 amount, Callback callback) external {
        _withdraw(msg.sender, amount, callback);
    }

    function send(uint256 amount, address to, Callback callback) external {
        _send(msg.sender, to, amount, callback);
    }

    function depositBySig(address user, uint256 amount, bytes calldata signature, Callback callback) external {
        bytes32 hashedInfo = keccak256(abi.encode("Venmo::depositBySig", amount));
        require(ECDSA.recover(hashedInfo, signature) == user);

        _deposit(user, amount, callback);
    }

    function withdrawBySig(address user, uint256 amount, bytes calldata signature, Callback callback) external {
        bytes32 hashedInfo = keccak256(abi.encode("Venmo::withdrawBySig", amount));
        require(ECDSA.recover(hashedInfo, signature) == user);

        _withdraw(user, amount, callback);
    }

    function sendBySig(address from, address to, uint256 amount, bytes calldata signature, Callback callback)
        external
    {
        bytes32 hashedInfo = keccak256(abi.encode("Venmo::sendBySig", to, amount));
        require(ECDSA.recover(hashedInfo, signature) == from);

        _send(from, to, amount, callback);
    }

    function _deposit(address user, uint256 amount, Callback callback) internal {
        token.safeTransferFrom(user, address(this), amount);
        balances[user] += amount;
        callback.depositCallback(user, amount);
    }

    function _withdraw(address user, uint256 amount, Callback callback) internal {
        token.safeTransfer(user, amount);
        balances[user] -= amount;
        callback.withdrawCallback(user, amount);
    }

    function _send(address from, address to, uint256 amount, Callback callback) internal {
        token.safeTransfer(to, amount);
        balances[from] -= amount;
        callback.sendCallback(from, to, amount);
    }
}
