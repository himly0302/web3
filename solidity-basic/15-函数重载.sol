// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract HelloFuncReload {
    // 函数重载 名字相同但输入参数类型不同的函数可以同时存在，他们被视为不同的函数。
    // 注意，Solidity不允许修饰器（modifier）重载。

    function say() public pure returns (string memory) {
        return  ("Nothing");
    }
    function say(string memory smthing) public pure returns (string memory) {
        return (smthing);
    } 

    /* 实参匹配 */
    // 在调用重载函数时，会把输入的实际参数和函数参数的变量类型做匹配。 如果出现多个匹配的重载函数，则会报错。
    function f(uint8 _in) public pure returns (uint8 out) {
        out = _in;
    }
    function f(uint256 _in) public pure returns (uint256 out) {
        out = _in;
    }
}