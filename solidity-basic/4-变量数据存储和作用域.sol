// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract HelloStorage {
    // 数据存储的位置分三类; gas成本：storage > memory > calldata
    // storage: 合约里的变量默认都是storage, 存在链上。
    // memory: 函数里的参数和临时变量，存在内存中、不上链；返回数据类型变长的情况下, 必须加memory修饰。
    // calldata: 存在内存中、不上链；calldata变量不能修改,一般用于函数参数。
    // 节省链上有限空间 和 降低gas

    function fCalldata(uint[] calldata _x) public pure returns (uint[] calldata) {
        // calldata修饰的变量，不能被修改
        // _x[0] = 3;
        return _x;
    }

    /* 赋值规则: 针对引用类型 */
    // storage(合约状态变量)赋值本地storage(函数里的)时, 会创建引用。
    // memory赋值给memory，会创建引用。
    uint[] x = [1, 2, 3];

    function fStroage() public  {
        uint[] storage XStorage = x;
        XStorage[0] = 100;
    }

    /* 变量作用域 */
    // 状态变量 数据存储在链上的变量, 所有合约内函数都可以访问，gas消耗高。
    // public private internal external 用于声明状态变量（合约顶层）的可见性，​​函数内部局部变量不能使用​​。

    // 局部变量 在函数执行中有效的变量, 存储在内存中，gas低。
    // 函数内局部变量若为动态数组（如 uint[]），​​必须显式指定数据位置​​（memory 或 storage）。

    // 全局变量 全局范围工作的变量, 是solidity预留关键字。
    function global() external view returns (address, uint) {
        address sender = msg.sender;
        uint num = block.number;
        return (sender, num);
    }

    // 以太单位
    function units() public pure returns (uint, uint, uint) {
        assert(1 wei == 1e0);  // 1
        assert(1 gwei == 1e9); // 1000000000
        assert(1 ether == 1e18);
        return (1 wei, 1 gwei, 1 ether);
    }

    // 时间单位
    function timeunits() public pure {
        assert(1 seconds == 1);
        assert(1 minutes == 60 seconds);
        assert(1 hours == 60 minutes);
        assert(1 days == 24 hours);
        assert(1 weeks == 7 days);
    }


}