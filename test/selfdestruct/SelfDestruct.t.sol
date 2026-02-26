// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../src/selfdestruct/VulnerableContract.sol";
import "../../src/selfdestruct/AttackContract.sol";
import "../../src/selfdestruct/FixedContract.sol";

contract SelfDestructTest is Test {
    VulnerableContract vulnerable;
    FixedContract fixed_;

    receive() external payable {}

    function setUp() public {
        vulnerable = new VulnerableContract();
        fixed_ = new FixedContract();
        vm.deal(address(this), 20 ether);
    }

    function test_attack_breaks_game() public {
        for (uint256 i = 0; i < 4; i++) {
            vulnerable.deposit{value: 1 ether}();
        }

        AttackContract attacker = new AttackContract{value: 2 ether}();
        attacker.attack(payable(address(vulnerable)));

        vm.expectRevert();
        vulnerable.deposit{value: 1 ether}();

        vm.expectRevert();
        vulnerable.claimReward();
    }

    function test_fixed_still_works() public {
        for (uint256 i = 0; i < 4; i++) {
            fixed_.deposit{value: 1 ether}();
        }

        AttackContract attacker = new AttackContract{value: 2 ether}();
        attacker.attack(payable(address(fixed_)));

        fixed_.deposit{value: 1 ether}();

        uint256 beforeBalance = address(this).balance;
        fixed_.claimReward();

        assertEq(address(this).balance, beforeBalance + 5 ether);
        assertEq(fixed_.deposited(), 0);
        assertEq(fixed_.getBalance(), 2 ether);
    }
}
