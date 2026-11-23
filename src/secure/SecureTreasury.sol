// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

contract SecureTreasury {
    address public owner;
    uint256 public feePercent;

    event OwnerChanged(address indexed oldOwner, address indexed newOwner);

    error NotOwner();

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    constructor() payable {
        owner = msg.sender;
        feePercent = 1;
    }

    function deposit() external payable {}

    function setOwner(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Zero address");
        emit OwnerChanged(owner, newOwner);
        owner = newOwner;
    }

    function setFee(uint256 newFee) external onlyOwner {
        require(newFee <= 10, "Fee too high");
        feePercent = newFee;
    }

    function emergencyWithdraw() external onlyOwner {
        (bool ok, ) = owner.call{value: address(this).balance}("");
        require(ok, "Transfer failed");
    }
}