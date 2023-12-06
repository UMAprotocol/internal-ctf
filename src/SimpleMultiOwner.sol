// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Challenge:
// 1. The SimpleMultiowner contract is deployed by someone else.
// 2. They have set some set of owners that does not include you.
// 3. Your task is to make yourself the only owner.
contract SimpleMultiOwner {
    event Propose(uint256 indexed proposalId, address indexed target, bytes data, address[] owners);
    event Execute(uint256 indexed proposalId, address indexed target, bytes data, address[] owners);

    address[] public owners;
    uint256 id = 0;

    mapping(uint256 => bytes32) public proposals;

    constructor() {
        owners = [msg.sender];
    }

    function addOwner(address owner) public {
        require(msg.sender == address(this), "Only self");
        owners.push(owner);
    }

    function removeOwner(address owner) public {
        require(msg.sender == address(this), "Only self");
        require(owners.length > 1, "Cannot remove last owner");
        for (uint256 i = 0; i < owners.length; i++) {
            if (owners[i] == owner) {
                owners[i] = owners[owners.length - 1];
                owners.pop();
                break;
            }
        }
    }

    // Anyone can propose a transaction.
    function propose(address target, bytes memory data) public {
        bytes32 proposal = _hashTransaction(target, data, owners);
        uint256 proposalId = id++;
        proposals[proposalId] = proposal;
        emit Propose(proposalId, target, data, owners);
    }

    // Only owners at the time of the proposal can execute a transaction.
    function execute(uint256 proposalId, address target, bytes memory data, address[] memory proposalOwners) public {
        // Verify that the caller was an owner at the time of the proposal.
        bool isOwner = false;
        for (uint256 i = 0; i < proposalOwners.length; i++) {
            if (msg.sender == proposalOwners[i]) {
                isOwner = true;
                break;
            }
        }
        require(isOwner, "Not an owner");
        bytes32 proposal = _hashTransaction(target, data, proposalOwners);
        require(proposal == proposals[proposalId], "Invalid execution");
        delete proposals[proposalId]; // Delete to prevent re-entrancy.
        (bool success,) = target.call(data);
        require(success, "Transaction failed");
        emit Execute(proposalId, target, data, proposalOwners);
    }

    function _hashTransaction(address target, bytes memory data, address[] memory proposalOwners)
        internal
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(target, data, proposalOwners));
    }
}
