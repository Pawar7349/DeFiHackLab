// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../src/txorigin/VulnerableContract.sol";
import "../../src/txorigin/AttackContract.sol";
import "../../src/txorigin/FixedContract.sol";

contract TxOriginTest is Test {
    VulnerableContract vulnerable;
    FixedContract fixed_;

    address owner = makeAddr("owner");
    address payable thief = payable(makeAddr("thief"));

    function setUp() public {
        vm.prank(owner);
        vulnerable = new VulnerableContract();

        vm.prank(owner);
        fixed_ = new FixedContract();

        vm.deal(owner, 20 ether);
    }

    function test_attack_steals_all_eth() public {
        vm.prank(owner);
        vulnerable.deposit{value: 5 ether}();

        AttackContract attacker = new AttackContract(address(vulnerable), thief);

        vm.prank(owner, owner);
        attacker.attack();

        assertEq(vulnerable.getBalance(), 0);
        assertEq(thief.balance, 5 ether);
    }

    function test_fixed_blocks_attack() public {
        vm.prank(owner);
        fixed_.deposit{value: 5 ether}();

        AttackContract attacker = new AttackContract(address(fixed_), thief);

        vm.expectRevert();
        vm.prank(owner, owner);
        attacker.attack();

        assertEq(fixed_.getBalance(), 5 ether);
        assertEq(thief.balance, 0);
    }
}
