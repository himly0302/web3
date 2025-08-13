// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

// 透明代理 通过限制管理员调用逻辑合约解决“选择器冲突”问题。
// 1. 管理员变为工具人，仅能调用代理合约的可升级函数对合约升级，不能通过回调函数调用逻辑合约。
// 2. 其它用户不能调用可升级函数，但是可以调用逻辑合约的函数。

// 缺点 每次用户调用函数时，都会多一步是否为管理员的检查，消耗更多gas。但瑕不掩瑜，透明代理仍是大多数项目方选择的方案。


// 选择器冲突
// 在智能合约中，函数选择器 是 函数签名的哈希前4个字节。范围很小，因此两个不同的函数可能会有相同的选择器。
// 下例 合约Foo无法通过编译，因为EVM无法通过函数选择器分辨用户调用哪个函数
contract Foo {
    bytes4 public selector1 = bytes4(keccak256("burn(uint256)")); 
    bytes4 public selector2 = bytes4(keccak256("collate_propagate_storage(bytes16)")); 

    // function burn(uint256) external {}
    // function collate_propagate_storage(bytes16) external {}
}


// 透明可升级合约的教学代码，不要用于生产。
contract TransparentProxy {
    address implementation; // logic合约地址
    address admin; // 管理员
    string public words; // 字符串，可以通过逻辑合约的函数改变

    // 构造函数，初始化admin和逻辑合约地址
    constructor(address _implementation){
        admin = msg.sender;
        implementation = _implementation;
    }

    receive() external payable { }
    // fallback函数，将调用委托给逻辑合约
    // 不能被admin调用，避免选择器冲突引发意外
    fallback() external payable {
        require(msg.sender != admin);
        (bool success, bytes memory data) = implementation.delegatecall(msg.data);
    }

    // 升级函数，改变逻辑合约地址，只能由admin调用
    function upgrade(address newImplementation) external {
        if (msg.sender != admin) revert();
        implementation = newImplementation;
    }
}

contract Logic1 {
    // 状态变量和proxy合约一致，防止插槽冲突
    address public implementation; 
    address public admin; 
    string public words; // 字符串，可以通过逻辑合约的函数改变

    // 改变proxy中状态变量，选择器： 0xc2985578
    function foo() public{
        words = "old";
    }
}