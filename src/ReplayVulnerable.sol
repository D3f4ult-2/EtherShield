
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract ReplayVulnerable {

    mapping(address => uint256) public balances;

    event TransferAuthorized(
        address indexed user,
        address indexed recipient,
        uint256 amount
    );

    constructor() {
        balances[msg.sender] = 1000;
    }

    function transferWithSignature(
        address user,
        address recipient,
        uint256 amount,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        bytes32 messageHash = keccak256(
            abi.encodePacked(user, recipient, amount)
        );

        address signer = ecrecover(
            messageHash,
            v,
            r,
            s
        );

        require(signer == user, "Invalid signature");
        require(balances[user] >= amount, "Insufficient balance");

        balances[user] -= amount;
        balances[recipient] += amount;

        emit TransferAuthorized(user, recipient, amount);
    }
}

