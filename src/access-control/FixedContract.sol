// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FixedContract {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function withdraw() public {
        require(msg.sender == owner);
        payable(owner).transfer(address(this).balance);
    }

    receive() external payable {}
}
