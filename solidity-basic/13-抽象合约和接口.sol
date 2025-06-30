// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

/* 抽象合约 */
// 如果一个智能合约里至少有一个未实现的函数，即某个函数缺少主体{}中的内容，则必须将该合约标为abstract，不然编译会报错；
// 另外，未实现的函数需要加virtual，以便子合约重写。

abstract contract InsertionSort {
    function insertionSort(uint[] memory a) public pure virtual returns (uint[] memory); 
}

/* 接口 
1.不能包含状态变量
2.不能包含构造函数
3.不能继承除接口外的其他合约
4.所有函数都必须是external且不能有函数体
5.继承接口的非抽象合约必须实现接口定义的所有功能
*/
interface Base {
    function getFName() external pure returns (string memory);
    function getLName() external pure returns (string memory);
}

contract BaseImpl is Base {
    function getFName() external pure override  returns (string memory) {}
    function getLName() external pure override  returns (string memory) {}
}


/* type()*/

contract ContractType {
    
    function useType() external pure {
        // 1. 获取接口标识符
        bytes4 interfaceId = type(Base).interfaceId;

        // 2. 获取合约信息
        bytes memory creationCode = type(BaseImpl).creationCode; // 获取合约创建字节码
        bytes memory runtimeCode = type(BaseImpl).runtimeCode; // 获取合约运行时字节码​​
        string memory name = type(BaseImpl).name; // 获取合约名称
    }
}