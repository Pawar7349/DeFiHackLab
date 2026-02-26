// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AmmPool {
    uint256 public tokenReserve;
    uint256 public ethReserve;
    mapping(address => uint256) public tokenBalances;

    constructor(uint256 _tokenReserve) payable {
        require(_tokenReserve > 0, "bad reserve");
        require(msg.value > 0, "bad reserve");
        tokenReserve = _tokenReserve;
        ethReserve = msg.value;
    }

    function getSpotPrice() external view returns (uint256) {
        return (ethReserve * 1e18) / tokenReserve;
    }

    function swapEthForToken() external payable returns (uint256 tokenOut) {
        require(msg.value > 0, "zero eth");

        uint256 k = ethReserve * tokenReserve;
        uint256 newEthReserve = ethReserve + msg.value;
        uint256 newTokenReserve = k / newEthReserve;

        tokenOut = tokenReserve - newTokenReserve;

        tokenReserve = newTokenReserve;
        ethReserve = newEthReserve;
        tokenBalances[msg.sender] += tokenOut;
    }

    function swapTokenForEth(uint256 tokenIn) external returns (uint256 ethOut) {
        require(tokenIn > 0, "zero token");
        require(tokenBalances[msg.sender] >= tokenIn, "not enough token");

        uint256 k = ethReserve * tokenReserve;
        uint256 newTokenReserve = tokenReserve + tokenIn;
        uint256 newEthReserve = k / newTokenReserve;

        ethOut = ethReserve - newEthReserve;

        tokenBalances[msg.sender] -= tokenIn;
        tokenReserve = newTokenReserve;
        ethReserve = newEthReserve;

        payable(msg.sender).transfer(ethOut);
    }
}
