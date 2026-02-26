// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../src/upgrade-misconfig/Proxy.sol";
import "../../src/upgrade-misconfig/VulnerableContract.sol";
import "../../src/upgrade-misconfig/FixedContract.sol";
import "../../src/upgrade-misconfig/AttackContract.sol";

contract UpgradeMisconfigTest is Test {
    address attacker = makeAddr("attacker");

    function test_uninitialized_proxy_gets_drained() public {
        VulnerableContract impl = new VulnerableContract();
        Proxy proxy = new Proxy(address(impl), "");

        vm.deal(address(this), 20 ether);
        payable(address(proxy)).transfer(10 ether);

        MaliciousWallet malicious = new MaliciousWallet();
        AttackContract attackContract = new AttackContract();

        vm.prank(attacker);
        attackContract.attack(address(proxy), address(malicious), payable(attacker));

        assertEq(address(proxy).balance, 0);
        assertEq(attacker.balance, 10 ether);
    }

    function test_initialized_proxy_blocks_attack() public {
        FixedContract impl = new FixedContract();
        bytes memory initData = abi.encodeWithSignature("initialize(address)", address(this));
        Proxy proxy = new Proxy(address(impl), initData);

        vm.deal(address(this), 20 ether);
        payable(address(proxy)).transfer(10 ether);

        MaliciousWallet malicious = new MaliciousWallet();
        AttackContract attackContract = new AttackContract();

        vm.expectRevert("already initialized");
        vm.prank(attacker);
        attackContract.attack(address(proxy), address(malicious), payable(attacker));

        assertEq(address(proxy).balance, 10 ether);
        assertEq(attacker.balance, 0);
    }

    receive() external payable {}
}
