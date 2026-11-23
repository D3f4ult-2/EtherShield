
 // SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {ReplaySecure} from "../src/ReplaySecure.sol";

contract ReplaySecureTest is Test {

    ReplaySecure replay;

    uint256 alicePrivateKey = 0xA11CE;
    address alice;
    address bob;

    function setUp() public {
        alice = vm.addr(alicePrivateKey);
        bob = makeAddr("Bob");

        vm.prank(alice);
        replay = new ReplaySecure();
    }

    function signTransfer(
        ReplaySecure target,
        uint256 amount,
        uint256 nonce,
        uint256 deadline
    ) internal returns (uint8 v, bytes32 r, bytes32 s) {

        bytes32 structHash = keccak256(
            abi.encode(
                target.TRANSFER_TYPEHASH(),
                alice,
                bob,
                amount,
                nonce,
                deadline
            )
        );

        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                target.DOMAIN_SEPARATOR(),
                structHash
            )
        );

        return vm.sign(alicePrivateKey, digest);
    }

    function test_ValidSignature() public {
        uint256 amount = 100;
        uint256 deadline = block.timestamp + 1 days;

        (uint8 v, bytes32 r, bytes32 s) =
            signTransfer(replay, amount, 0, deadline);

        replay.transferWithSignature(
            alice, bob, amount, deadline, v, r, s
        );

        assertEq(replay.balances(alice), 900);
        assertEq(replay.balances(bob), 100);
        assertEq(replay.nonces(alice), 1);
    }

    function test_ReplayAttackBlocked() public {
        uint256 amount = 100;
        uint256 deadline = block.timestamp + 1 days;

        (uint8 v, bytes32 r, bytes32 s) =
            signTransfer(replay, amount, 0, deadline);

        replay.transferWithSignature(
            alice, bob, amount, deadline, v, r, s
        );

        // Réutilisation de la même signature
        vm.expectRevert("Invalid signature");

        replay.transferWithSignature(
            alice, bob, amount, deadline, v, r, s
        );
    }

    function test_ExpiredSignatureBlocked() public {
        uint256 amount = 100;
        uint256 currentTime = vm.getBlockTimestamp();
        uint256 deadline = currentTime + 1 hours;

        (uint8 v, bytes32 r, bytes32 s) =
            signTransfer(replay, amount, 0, deadline);

        vm.warp(deadline + 1);

        vm.expectRevert("Signature expired");

        replay.transferWithSignature(
            alice, bob, amount, deadline, v, r, s
        );
    }

    function test_SignatureForAnotherContractBlocked() public {
        uint256 amount = 100;
        uint256 deadline = block.timestamp + 1 days;

        (uint8 v, bytes32 r, bytes32 s) =
            signTransfer(replay, amount, 0, deadline);

        // Déployer un deuxième contrat
        vm.prank(alice);
        ReplaySecure anotherReplay = new ReplaySecure();

        // Réutiliser la signature du premier contrat
        vm.expectRevert("Invalid signature");

        anotherReplay.transferWithSignature(
            alice, bob, amount, deadline, v, r, s
        );
    }
}

