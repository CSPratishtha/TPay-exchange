// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TpayToken is ERC20, Ownable {
    uint256 public constant MAX_SUPPLY = 1_000_000_000 * 1e18;

    mapping(address => uint256) public vestedAmount;
    mapping(address => uint256) public vestingEnd;

    constructor(address teamWallet, address marketingWallet)
        ERC20("Tpay Token", "TPAY")
        Ownable(msg.sender)
    {
        _mint(address(this), MAX_SUPPLY);

        // Initial distributions based on tokenomics
        _transfer(address(this), marketingWallet, MAX_SUPPLY * 20 / 100); // 20% to marketing
        _transfer(address(this), address(this), MAX_SUPPLY * 20 / 100);   // 20% for team vesting
        _transfer(address(this), owner(), MAX_SUPPLY * 10 / 100);         // 10% to ecosystem/DAO
        // 40% for LP mining, 10% DAO Treasury remain in contract

        startVesting(teamWallet, MAX_SUPPLY * 20 / 100, 730 days); // 2-year vesting
    }

    function startVesting(address beneficiary, uint256 amount, uint256 duration) internal {
        vestedAmount[beneficiary] = amount;
        vestingEnd[beneficiary] = block.timestamp + duration;
    }

    function claimVested() external {
        require(block.timestamp >= vestingEnd[msg.sender], "Vesting not ended");
        uint256 amount = vestedAmount[msg.sender];
        require(amount > 0, "No vested tokens");

        vestedAmount[msg.sender] = 0;
        _transfer(address(this), msg.sender, amount);
    }

    function distributeMiningRewards(address to, uint256 amount) external onlyOwner {
        require(balanceOf(address(this)) >= amount, "Not enough mining supply in contract");
        _transfer(address(this), to, amount);
    }
}

