// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../../src/secure/SecureTreasury.sol";

contract SecureTreasuryTest is Test {
    SecureTreasury treasury;
    address owner = makeAddr("owner");
    address attacker = makeAddr("attacker");

    function setUp() public {
        vm.deal(owner, 10 ether);
        vm.prank(owner);
        treasury = new SecureTreasury{value: 10 ether}();
    }

    function test_AccessControlAttackBlocked() public {
        vm.startPrank(attacker);
        vm.expectRevert(SecureTreasury.NotOwner.selector);
        treasury.setOwner(attacker);
        vm.expectRevert(SecureTreasury.NotOwner.selector);
        treasury.setFee(100);
        vm.expectRevert(SecureTreasury.NotOwner.selector);
        treasury.emergencyWithdraw();
        vm.stopPrank();

        assertEq(treasury.owner(), owner);
        assertEq(address(treasury).balance, 10 ether);
        assertEq(attacker.balance, 0);
    }

    function test_OwnerStillWorks() public {
        vm.prank(owner);
        treasury.setFee(5);
        assertEq(treasury.feePercent(), 5);
    }
}
