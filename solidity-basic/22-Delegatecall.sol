// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract contractB {
    event LogB(address sender, uint value);

    function callC(address _to) public payable {
        // call: 用户A 通过合约B 调用 合约C的函数
        // 在合约B中 msg.sender=A地址 msg.value=A给的值
        // 在合约C中 msg.sender=B地址 msg.value=B给的值
        (bool success, ) = _to.call(abi.encodeWithSignature("write()"));
        if (success) {
            emit LogB(msg.sender, msg.value);
        }
    }

    function delegateCallC(address _to) public payable {
        // delegatecall: 用户A 通过合约B 调用 合约C的函数
        // 在合约B中 msg.sender=A地址 msg.value=A给的值
        // 在合约C中 msg.sender=A地址 msg.value=A给的值
        (bool success, ) = _to.delegatecall(abi.encodeWithSignature("write()"));
        if (success) {
            emit LogB(msg.sender, msg.value);
        }
    }

    // 合约B和目标合约C的变量存储布局必须相同<变量名可以不一致, 变量类型、声明顺序必须相同>。
    uint public num;
    address public sender;

    function callSetVars(address _addr, uint _num) external payable {
        // call: 用户A 通过合约B 调用 合约C的函数
        // 此时 call函数语境为合约C, 修改的是合约C中的状态变量
        (bool success, ) = _addr.call(
            // 为什么参数类型必须为 uint256
            // 因为 Solidity的ABI编码要求函数签名使用​​完整的类型名称​​。uint虽然是uint256的别名，但在函数签名中必须写为uint256
            abi.encodeWithSignature("setVars(uint256)", _num)
        );
        if (success) {
            emit LogB(msg.sender, msg.value);
        }
    }

    function delegatecallSetVars(address _addr, uint _num) external payable {
        // delegatecall: 用户A 通过合约B 调用 合约C的函数
        // 此时 delegatecall函数语境为合约B, 修改的是合约B中的状态变量
        (bool success, ) = _addr.delegatecall(
            abi.encodeWithSignature("setVars(uint256)", _num)
        );
        if (success) {
            emit LogB(msg.sender, msg.value);
        }
    }
}

contract contractC {
    event LogC(address sender, uint value);

    function write() public payable {
        emit LogC(msg.sender, msg.value);
    }

    uint public num;
    address public sender;
    function setVars(uint _num) public payable {
        num = _num;
        sender = msg.sender;
    }
}

/* delegatecall 应用场景 */
// 代理合约（Proxy Contract）：将智能合约的存储合约和逻辑合约分开。
    // 代理合约（Proxy Contract）存储所有相关的变量，并且保存逻辑合约的地址。
    // 逻辑合约（Logic Contract）存在所有函数，通过delegatecall执行。
    // 当升级时，只需要将代理合约指向新的逻辑合约即可。
// EIP-2535 Diamonds（钻石）：钻石是一个支持构建可在生产中扩展的模块化智能合约系统的标准。
    // 钻石是具有多个实施合约的代理合约。 更多信息请查看：钻石标准简介。

/* delegatecall 的调用规则 */
// ​​Gas 指定​​：
    // 1. ​​可以​​通过 {gas: <amount>} 指定调用的 Gas 限额（如 addr.delegatecall{gas: 1000000}(...)）。
    // 2. 若不指定，默认传递所有剩余 Gas。
// ETH 发送​​：
    // 1. ​不可以​​附带 ETH（即不能使用 {value: <amount>}）。
    // 2. delegatecall 的语义是“借用目标合约的代码逻辑”，但​​资金操作始终在调用者合约的上下文中完成​​，因此 ETH 发送无意义且被禁止。