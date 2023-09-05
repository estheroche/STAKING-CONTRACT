// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Staking {
    using SafeMath for uint256;

    IERC20 public wbnb = IERC20(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    uint256 public rewardRate;

    // Struct to store user's staking data
    struct StakerData {
        uint256 totalStaked;
        uint256 lastStakedTimestamp;
        uint256 reward;
    }

    mapping(address => StakerData) public stakers;

    constructor() {
        wbnb = IERC20(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
        rewardRate = 2;
    }

    function calculateReward(address user) public view returns (uint256) {
        StakerData storage staker = stakers[user];
        uint256 stakingDuration = block.timestamp.mul(60 * 60 * 30).sub(
            staker.lastStakedTimestamp
        );
        return staker.totalStaked.mul(2).div(100).mul(stakingDuration);
    }

    function stake(uint256 amount) public {
        require(amount > 0, "Amount must be greater than 0");
        require(amount != 0, " zero amount not required");
        wbnb.transferFrom(msg.sender, address(this), amount);

        // Update staker's data
        StakerData storage staker = stakers[msg.sender];
        staker.reward = staker.reward.add(calculateReward(msg.sender));
        staker.totalStaked = staker.totalStaked.add(amount);
        staker.lastStakedTimestamp = block.timestamp;
    }

    function unstake(uint256 amount) public {
        StakerData storage staker = stakers[msg.sender];
        require(staker.totalStaked >= amount, "Not enough staked tokens");

        // Update staker's data
        staker.reward = staker.reward.add(calculateReward(msg.sender));
        staker.totalStaked = staker.totalStaked.sub(amount);
        staker.lastStakedTimestamp = block.timestamp;

        wbnb.transfer(msg.sender, amount);
    }

    function claimReward() public {
        StakerData storage staker = stakers[msg.sender];
        uint256 reward = staker.reward.add(calculateReward(msg.sender));
        require(reward > 0, "No reward to claim");

        staker.reward = 0;
        staker.lastStakedTimestamp = block.timestamp;

        wbnb.transfer(msg.sender, reward);
    }
}
