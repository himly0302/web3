// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract HelloReceiveEth {
    event Received(address Sender, uint Value);
    event fallbackCalled(address Sender, uint Value, bytes Data);

    /* 接收ETH函数 receive : 在合约收到ETH转账时被调用的函数。*/
    // 一个合约最多有一个receive()函数，不需要function关键字。
    // receive()函数不能有任何的参数，不能返回任何值，必须包含external和payable。
    receive() external payable {
        // receive()最好不要执行太多的逻辑。
        // receive()最好不要执行太多的逻辑因为如果别人用send和transfer方法发送ETH的话，gas会限制在2300，receive()太复杂可能会触发Out of Gas报错；
        // 如果用call就可以自定义gas执行更复杂的逻辑
        emit Received(msg.sender, msg.value);
    }

    /* 回退函数fallback: 在调用合约不存在的函数时被触发。*/
    // fallback()声明时不需要function关键字，必须由external修饰，一般也会用payable修饰。
    fallback() external payable {
        emit fallbackCalled(msg.sender, msg.value, msg.data);
    }

    // msg.data存在 => fallback
    // msg.data不存在
        // receive函数存在 => receive
        // receive函数不存在 => fallback
}


// ### `msg.data` 是什么？
// - **完整调用数据**：`msg.data`是一个`bytes`类型的全局变量，包含**完整的调用信息**
// - **组成结构**：
//   - **函数选择器**：前4字节是函数选择器（函数签名的Keccak256哈希的前4字节）
//   - **参数数据**：剩余字节是ABI编码的参数值