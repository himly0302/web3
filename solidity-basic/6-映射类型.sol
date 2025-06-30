// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract HelloMapping {
    // 映射 mapping(_KeyType => _ValueType)，其中_KeyType和_ValueType分别是Key和Value的变量类型。
    // 规则1: 映射的_KeyType只能选择Solidity内置的值类型，比如uint，address等，不能用自定义的结构体。
    // 规则2: 映射的存储位置必须是storage，因此可以用于合约的状态变量，函数中的storage变量和library函数的参数.
    // 规则3：如果映射声明为public，那么Solidity会自动给你创建一个getter函数，可以通过Key来查询对应的Value。
    // 规则4：给映射新增的键值对的语法为_Var[_Key] = _Value，其中_Var是映射变量名，_Key和_Value对应新增的键值对。
    mapping(uint => address) public idToAdress;

    function writeMap(uint _Key, address _Value) public {
        idToAdress[_Key] = _Value;
        // address _address = idToAdress[_Key];
    }

    // 原理
    // 原理1: 映射不储存任何键（Key）的资讯，也没有length的资讯。
    // 原理2: 对于映射使用keccak256(h(key).slot)计算存取value的位置。
    // 原理3: 因为Ethereum会定义所有未使用的空间为0，所以未赋值（Value）的键（Key）初始值都是各个type的默认值，如uint的默认值是0。
}