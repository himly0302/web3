// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract HelloEvent {
    // 事件 EVM上日志的抽象
    // 响应：应用程序（ethers.js）可以通过RPC接口订阅和监听这些事件，并在前端做响应。
    // 经济：事件是EVM上比较经济的存储数据的方式，每个大概消耗2,000 gas；相比之下，链上存储一个新变量至少需要20,000 gas。

    mapping(address => uint256) public  _balances;

    // 事件声明 由event关键字开头，接着是事件名称，括号里面写好事件需要记录的变量类型和变量名。
    // indexed标记的参数可以理解为检索事件的索引“键”，方便之后搜索。每个 indexed 参数的大小为固定的256比特，如果参数太大了（比如字符串），就会自动计算哈希存储在主题中。
    // 对于非值类型的参数（如arrays, bytes, strings）, Solidity不会直接存储，而是会将Keccak-256哈希存储在主题中，从而导致数据信息的丢失。这对于某些依赖于链上事件的DAPP（跨链，用户注册等等）来说，可能会导致事件检索困难，需要解析哈希值。

    // 事件中不带 indexed的参数会被存储在 data 部分中，可以理解为事件的“值”。data 部分的变量不能被直接检索，但可以存储任意大小的数据。
    // data 部分的变量在存储上消耗的gas相比于 topics 更少。
    event Transfer(address indexed from, address indexed to, uint256 value);

    // 在函数里释放事件
    function _transfer(address from, address to, uint256 amount) external {
        _balances[from] = 10000000; // 给转账地址一些初始代币

        _balances[from] -=  amount; // from地址减去转账数量
        _balances[to] += amount; // to地址加上转账数量

        // 释放事件
        emit Transfer(from, to, amount);
    }
}

// EVM日志 Log
// 以太坊虚拟机（EVM）用日志Log来存储Solidity事件，每条日志记录都包含主题topics和数据data两部分。

// 256bit = 32byte
// 1byte = 8bit
// 16进制数 = 4bit
// 256bit 等于 64个16进制数