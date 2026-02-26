// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Proxy {
    bytes32 internal constant IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    constructor(address implementation, bytes memory initData) payable {
        assembly {
            sstore(IMPLEMENTATION_SLOT, implementation)
        }

        if (initData.length > 0) {
            (bool ok,) = implementation.delegatecall(initData);
            require(ok, "init failed");
        }
    }

    fallback() external payable {
        _delegate(_implementation());
    }

    receive() external payable {
        _delegate(_implementation());
    }

    function _implementation() internal view returns (address impl) {
        assembly {
            impl := sload(IMPLEMENTATION_SLOT)
        }
    }

    function _delegate(address impl) internal {
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }
}
