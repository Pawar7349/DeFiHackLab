// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../src/governance/GovToken.sol";
import "../../src/governance/FlashLoanPool.sol";
import "../../src/governance/VulnerableContract.sol";
import "../../src/governance/FixedContract.sol";
import "../../src/governance/AttackContract.sol";

contract GovernanceAttackTest is Test {
    GovToken token;
    FlashLoanPool pool;
    VulnerableContract vulnerable;
    FixedContract fixed_;

    address attacker = makeAddr("attacker");

    function setUp() public {
        token = new GovToken();
        pool = new FlashLoanPool(address(token));

        vulnerable = new VulnerableContract(address(token));
        fixed_ = new FixedContract(address(token));

        token.mint(address(pool), 1_000_000 ether);

        vm.deal(address(this), 100 ether);
        payable(address(vulnerable)).transfer(25 ether);
        payable(address(fixed_)).transfer(25 ether);
    }

    function test_flashloan_vote_drains_vulnerable_treasury() public {
        AttackContract attackContract =
            new AttackContract(address(token), address(pool), address(vulnerable), payable(attacker));

        vm.prank(attacker);
        attackContract.attack();

        assertEq(vulnerable.getBalance(), 0);
        assertEq(attacker.balance, 25 ether);
    }

    function test_fixed_blocks_flashloan_vote() public {
        AttackContract attackContract =
            new AttackContract(address(token), address(pool), address(fixed_), payable(attacker));

        vm.expectRevert();
        vm.prank(attacker);
        attackContract.attack();

        assertEq(fixed_.getBalance(), 25 ether);
        assertEq(attacker.balance, 0);
    }
}
