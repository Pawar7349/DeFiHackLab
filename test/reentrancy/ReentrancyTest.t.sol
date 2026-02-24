//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;



import "forge-std/Test.sol";
import "../../src/reentrancy/VulnerableContract.sol";
import "../../src/reentrancy/AttackContract.sol";
import "../../src/reentrancy/FixedContract.sol";


contract ReentrancyTest is Test {
    VulnerableContract vulnerable;
    AttackContract attacker;
    FixedContract fixed_;

    function setUp() public {
        vulnerable = new VulnerableContract();
        attacker = new AttackContract(address(vulnerable));
        fixed_ = new FixedContract();
    }



    function test_attack_drains_vulnerable_vault() public {
        vm.deal(address(this), 6 ether);
        vulnerable.deposit{value: 5 ether}();
        attacker.attack{value: 1 ether}();

        assertEq(vulnerable.getBalance(), 0);
        assertGt(attacker.getBalance(), 5 ether);
    }

    function test_attack_fails_on_fixed() public {
        vm.deal(address(this), 6 ether);
        fixed_.deposit{value: 5 ether}();
    
        AttackContract attackerFixed = new AttackContract(address(fixed_));
    
        vm.expectRevert();
        attackerFixed.attack{value: 1 ether}();
   }
}