// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./AmmPool.sol";

contract SpotOracle {
    AmmPool public pool;

    constructor(address _pool) {
        pool = AmmPool(_pool);
    }

    function getPrice() external view returns (uint256) {
        return pool.getSpotPrice();
    }
}
