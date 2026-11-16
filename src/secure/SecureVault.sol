
pragma solidity ^0.8.13;

contract SecureVault {

    // Stocker le solde de chaque utilisateur
    mapping(address => uint256) public balances;

    // Permettre aux utilisateurs de deposer des ETH
    function deposit() external payable {
        require(msg.value > 0, "Amount must be greater than zero");

        balances[msg.sender] += msg.value;
    }

    // Retrait securise des ETH
    function withdraw() external {
        // 1. CHECKS : verifier le solde
        uint256 amount = balances[msg.sender];

        require(amount > 0, "Insufficient balance");

        // 2. EFFECTS : mettre a jour le solde AVANT le transfert
        balances[msg.sender] = 0;

        // 3. INTERACTIONS : envoyer les ETH apres la mise a jour
        (bool success, ) = payable(msg.sender).call{value: amount}("");

        require(success, "Transfer failed");
    }
}
