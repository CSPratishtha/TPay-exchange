// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./TpayTokenAndIncentives.sol";

contract TpayFarm is Ownable {
    // Info of each user.
    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
    }

    // Info of each pool.
    struct PoolInfo {
        IERC20 lpToken;
        uint256 allocPoint;
        uint256 lastRewardBlock;
        uint256 accTpayPerShare;
    }

    TpayToken public tpay;
    uint256 public tpayPerBlock;
    uint256 public totalAllocPoint = 0;
    uint256 public startBlock;

    PoolInfo[] public poolInfo;
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;

    constructor(
        address initialOwner,
        address _tpay,
        uint256 _tpayPerBlock,
        uint256 _startBlock
    ) Ownable(initialOwner) {
        tpay = TpayToken(_tpay);
        tpayPerBlock = _tpayPerBlock;
        startBlock = _startBlock;
    }

    function addPool(uint256 _allocPoint, IERC20 _lpToken) external onlyOwner {
        massUpdatePools();
        totalAllocPoint += _allocPoint;
        poolInfo.push(
            PoolInfo({
                lpToken: _lpToken,
                allocPoint: _allocPoint,
                lastRewardBlock: block.number > startBlock ? block.number : startBlock,
                accTpayPerShare: 0
            })
        );
    }

    function deposit(uint256 _pid, uint256 _amount) external {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);

        if (user.amount > 0) {
            uint256 pending = (user.amount * pool.accTpayPerShare / 1e12) - user.rewardDebt;
            if (pending > 0) {
                tpay.distributeMiningRewards(msg.sender, pending);
            }
        }

        if (_amount > 0) {
            pool.lpToken.transferFrom(msg.sender, address(this), _amount);
            user.amount += _amount;
        }

        user.rewardDebt = user.amount * pool.accTpayPerShare / 1e12;
    }

    function withdraw(uint256 _pid, uint256 _amount) external {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "Withdraw > deposit");
        updatePool(_pid);

        uint256 pending = (user.amount * pool.accTpayPerShare / 1e12) - user.rewardDebt;
        if (pending > 0) {
            tpay.distributeMiningRewards(msg.sender, pending);
        }

        if (_amount > 0) {
            user.amount -= _amount;
            pool.lpToken.transfer(msg.sender, _amount);
        }

        user.rewardDebt = user.amount * pool.accTpayPerShare / 1e12;
    }

    function emergencyWithdraw(uint256 _pid) external {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        pool.lpToken.transfer(msg.sender, user.amount);
        user.amount = 0;
        user.rewardDebt = 0;
    }

    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) return;

        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }

        uint256 multiplier = block.number - pool.lastRewardBlock;
        uint256 tpayReward = multiplier * tpayPerBlock * pool.allocPoint / totalAllocPoint;
        pool.accTpayPerShare += (tpayReward * 1e12) / lpSupply;
        pool.lastRewardBlock = block.number;
    }

    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }
}
