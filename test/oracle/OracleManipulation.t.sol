// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../src/oracle/AmmPool.sol";
import "../../src/oracle/SpotOracle.sol";
import "../../src/oracle/VulnerableContract.sol";
import "../../src/oracle/FixedContract.sol";
import "../../src/oracle/AttackContract.sol";

contract OracleManipulationTest is Test {
    address attacker = makeAddr("attacker");

    function test_attack_drains_vulnerable_vault() public {
        AmmPool pool = new AmmPool{value: 10 ether}(10 ether);
        SpotOracle oracle = new SpotOracle(address(pool));
        VulnerableContract vulnerable = new VulnerableContract(address(oracle));

        vm.deal(address(this), 50 ether);
        payable(address(vulnerable)).transfer(20 ether);

        AttackContract attackContract = new AttackContract(address(vulnerable), address(pool));

        vm.deal(attacker, 10 ether);
        uint256 beforeBalance = attacker.balance;

        vm.prank(attacker);
        attackContract.attack{value: 10 ether}();

        assertGt(attacker.balance, beforeBalance);
        assertLt(vulnerable.getBalance(), 20 ether);
    }

    function test_fixed_blocks_price_attack() public {
        AmmPool pool = new AmmPool{value: 10 ether}(10 ether);
        FixedContract fixed_ = new FixedContract();

        vm.deal(address(this), 50 ether);
        payable(address(fixed_)).transfer(20 ether);

        AttackContract attackContract = new AttackContract(address(fixed_), address(pool));

        vm.deal(attacker, 10 ether);

        vm.expectRevert("no profit");
        vm.prank(attacker);
        attackContract.attack{value: 10 ether}();

        assertEq(fixed_.getBalance(), 20 ether);
    }

    receive() external payable {}
}
