// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

// 哈希函数（hash function）是一个密码学概念，它可以将任意长度的消息转换为一个固定长度的值，这个值也称作哈希（hash）

/*
一个好的哈希函数应该具有以下几个特性：

单向性：从输入的消息到它的哈希的正向运算简单且唯一确定，而反过来非常难，只能靠暴力枚举。
灵敏性：输入的消息改变一点对它的哈希改变很大。
高效性：从输入的消息到哈希的运算高效。
均一性：每个哈希值被取到的概率应该基本相等。
抗碰撞性：
    弱抗碰撞性：给定一个消息x，找到另一个消息x'，使得hash(x) = hash(x')是困难的。
    强抗碰撞性：找到任意x和x'，使得hash(x) = hash(x')是困难的
*/

contract HelloHash {
    
    function hash(
        uint _num,
        string memory _string,
        address _addr
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_num, _string, _addr));
    }
}