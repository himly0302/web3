// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;


// ABI (Application Binary Interface，应用二进制接口)是与以太坊智能合约交互的标准。
// 数据基于他们的类型编码；并且由于编码后不包含类型信息，解码时需要注明它们的类型。

contract HelloAbi {
    uint x = 10;
    address addr = 0x7A58c0Be72BE218B41C608b7Fe7C5bB630736C71;
    string name = "0xAA";
    uint[2] array = [5, 6];

    // ABI被设计出来跟智能合约交互，他将每个参数填充为32字节的数据，并拼接在一起。
    // 和合约交互，要用的就是abi.encode
    function encode() public view returns (bytes memory result) {
        result = abi.encode(x, addr, name, array);
    }

    // 将给定参数根据其所需最低空间编码。类似 abi.encode，但是会把其中填充的很多0省略。
    // 省空间，并且不与合约交互的时候.
    // 因为不会做填充，所以不同的输入在拼接后可能会产生相同的编码结果，导致冲突，这也带来了潜在的安全风险。
    function encodePacked() public view returns(bytes memory result) {
        result = abi.encodePacked(x, addr, name, array);
    }

    // 第一个参数为函数签名。当调用其他合约的时候可以使用。
    function encodeWithSignature() public view returns(bytes memory result) {
        result = abi.encodeWithSignature("foo(uint256,address,string,uint256[2])", x, addr, name, array);
    }

    // 第一个参数为函数选择器(为函数签名Keccak哈希的前4个字节)
    function encodeWithSelector() public view returns(bytes memory result) {
        result = abi.encodeWithSelector(bytes4(keccak256("foo(uint256,address,string,uint256[2])")), x, addr, name, array);
    }

    // 用于解码abi.encode生成的二进制编码，将它还原成原本的参数。
    function decode(bytes calldata data) public pure returns(uint dx, address daddr, string memory dname, uint[2] memory darray) {
        (dx, daddr, dname, darray) = abi.decode(data, (uint, address, string, uint[2]));
    }
    
}