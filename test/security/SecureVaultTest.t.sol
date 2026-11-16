
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {SecureVault} from "../../src/secure/SecureVault.sol";
import {ReentrancyAttacker} from "../../src/vulnerable/ReentrancyAttacker.sol";

contract SecureVaultTest is Test {

    SecureVault public vault;
    ReentrancyAttacker public attacker;

    address public victim = makeAddr("victim");

    // Initialisation avant chaque test
    function setUp() public {

        // 1. Deployer le contrat securise
        vault = new SecureVault();

        // 2. Donner 10 ETH a la victime
        vm.deal(victim, 10 ether);

        // 3. La victime depose 10 ETH
        vm.prank(victim);
        vault.deposit{value: 10 ether}();

        // 4. Deployer le contrat attaquant
        attacker = new ReentrancyAttacker(address(vault));
    }

    // Verifier que l'attaque par reentrance echoue
    function test_ReentrancyAttackBlocked() public {

        // Donner 1 ETH au contrat de test
        vm.deal(address(this), 1 ether);

        // L'attaque doit echouer
        vm.expectRevert(bytes("Transfer failed"));
        attacker.attack{value: 1 ether}();

        // Le vault doit toujours contenir les 10 ETH de la victime
        assertEq(address(vault).balance, 10 ether);

        // Le solde de la victime doit etre intact
        assertEq(vault.balances(victim), 10 ether);

        // Le contrat attaquant ne doit avoir recu aucun ETH
        assertEq(address(attacker).balance, 0);
    }
}
