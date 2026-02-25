// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

import {FixedToken} from "../../src/overflow/FixedContract.sol";
import {FixedContract as ReentrancyFixed} from "../../src/reentrancy/FixedContract.sol";
import {FixedContract as TxOriginFixed} from "../../src/txorigin/FixedContract.sol";
import {FixedContract as SelfDestructFixed} from "../../src/selfdestruct/FixedContract.sol";
import {FixedContract as OracleFixed} from "../../src/oracle/FixedContract.sol";
import {FixedContract as GovernanceFixed} from "../../src/governance/FixedContract.sol";
import {GovToken} from "../../src/governance/GovToken.sol";
import {FixedContract as SignatureFixed} from "../../src/signature-replay/FixedContract.sol";
import {FixedContract as UpgradeFixed} from "../../src/upgrade-misconfig/FixedContract.sol";

contract FixedPropertiesTest is Test {
    FixedToken overflowFixed;
    ReentrancyFixed reentrancyFixed;
    TxOriginFixed txOriginFixed;
    SelfDestructFixed selfDestructFixed;
    OracleFixed oracleFixed;
    GovernanceFixed governanceFixed;
    GovToken governanceToken;
    SignatureFixed signatureFixed;
    UpgradeFixed upgradeFixed;

    uint256 internal signerPk = 0xA11CE;
    address internal signer;

    function setUp() public {
        overflowFixed = new FixedToken();
        reentrancyFixed = new ReentrancyFixed();
        txOriginFixed = new TxOriginFixed();
        selfDestructFixed = new SelfDestructFixed();
        oracleFixed = new OracleFixed();

        governanceToken = new GovToken();
        governanceFixed = new GovernanceFixed(address(governanceToken));
        governanceToken.mint(address(this), 1_000_000 ether);
        governanceToken.approve(address(governanceFixed), type(uint256).max);

        signer = vm.addr(signerPk);
        signatureFixed = new SignatureFixed(signer);
        upgradeFixed = new UpgradeFixed();

        vm.deal(address(this), 300 ether);

        txOriginFixed.deposit{value: 20 ether}();
        payable(address(signatureFixed)).transfer(20 ether);
        payable(address(governanceFixed)).transfer(20 ether);
    }

    function testFuzz_overflowFixed_transfer_conserves_supply(uint128 numTokens, uint128 amount) public {
        numTokens = uint128(bound(numTokens, 0, 1000));
        amount = uint128(bound(amount, 0, 1000));

        uint256 total = uint256(numTokens) * uint256(amount);
        vm.assume(total <= 1000);

        address to = makeAddr("to");
        overflowFixed.transfer(to, numTokens, amount);

        assertEq(overflowFixed.balances(address(this)) + overflowFixed.balances(to), 1000);
    }

    function testFuzz_reentrancyFixed_withdraw_resets_user_balance(uint96 amount) public {
        amount = uint96(bound(amount, 1, 10 ether));
        address user = makeAddr("user");

        vm.deal(user, amount);

        vm.prank(user);
        reentrancyFixed.deposit{value: amount}();

        assertEq(reentrancyFixed.balances(user), amount);

        vm.prank(user);
        reentrancyFixed.withdraw();

        assertEq(reentrancyFixed.balances(user), 0);
    }

    function testFuzz_txoriginFixed_blocks_non_owner(uint96 amount) public {
        amount = uint96(bound(amount, 0, 20 ether));
        address attacker = makeAddr("attacker");

        vm.expectRevert("only owner");
        vm.prank(attacker);
        txOriginFixed.transferTo(payable(attacker), amount);

        assertEq(txOriginFixed.getBalance(), 20 ether);
    }

    function testFuzz_selfDestructFixed_caps_deposit(uint8 count) public {
        count = uint8(bound(count, 0, 8));

        uint8 capped = count > 5 ? 5 : count;
        for (uint8 i = 0; i < capped; i++) {
            address user = address(uint160(i + 1));
            vm.deal(user, 1 ether);

            vm.prank(user);
            selfDestructFixed.deposit{value: 1 ether}();
        }

        if (count > 5) {
            address extra = makeAddr("extra");
            vm.deal(extra, 1 ether);

            vm.expectRevert("game over");
            vm.prank(extra);
            selfDestructFixed.deposit{value: 1 ether}();
        }

        assertLe(selfDestructFixed.deposited(), selfDestructFixed.targetAmount());
    }

    function testFuzz_oracleFixed_withdraw_never_exceeds_credit(uint96 depositAmount, uint96 withdrawAmount) public {
        depositAmount = uint96(bound(depositAmount, 1, 10 ether));
        withdrawAmount = uint96(bound(withdrawAmount, 0, depositAmount));

        address user = makeAddr("oracle-user");
        vm.deal(user, depositAmount);

        vm.prank(user);
        oracleFixed.deposit{value: depositAmount}();

        vm.prank(user);
        oracleFixed.withdraw(withdrawAmount);

        assertEq(oracleFixed.credits(user), depositAmount - withdrawAmount);
        assertEq(oracleFixed.getBalance(), depositAmount - withdrawAmount);
    }

    function testFuzz_signatureFixed_blocks_replay(uint96 amount, uint64 nonce) public {
        amount = uint96(bound(amount, 1, 2 ether));
        address payable claimer = payable(makeAddr("claimer"));
        uint256 normalizedAmount = uint256(amount);
        uint256 normalizedNonce = uint256(nonce);

        bytes32 payload =
            keccak256(abi.encodePacked(address(signatureFixed), block.chainid, claimer, normalizedAmount, normalizedNonce));
        bytes32 digest = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", payload));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerPk, digest);

        vm.prank(claimer);
        signatureFixed.claim(claimer, normalizedAmount, normalizedNonce, v, r, s);

        vm.expectRevert("already used");
        vm.prank(claimer);
        signatureFixed.claim(claimer, normalizedAmount, normalizedNonce, v, r, s);
    }

    function testFuzz_upgradeFixed_initialize_only_once(address firstOwner, address secondOwner) public {
        vm.assume(firstOwner != address(0));

        upgradeFixed.initialize(firstOwner);

        vm.expectRevert("already initialized");
        upgradeFixed.initialize(secondOwner);

        assertEq(upgradeFixed.owner(), firstOwner);
        assertTrue(upgradeFixed.initialized());
    }

    function testFuzz_governanceFixed_requires_block_delay(uint256 stakeAmount) public {
        uint256 halfSupply = governanceToken.totalSupply() / 2;
        stakeAmount = bound(stakeAmount, halfSupply + 1, governanceToken.totalSupply());

        governanceFixed.stake(stakeAmount);

        vm.expectRevert("wait one block");
        governanceFixed.executeEmergencyExit(payable(address(this)));

        vm.roll(block.number + 1);
        governanceFixed.executeEmergencyExit(payable(address(this)));

        assertEq(governanceFixed.getBalance(), 0);
    }

    receive() external payable {}
}
