// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract HelloInit {
    // 声明但没赋值的变量都有它的初始值或默认值。

    // 值类型初始值
    bool public _bool; // false
    string public _string; // ""
    int public _int; // 0
    uint public _uint; // 0
    address public _address; // 0x0000000000000000000000000000000000000000

    enum ActionSet { Buy, Hold, Sell}
    ActionSet public _enum; // 第1个内容Buy的索引0

    function fi() internal{} // internal空白函数
    function fe() external{} // external空白函数

    // 引用类型初始值
    uint[8] public _staticArray; // 所有成员设为其默认值的静态数组[0,0,0,0,0,0,0,0]
    uint[] public _dynamicArray; // `[]`
    mapping(uint => address) public _mapping; // 所有元素都为其默认值的mapping
    // 所有成员设为其默认值的结构体 0, 0
    struct Student{
        uint256 id;
        uint256 score; 
    }
    Student public student;

    // delete 会让变量的值变为初始值
    bool public  _bool2 = true;
    function d() public {
        delete _bool2;
    }
}