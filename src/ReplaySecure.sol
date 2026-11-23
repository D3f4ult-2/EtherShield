
 // SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract ReplaySecure {

    mapping(address => uint256) public balances;
    mapping(address => uint256) public nonces;

    bytes32 public immutable DOMAIN_SEPARATOR;

    bytes32 public constant TRANSFER_TYPEHASH =
        keccak256(
            "Transfer(address user,address recipient,uint256 amount,uint256 nonce,uint256 deadline)"
        );

    event TransferAuthorized(
        address indexed user,
        address indexed recipient,
        uint256 amount
    );

    constructor() {
        balances[msg.sender] = 1000;

        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256(
                    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                ),
                keccak256(bytes("EtherShield")),
                keccak256(bytes("1")),
                block.chainid,
                address(this)
            )
        );
    }

    function transferWithSignature(
        address user,
        address recipient,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {

        require(block.timestamp <= deadline, "Signature expired");

        uint256 currentNonce = nonces[user];

        bytes32 structHash = keccak256(
            abi.encode(
                TRANSFER_TYPEHASH,
                user,
                recipient,
                amount,
                currentNonce,
                deadline
            )
        );

        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                structHash
            )
        );

                // Vérification de la signature ECDSA
        require(v == 27 || v == 28, "Invalid v");

        require(
            uint256(s) <=
            0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0,
            "Invalid s"
        );

        require(
            r != bytes32(0) && s != bytes32(0),
            "Invalid signature"
        );

        address signer = ecrecover(digest, v, r, s);

        require(signer != address(0) && signer == user, "Invalid signature");
        require(balances[user] >= amount, "Insufficient balance");

        // Incrémenter le nonce avant le transfert
        nonces[user]++;

        balances[user] -= amount;
        balances[recipient] += amount;

        emit TransferAuthorized(user, recipient, amount);
    }
}

