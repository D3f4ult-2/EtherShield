// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

contract VulnerableTreasury {
    address public owner;
    uint256 public feePercent;

    constructor() payable {
        owner = msg.sender;
        feePercent = 1;
    }

    function deposit() external payable {}

    // BUG: anyone can call this, there is no access check
    function setOwner(address newOwner) external {
        owner = newOwner;
    }

    // BUG: anyone can change a critical parameter
    function setFee(uint256 newFee) external {
        feePercent = newFee;
    }

    function emergencyWithdraw() external {
        require(msg.sender == owner, "Not owner");
        (bool ok, ) = owner.call{value: address(this).balance}("");
        require(ok, "Transfer failed");
    }
}
