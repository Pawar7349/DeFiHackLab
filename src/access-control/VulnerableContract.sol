// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VulnerableContract {
    address public owner;
    bool public initialized;

    function initialize(address _owner) public {
        require(!initialized);
        owner = _owner;
        initialized = true;
    }

    function withdraw() public {
        require(msg.sender == owner);
        payable(owner).transfer(address(this).balance);
    }

    receive() external payable {}
}