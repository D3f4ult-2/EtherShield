pragma solidity ^0.8.13;


contract VulnerableVault {
    // Solde de chaque utilisateur 
    mapping(address => uint256) public balances;

    // Déposer des ETH
    function deposit() external payable {
        require(msg.value > 0, "Amount must be greater than zero");
        balances[msg.sender] += msg.value;
    }

    // Retrait des ETH
    function withdraw() external {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "Insufficient balance");

        // Envoi des ETH avant la mise a jour du solde
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Transfer failed");

        // Mise a jour
        balances[msg.sender] = 0;
    }
}


