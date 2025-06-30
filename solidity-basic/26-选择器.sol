// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

// 当我们调用智能合约时，本质上是向目标合约发送了一段calldata; 例如在remix中发送一次交易后，可以在详细信息中看见input即为此次交易的calldata
// 发送的calldata中前4个字节是 selector（函数选择器）。

/* 
msg.data 

msg.data是Solidity中的一个全局变量，值为完整的calldata（调用函数时传入的数据）。
其实calldata就是告诉智能合约，我要调用哪个函数，以及参数是什么。


method id、selector

method id定义为 函数签名的Keccak哈希后的前4个字节；送的calldata中前4个字节是 selector（函数选择器）。
当selector与method id相匹配时，即表示调用该函数。
*/

contract DemoContract {
    
}


contract HelloSelector {
    event Log(bytes data);
    event SelectorEvent(bytes4 data);

    // 调用函数mint, 参数0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
    // 输出calldata为 0x6a6278420000000000000000000000005b38da6a701c568545dcfcb03fcb875f56beddc4 分成两段
    // 0x6a627842 函数选择器selector
    // 0000000000000000000000005b38da6a701c568545dcfcb03fcb875f56beddc4 后面32个字节为输入的参数
    function mint(address to) external returns (address) {
        emit Log(msg.data);
        return to;
    }

    // 计算method id => 0x6a627842; 与函数选择器一致
    function mintSelector() external pure returns(bytes4 mSelector){
        return bytes4(keccak256("transfer(address,uint256)"));
    }

    // 基础类型参数 固定长度类型参数 可变长度类型参数
    function elementaryParamSelector(uint256 param1, bool param2) external returns (bytes4) {
        emit SelectorEvent(this.elementaryParamSelector.selector);
        return bytes4(keccak256("elementaryParamSelector(uint256,bool)"));
    }

    // 映射类型参数
    struct User {
        uint256 uid;
        bytes name;
    }

    enum School { SCHOOL1, SCHOOL2 }

    function mappingParamSelector(DemoContract demo, User memory user, School mySchool) external returns(bytes4 selectorWithMappingParam){
        emit SelectorEvent(this.mappingParamSelector.selector);
        return bytes4(keccak256("mappingParamSelector(address,(uint256,bytes),uint8)"));
    }
}
