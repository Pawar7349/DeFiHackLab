// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../src/access-control/VulnerableContract.sol";
import "../../src/access-control/AttackContract.sol";
import "../../src/access-control/FixedContract.sol";

contract AccessControlTest is Test {
    VulnerableContract vulnerable;
    AttackContract attacker;
    FixedContract fixed_;

    function setUp() public {
        vulnerable = new VulnerableContract();
        attacker = new AttackContract(payable(address(vulnerable)));
        fixed_ = new FixedContract();
    }

    function test_attack_drains_wallet() public {
        vm.deal(address(this), 5 ether);
        payable(address(vulnerable)).transfer(5 ether);

        attacker.attack();

        assertEq(address(vulnerable).balance, 0);
    }

    function test_fixed_owner_is_set() public view {
        assertEq(fixed_.owner(), address(this));
    }
}
