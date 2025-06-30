// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract HelloConst {
    // constant（常量）和immutable（不变量）。状态变量声明这两个关键字之后，不能在初始化后再更改数值。
    // 只有数值变量可以声明constant和immutable; string和bytes可以声明为constant，但不能为immutable
    // mapping(uint => address) immutable units;


    // constant 变量必须在声明的时候初始化，之后再也不能改变。
    uint256 public constant CONSTANT_NUM = 10;
    string constant CONSTANT_STRING = "0xAA";
    bytes constant CONSTANT_BYTES = "WTF";

    // immutable 变量可以在声明时或构造函数中初始化。
    // 若immutable变量既在声明时初始化，又在constructor中初始化，会使用constructor初始化的值。
    uint256 public immutable IMMUTABLE_NUM = 9999999999;
    address public immutable IMMUTABLE_ADDRESS; 

    constructor(){
        IMMUTABLE_ADDRESS = address(this);
        IMMUTABLE_NUM = 1118;
    }
}