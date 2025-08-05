// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import './28-ERC20/ERC20.sol';

// 线性释放: 代币在归属期内匀速释放。
// 项目方规定线性释放的起始时间、归属期和受益人。
// 项目方将锁仓的ERC20代币转账给TokenVesting合约。
// 受益人可以调用release函数，从合约中取出释放的代币。

contract TokenVesting {
    // 事件
    event ERC20Released(address indexed token, uint256 amount);

    mapping(address => uint256) public erc20Released; // 代币地址 -> 释放数量(记录受益人已领取的代币数量)
    address public immutable beneficiary; //  受益人地址
    uint256 public immutable start; // 归属期起始时间戳
    uint256 public immutable duration; // 归属期 (秒)

    constructor(address beneficiaryAdress, uint256 durationSeconds) {
        require(beneficiaryAdress != address(0), "VestingWallet: beneficiary is zero address");

        beneficiary = beneficiaryAdress;
        duration = durationSeconds;
    }

    // 受益人提取已释放的代币
    function release(address token) public {
        uint256 releasable = vestedAmount(token, block.timestamp) - erc20Released[token]; // 计算可提取的代币数量
        erc20Released[token] += releasable;

        emit ERC20Released(token, releasable);
        IERC20(token).transfer(beneficiary, releasable);
    }

    // 根据线性释放公式，计算已经释放的数量。
    // 开发者可以通过修改这个函数，自定义释放方式。
    function vestedAmount(address token, uint256 timestamp) public view returns (uint256)  {
        uint256 totalAll = ERC20(token).balanceOf(address(this)) + erc20Released[token];
        if (timestamp < start) {
            return 0;
        } else if (timestamp > start + duration) {
            return totalAll;
        } else {
            return totalAll * (timestamp - start) / duration;
        }
    }
}