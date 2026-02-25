// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FixedContract {
    address public signer;
    mapping(bytes32 => bool) public used;

    constructor(address _signer) {
        signer = _signer;
    }

    function claim(address payable to, uint256 amount, uint256 nonce, uint8 v, bytes32 r, bytes32 s) external {
        bytes32 payload = keccak256(abi.encodePacked(address(this), block.chainid, to, amount, nonce));
        bytes32 digest = _toEthSignedMessageHash(payload);

        require(!used[digest], "already used");
        require(ecrecover(digest, v, r, s) == signer, "bad signature");

        used[digest] = true;
        to.transfer(amount);
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function _toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    receive() external payable {}
}
