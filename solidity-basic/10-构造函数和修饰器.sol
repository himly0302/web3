// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract HelloCon {
    // 构造函数 是一种特殊的函数，每个合约可以定义一个，并在部署合约的时候自动运行一次。
    // 它可以用来初始化合约的一些参数
    address public owner;

    constructor(address initOwner) {
        owner = initOwner;
    }

    // 修饰器（modifier）是Solidity特有的语法，声明函数拥有的特性，并减少代码冗余。
    // modifier的主要使用场景是运行函数前的检查，例如地址，变量，余额等。
    modifier onlyOwner {
        require(msg.sender == owner); // 检查调用者是否为owner地址
        _; // 如果是的话，继续运行函数主体；否则报错并revert交易
    }

    function changeOwner(address _newOwner) external onlyOwner {
        owner = _newOwner;
    }
}