// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import './28-ERC20/ERC20.sol';

// 代币锁: 一种简单的时间锁合约，它可以把合约中的代币锁仓一段时间，受益人在锁仓期满后可以取走代币。
// 代币锁 一般是用来锁仓流动性提供者LP代币的。

// 什么是LP代币？
// 区块链中，用户在去中心化交易所(DEX)上交易代币. 去中心化交易所使用自动做市商(AMM)机制，需要用户或项目方提供资金池，以使得其他用户能够即时买卖。
// 简单来说，用户/项目方需要质押相应的币对（比如ETH/DAI）到资金池中，作为补偿，DEX会给他们铸造相应的流动性LP代币凭证，证明他们质押了相应的份额，供他们收取手续费。

// 为什么要锁定流动性？
// 如果项目方毫无征兆的撤出流动性池中的LP代币，那么投资者手中的代币就无法变现，直接归零了,这种行为也叫rug-pull。
// 如果LP代币是锁仓在代币锁合约中，在锁仓期结束以前，项目方无法撤出流动性池，也没办法rug pull。
// 因此代币锁可以防止项目方过早跑路

// 代币锁合约
// 1.开发者在部署合约时规定锁仓的时间，受益人地址，以及代币合约。
// 2.开发者将代币转入TokenLocker合约。
// 3.在锁仓期满，受益人可以取走合约里的代币。

contract TokenLocker {

    // 事件
    event TokenLockStart(address indexed beneficiary, address indexed token, uint256 startTime, uint256 lockTime);
    event Release(address indexed beneficiary, address indexed token, uint256 releaseTime, uint256 amount);

    IERC20 public immutable token; // 被锁仓的ERC20代币合约
    address public immutable beneficiary; // 受益人地址
    uint256 public immutable lockTime; // 锁仓时间(秒)
    uint256 public immutable startTime; // 锁仓起始时间戳(秒)

    constructor(IERC20 _token, address _beneficiary, uint256 _lockTime) {
        require(_lockTime > 0, "TokenLock: lock time should greater than 0");
        token = _token;
        beneficiary = _beneficiary;
        lockTime = _lockTime;
        startTime = block.timestamp;

        emit TokenLockStart(_beneficiary, address(_token), block.timestamp, _lockTime);
    }

    // 在锁仓时间过后，将代币释放给受益人。
    function release() public {
        require(block.timestamp >= startTime + lockTime, "TokenLock: current time is before release time");

        uint256 amount = token.balanceOf(address(this));
        require(amount > 0, "TokenLock: no tokens to release");

        token.transfer(beneficiary, amount);

        emit Release(beneficiary, address(token), block.timestamp, amount);
    }
}