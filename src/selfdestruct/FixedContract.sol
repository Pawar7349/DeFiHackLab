// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FixedContract {
    uint256 public constant targetAmount = 5 ether;
    uint256 public deposited;

    function deposit() external payable {
        require(msg.value == 1 ether, "send 1 ether");
        require(deposited + msg.value <= targetAmount, "game over");
        deposited += msg.value;
    }

    function claimReward() external {
        require(deposited == targetAmount, "not finished");
        deposited = 0;
        payable(msg.sender).transfer(targetAmount);
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    receive() external payable {}
}
