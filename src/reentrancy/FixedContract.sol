// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FixedContract{
    mapping(address => uint256) public balances;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() public {
        uint256 amount = balances[msg.sender];
        require(amount > 0);

        balances[msg.sender] = 0;

        (bool success, ) = msg.sender.call{value: amount}("");
        require(success);
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}