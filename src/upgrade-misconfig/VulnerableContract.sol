// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VulnerableContract {
    bytes32 internal constant IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "only owner");
        _;
    }

    function initialize(address _owner) external {
        owner = _owner;
    }

    function upgradeTo(address newImplementation) external onlyOwner {
        assembly {
            sstore(IMPLEMENTATION_SLOT, newImplementation)
        }
    }

    function withdraw(address payable to) external onlyOwner {
        to.transfer(address(this).balance);
    }

    receive() external payable {}
}
