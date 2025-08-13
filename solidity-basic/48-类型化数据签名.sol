// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

// EIP191签名标准 给一段消息签名
// 过于简单，当签名数据比较复杂时，用户只能看到一串十六进制字符串（数据的哈希），无法核实签名内容是否与预期相符

// EIP712类型化数据签名 一种更高级、更安全的签名方法
// 会展示签名消息的原始数据，用于用户验证数据

// EIP712 一般包含链下签名（前端或脚本）和链上验证（合约）两部分

// 线下签名 
/*
1. 必须包含一个EIP712Domain部分， 包含 name、version(一般约定‘1’)、chainId、verifyingContract(验证签名的合约地址)
EIP712Domain: [{ name: "name", type: "string" }, { name: "version", type: "string" }, { name: "chainId", type: "uint256" }, { name: "verifyingContract", type: "address" }]

这些信息会在用户签名时显示，并确保只有特定链的特定合约才能验证签名。
const domain = { name: "EIP712Storage", version: "1", chainId: "1", verifyingContract: "0xf8e81D47203A594245E36C48e151709F0C19fBe8" }

2. 根据使用场景自定义一个签名的数据类型，他要与合约匹配。 举个例子：定义了一个 Storage 类型，含有两个成员：
const types = { 
    Storage: [ 
        { name: "spender", type: "address" },  // 指定了可以修改变量的调用者<公钥，账号地址>
        { name: "number", type: "uint256" }    // 指定了变量修改后的值
    ]
}

3. 创建一个 message 变量，传入要被签名的类型化数据。
const message = {
    spender: "0x5B38Da6a701c568545dCfcB03FcB875f56beddC4",
    number: "100",
};

4. 调用钱包对象的 signTypedData() 方法，传入前面步骤中的 domain，types，和 message 变量进行签名
const provider = new ethers.BrowserProvider(window.ethereum)
const signature = await signer.signTypedData(domain, types, message); // 获得signer后调用signTypedData方法进行eip712签名
console.log("Signature:", signature);
*/

// 链上验证
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract EIP712Storage {
    using ECDSA for bytes32;

    // 常量 EIP712Domain 的类型哈希
    bytes32 private constant EIP712DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
    // 常量 Storage 的类型哈希
    bytes32 private constant STORAGE_TYPEHASH = keccak256("Storage(address spender,uint256 number)");

    // 每个域(Dapp)的唯一值，由 EIP712DOMAIN_TYPEHASH 以及 EIP712Domain组成，在 constructor() 中初始化
    bytes32 private DOMAIN_SEPARATOR;
    // 合约中存储值的状态变量
    uint256 number;
    // 合约所有者
    address owner;

    constructor() {
        DOMAIN_SEPARATOR = keccak256(abi.encode(
            EIP712DOMAIN_TYPEHASH, // type hash
            keccak256(bytes("EIP712Storage")), // domain name
            keccak256(bytes("1")), // domain version
            block.chainid,
            address(this)
        ));

        owner = msg.sender;
    }

    // 验证 EIP712 签名，并修改 number 的值。
    function permitStore(uint256 _num, bytes memory _signature) public {
        // 检查签名长度，65是标准r,s,v签名的长度
        require(_signature.length == 65, "invalid signature length");
        bytes32 r;
        bytes32 s;
        uint8 v;
        // 目前只能用assembly (内联汇编)来从签名中获得r,s,v的值
        assembly {
            /*
            前32 bytes存储签名的长度 (动态数组存储规则)
            add(sig, 32) = sig的指针 + 32
            等效为略过signature的前32 bytes
            mload(p) 载入从内存地址p起始的接下来32 bytes数据
            */
            // 读取长度数据后的32 bytes
            r := mload(add(_signature, 0x20))
            // 读取之后的32 bytes
            s := mload(add(_signature, 0x40))
            // 读取最后一个byte
            v := byte(0, mload(add(_signature, 0x60)))
        }

        // 获取签名消息hash
        bytes32 digest = keccak256(abi.encodePacked(
            "\x19\x01",
            DOMAIN_SEPARATOR,
            keccak256(abi.encode(STORAGE_TYPEHASH, msg.sender, _num))
        )); 
        
        address signer = digest.recover(v, r, s); // 恢复签名者
        require(signer == owner, "EIP712Storage: Invalid signature"); // 检查签名

        // 修改状态变量
        number = _num;
    }

    // 读取 number 的值
    function retrieve() public view returns (uint256){
        return number;
    }    
}