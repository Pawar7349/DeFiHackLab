// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FixedContract {
    mapping(address => uint256) public credits;

    function deposit() external payable {
        credits[msg.sender] += msg.value;
    }

    function withdraw(uint256 creditAmount) external {
        require(credits[msg.sender] >= creditAmount, "not enough credit");
        credits[msg.sender] -= creditAmount;
        payable(msg.sender).transfer(creditAmount);
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    receive() external payable {}
}
