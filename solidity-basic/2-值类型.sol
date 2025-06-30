// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract HelloWeb3 {
    /* 布尔型 */
    bool public _bool = true;

    /* 整型 */
    int public _int = -1; // 整数, 可以为负
    uint public _uint = 1; // 无符号整数
    uint16 public _number = 65535; // 16位无符号整数<16bit> => 最大值65535

    /* 地址类型 */
    // 普通地址（address）: 存储一个 20 字节的值（以太坊地址的大小）。
    address public _address = 0x7A58c0Be72BE218B41C608b7Fe7C5bB630736C71;
    // payable address: 比普通地址多了 transfer 和 send 两个成员方法，用于接收转账。
    address payable public _address1 = payable(_address);
    uint256 public balance = _address1.balance; // 地址类型的成员
    // _address1.transfer(1); // 合约向_address1转账1wei

    /* 字节数组 */
    // 定长字节数组: 属于值类型，数组长度在声明之后不能改变。定长字节数组最多存储 32 bytes 数据，即bytes32。
    bytes32 public _byte32 = "Msolidity"; 
    bytes1 public _byte = _byte32[0];  // _byte32数组的首元素, 即'M'
    bytes2 public _byte2 = "MA"; // bytes2 最多两个元素(每个元素都是4️个字节)
    // 不定长字节数组: 属于引用类型，数组长度在声明之后可以改变，包括 bytes 等。

    /* 枚举 */
    // 枚举（enum）是 Solidity 中用户定义的数据类型。主要用于为 uint 分配名称，使程序易于阅读和维护。
    enum ActionSet { Buy, Hold, Sell }
    ActionSet action = ActionSet.Buy; // 0
}