// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "./31-ERC721/ERC721.sol";

// 以太坊使用的数字签名算法叫双椭圆曲线数字签名算法（ECDSA），基于双椭圆曲线“私钥-公钥”对的数字签名算法。它主要起到了三个作用：
// 身份认证：证明签名方是私钥的持有人。
// 不可否认：发送方不能否认发送过这个消息。
// 完整性：通过验证针对传输消息生成的数字签名，可以验证消息是否在传输过程中被篡改。

// ECDSA
// 1. 签名者利用 私钥 对 消息 创建 签名
// 2. 其他人使用 以太坊签名消息 和 签名 恢复签名者的 公钥, 并验证。

// 私钥(隐私): 0x227dbb8586117d55284e26620bc76534dfbd2394be34cf4a09cb775d593b6f2b
// 公钥(公开，账户地址): 0xe16C1623c1AA7D919cd2241d8b36d9E79C1Be2A2
// 消息(公开): 0x1bf2c0ce4546651a1a2feb457b39d891a6b83931cc2454434f39961345ac378c
// 以太坊签名消息(公开): 0xb42ca4636f721c7a331923e764587e98ec577cea1a185f60dfcc14dbb9bd900b
// 签名(公开): 0x390d704d7ab732ce034203599ee93dd5d3cb0d4d1d7c600ac11726659489773d559b12d220f99f41d17651b0c1c6a669d346a397f8541760d6b32a5725378b241c


// 签名(私钥加密数据）是链下的，不需要gas，因此这种白名单发放模式比Merkle Tree模式还要经济
// 用户要请求中心化接口去获取签名，不可避免的牺牲了一部分去中心化；但是有一个好处是白名单可以动态变化，而不是提前写死在合约里面了

library ECDSA {
    // 对比公钥并验证签名
    // 通过 以太坊签名消息 和 签名 获取公钥; 
    // 与签名者公钥_signer是否相等：若相等，则签名有效；否则，签名无效：
    function verify(bytes32 _msgHash, bytes memory _signature, address _signer) internal pure returns (bool) {
        return recoverSigner(_msgHash, _signature) == _signer;
    }

    // 通过 签名和以太坊签名消息 恢复公钥(用户地址)
    function recoverSigner(bytes32 _msgHash, bytes memory _signature) internal pure returns (address) {
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
        // 使用ecrecover(全局函数)：利用 msgHash 和 r,s,v 恢复 signer 地址
        return ecrecover(_msgHash, v, r, s);
    }

    // 计算以太坊签名消息
    // 因为消息可以是能被执行的交易，也可以是其他任何形式。
    // 为了避免用户误签了恶意交易，EIP191提倡在消息前加上"\x19Ethereum Signed Message:\n32"字符，并再做一次keccak256哈希，作为以太坊签名消息。
    function toEthSignedMessageHash(bytes32 hash) public pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}

contract SignatureNFT is ERC721 {
    address immutable public signer; // 签名地址
    mapping(address => bool) public mintedAddress;   // 记录已经mint的地址

    // 构造函数，初始化NFT合集的名称、代号、签名地址
    constructor(string memory _name, string memory _symbol, address _signer)
    ERC721(_name, _symbol)
    {
        signer = _signer;
    }

    // 打包消息
    // 在以太坊的ECDSA标准中，需要签名的消息 必须是一组数据的keccak256哈希，为bytes32类型。
    function getMessageHash(address _account, uint256 _tokenId) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_account, _tokenId));
    }

    function verify(bytes32 _msgHash, bytes memory _signature) public view returns (bool) {
        return ECDSA.verify(_msgHash, _signature, signer);
    }

    // 铸币
    // 消息 包含  _account 和 _tokenId 这两个数据
    // _signature 消息被私钥加密后的签名
    function mint(address _account, uint256 _tokenId, bytes memory _signature) external {
        bytes32 _msgHash = getMessageHash(_account, _tokenId); // 消息
        bytes32 _ethSignedMessageHash = ECDSA.toEthSignedMessageHash(_msgHash); // 以太坊签名消息

        // 验证公钥
        require(verify(_ethSignedMessageHash, _signature), "Invalid signature");
        require(!mintedAddress[_account], "Already minted!");

        _mint(_account, _tokenId);
        mintedAddress[_account] = true;
    }
}