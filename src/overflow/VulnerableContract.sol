// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VulnerableContract {
    mapping(address => uint256) public balances;

    constructor() {
        balances[msg.sender] = 1000;
    }

    function transfer(address to, uint256 numTokens, uint256 amount) public {
        uint256 total;
        unchecked {
            total = numTokens * amount;
        }

        require(balances[msg.sender] >= total, "not enough balance");
        balances[msg.sender] -= total;
        balances[to] += numTokens;
    }
}
