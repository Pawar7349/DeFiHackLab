// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VulnerableContract {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function deposit() external payable {}

    function transferTo(address payable to, uint256 amount) external {
        require(tx.origin == owner, "only owner");
        require(address(this).balance >= amount, "not enough ether");
        to.transfer(amount);
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    receive() external payable {}
}
