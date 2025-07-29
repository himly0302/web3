// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

// 由于以太坊上所有数据都是公开透明（public）且确定性（deterministic）的，它没法像其他编程语言一样给开发者提供生成随机数的方法。

contract Random {
    // 不安全
    // 首先，block.timestamp，msg.sender和blockhash(block.number-1)这些变量都是公开的，使用者可以预测出用这些种子生成出的随机数，并挑出他们想要的随机数执行合约。
    // 其次，矿工可以操纵blockhash和block.timestamp，使得生成的随机数符合他的利益。
    function getRandomOnchain() public view returns(uint256){
        // remix运行blockhash会报错
        bytes32 randomBytes = keccak256(abi.encodePacked(block.timestamp, msg.sender, blockhash(block.number-1)));
        return uint256(randomBytes);
    }
}

