// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SpotOracle.sol";

contract VulnerableContract {
    SpotOracle public oracle;
    mapping(address => uint256) public credits;

    constructor(address _oracle) {
        oracle = SpotOracle(_oracle);
    }

    function deposit() external payable {
        credits[msg.sender] += msg.value;
    }

    function withdraw(uint256 creditAmount) external {
        require(credits[msg.sender] >= creditAmount, "not enough credit");

        uint256 payout = (creditAmount * oracle.getPrice()) / 1e18;
        credits[msg.sender] -= creditAmount;

        payable(msg.sender).transfer(payout);
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    receive() external payable {}
}
