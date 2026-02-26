// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VulnerableContract {
    uint256 public constant targetAmount = 5 ether;

    function deposit() external payable {
        require(msg.value == 1 ether, "send 1 ether");
        require(address(this).balance <= targetAmount, "game over");
    }

    function claimReward() external {
        require(address(this).balance == targetAmount, "not finished");
        payable(msg.sender).transfer(targetAmount);
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    receive() external payable {}
}
