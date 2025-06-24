// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./TpayFactory.sol";
import "./TpayPair.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TpayRouter {
    TpayFactory public factory;

    constructor(address _factory) {
        factory = TpayFactory(_factory);
    }

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountA,
        uint amountB
    ) external returns (address pair) {
        pair = factory.getPair(tokenA, tokenB);
        if (pair == address(0)) {
            pair = factory.createPair(tokenA, tokenB);
        }
        TpayPair(pair).addLiquidity(amountA, amountB, msg.sender);
    }

    function swap(
        address tokenIn,
        address tokenOut,
        uint amountOut
    ) external {
        address pair = factory.getPair(tokenIn, tokenOut);
        require(pair != address(0), "Pair not found");

        IERC20(tokenIn).transferFrom(msg.sender, pair, IERC20(tokenIn).balanceOf(msg.sender));
        TpayPair(pair).swap(
            tokenIn == TpayPair(pair).token0() ? 0 : amountOut,
            tokenIn == TpayPair(pair).token0() ? amountOut : 0,
            msg.sender
        );
    }
}
