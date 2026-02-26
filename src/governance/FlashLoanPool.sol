// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./GovToken.sol";

interface IFlashLoanReceiver {
    function receiveFlashLoan(uint256 amount) external;
}

contract FlashLoanPool {
    GovToken public token;

    constructor(address _token) {
        token = GovToken(_token);
    }

    function flashLoan(uint256 amount) external {
        uint256 balanceBefore = token.balanceOf(address(this));
        require(amount <= balanceBefore, "not enough token");

        token.transfer(msg.sender, amount);
        IFlashLoanReceiver(msg.sender).receiveFlashLoan(amount);

        require(token.balanceOf(address(this)) >= balanceBefore, "loan not repaid");
    }
}
