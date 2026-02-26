// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../src/overflow/VulnerableContract.sol";
import "../../src/overflow/AttackContract.sol";
import "../../src/overflow/FixedContract.sol";

contract OverflowTest is Test {
    VulnerableContract vulnerable;
    AttackContract attackerContract;
    FixedToken fixed_;

    address attacker = makeAddr("attacker");

    function setUp() public {
        vulnerable = new VulnerableContract();
        attackerContract = new AttackContract(address(vulnerable));
        fixed_ = new FixedToken();
    }

    function test_attack_mints_tokens() public {
        attackerContract.attack(attacker);

        assertGt(vulnerable.balances(attacker), 1000);
        assertEq(vulnerable.balances(address(this)), 1000);
    }

    function test_fixed_stops_overflow() public {
        uint256 numTokens = type(uint256).max / 2 + 1;
        uint256 amount = 2;

        vm.expectRevert();
        fixed_.transfer(attacker, numTokens, amount);
    }
}
