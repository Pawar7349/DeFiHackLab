// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./GovToken.sol";

contract FixedContract {
    GovToken public token;
    mapping(address => uint256) public staked;
    mapping(address => uint256) public stakeBlock;

    constructor(address _token) {
        token = GovToken(_token);
    }

    function stake(uint256 amount) external {
        require(amount > 0, "bad amount");
        token.transferFrom(msg.sender, address(this), amount);
        staked[msg.sender] += amount;
        stakeBlock[msg.sender] = block.number;
    }

    function executeEmergencyExit(address payable to) external {
        require(staked[msg.sender] > token.totalSupply() / 2, "not enough votes");
        require(block.number > stakeBlock[msg.sender], "wait one block");
        to.transfer(address(this).balance);
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    receive() external payable {}
}
