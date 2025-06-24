// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TpayPair is ERC20("Tpay LP Token", "TLP") {
    address public token0;
    address public token1;

    uint112 private reserve0;
    uint112 private reserve1;

    function initialize(address _token0, address _token1) external {
        require(token0 == address(0) && token1 == address(0), "Already initialized");
        token0 = _token0;
        token1 = _token1;
    }

    function addLiquidity(uint amount0, uint amount1, address to) external {
        IERC20(token0).transferFrom(msg.sender, address(this), amount0);
        IERC20(token1).transferFrom(msg.sender, address(this), amount1);
        _mint(to, sqrt(amount0 * amount1));
        reserve0 += uint112(amount0);
        reserve1 += uint112(amount1);
    }

    function swap(uint amountOut0, uint amountOut1, address to) external {
        require(amountOut0 > 0 || amountOut1 > 0, "Insufficient output");

        if (amountOut0 > 0) IERC20(token0).transfer(to, amountOut0);
        if (amountOut1 > 0) IERC20(token1).transfer(to, amountOut1);

        uint balance0 = IERC20(token0).balanceOf(address(this));
        uint balance1 = IERC20(token1).balanceOf(address(this));

        require(balance0 * balance1 >= uint(reserve0) * uint(reserve1), "Invariant violation");

        reserve0 = uint112(balance0);
        reserve1 = uint112(balance1);
    }

    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}
