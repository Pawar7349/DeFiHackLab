// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../src/signature-replay/VulnerableContract.sol";
import "../../src/signature-replay/FixedContract.sol";
import "../../src/signature-replay/AttackContract.sol";

contract SignatureReplayTest is Test {
    uint256 signerPk = 0xA11CE;
    address signer;
    address attacker = makeAddr("attacker");

    function setUp() public {
        signer = vm.addr(signerPk);
        vm.deal(address(this), 50 ether);
    }

    function test_replay_drains_vulnerable_vault() public {
        VulnerableContract vulnerable = new VulnerableContract(signer);
        payable(address(vulnerable)).transfer(10 ether);

        AttackContract attackContract = new AttackContract(address(vulnerable));

        uint256 amount = 1 ether;
        bytes32 payload = keccak256(abi.encodePacked(address(attackContract), amount));
        bytes32 digest = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", payload));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerPk, digest);

        vm.prank(attacker);
        attackContract.attack(5, amount, v, r, s);

        assertEq(attacker.balance, 5 ether);
        assertEq(vulnerable.getBalance(), 5 ether);
    }

    function test_fixed_blocks_replay() public {
        FixedContract fixed_ = new FixedContract(signer);
        payable(address(fixed_)).transfer(10 ether);

        uint256 amount = 1 ether;
        uint256 nonce = 7;

        bytes32 payload = keccak256(abi.encodePacked(address(fixed_), block.chainid, attacker, amount, nonce));
        bytes32 digest = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", payload));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerPk, digest);

        vm.prank(attacker);
        fixed_.claim(payable(attacker), amount, nonce, v, r, s);

        vm.expectRevert("already used");
        vm.prank(attacker);
        fixed_.claim(payable(attacker), amount, nonce, v, r, s);

        assertEq(attacker.balance, 1 ether);
        assertEq(fixed_.getBalance(), 9 ether);
    }

    receive() external payable {}
}
