// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

// [推荐使用模版]https://github.com/OpenZeppelin/openzeppelin-contracts/tree/master/contracts/proxy

// solidity 合约部署在链上后，代码是不可变的。
// 优点：安全，用户知道会发生什么。
// 缺点：如果合约存在缺陷，也不能修改或升级，只能部署新合约。但是新合约的地址与旧的不一样，且合约的数据也需要花费大量gas进行迁移。
// 通过代理模式可以在合约部署后进行修改或升级。

// 代理模式
// 将合约数据和逻辑分开，分别保存在不同合约中；数据（状态变量）存储在代理合约中，而逻辑（函数）保存在另一个逻辑合约中。

// 可升级：当我们需要升级合约的逻辑时，只需要将代理合约指向新的逻辑合约。
// 省gas：如果多个合约复用一套逻辑，我们只需部署一个逻辑合约，然后再部署多个只保存数据的代理合约，指向逻辑合约。

// caller -> proxy -> impl

/** 
代理合约（Proxy）通过delegatecall，将函数调用全权委托给逻辑合约（Implementation）执行，再把最终的结果返回给调用者（Caller）。
*/
contract Proxy {
    // 逻辑合约同一个位置的状态变量类型必须和Proxy合约的相同，不然会报错。
    address public implementation; // 逻辑合约地址。

    constructor(address _implementation) {
        implementation = _implementation;
    }

    receive() external payable { }
    // 将本合约的调用委托给 逻辑合约
    // 如果调用合约中不存在的函数, 则会走fallback
    fallback() external payable { 
        _delegate();
    }

    function _delegate() internal {
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // 读取位置为0的storage，也就是implementation地址。
            let _implementation := sload(0)

            calldatacopy(0, 0, calldatasize())

            // 利用delegatecall调用implementation合约
            // delegatecall操作码的参数分别为：gas, 目标合约地址，input mem起始位置，input mem长度，output area mem起始位置，output area mem长度
            // output area起始位置和长度位置，所以设为0
            // delegatecall成功返回1，失败返回0
            let result := delegatecall(gas(), _implementation, 0, calldatasize(), 0, 0)

            // 将起始位置为0，长度为returndatasize()的returndata复制到mem位置0
            returndatacopy(0, 0, returndatasize())

            switch result
            // 如果delegate call失败，revert
            case 0 {
                revert(0, returndatasize())
            }
            // 如果delegate call成功，返回mem起始位置为0，长度为returndatasize()的数据（格式为bytes）
            default {
                return(0, returndatasize())
            }
        }
    }
}

/*
逻辑合约
*/
contract Logic {
    address public implementation; // 与Proxy保持一致，防止插槽冲突
    uint public x = 99;
    event CallSuccess(address sender);

    function increment() external returns(uint) {
        emit CallSuccess(msg.sender);
        return x + 1;
    }
}

/*
调用代理合约，并获取执行结果
*/
contract Caller {
    address public proxy; // 代理合约地址

    constructor(address _proxy) {
        proxy = _proxy;
    }

    // 通过代理合约调用 increase()函数
    function increase() external returns(uint) {
        ( , bytes memory data) = proxy.call(abi.encodeWithSignature("increment()"));
        return abi.decode(data,(uint));
    }
}
