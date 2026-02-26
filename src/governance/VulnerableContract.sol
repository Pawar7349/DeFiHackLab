// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./GovToken.sol";

contract VulnerableContract {
    GovToken public token;

    constructor(address _token) {
        token = GovToken(_token);
    }

    function executeEmergencyExit(address payable to) external {
        require(token.balanceOf(msg.sender) > token.totalSupply() / 2, "not enough votes");
        to.transfer(address(this).balance);
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    receive() external payable {}
}
