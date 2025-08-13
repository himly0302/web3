// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

// 多签钱包
// 一种电子钱包，特点是交易被多个私钥持有者（多签人）授权后才能执行：例如钱包由3个多签人管理，每笔交易需要至少2人签名授权。
// 多签钱包可以防止单点故障（私钥丢失，单人作恶），更加去中心化，更加安全，被很多DAO采用。

// 多签钱包合约
// 1. 设置多签人和门槛(链上）：部署多签合约时，需要初始化多签人列表和执行门槛（至少n个多签人签名授权后，交易才能执行）。
// 2. 创建交易(链下）：一笔待授权的交易
    // to 目标合约；value 交易发送的以太坊数量；data 调用函数的选择器和参数；nonce 初始0，随着每笔成功交易递增值(防止签名重放攻击)；chainid 链id(防止不同链的签名重放攻击) 
// 3. 收集多签签名(链下)
    // 将待交易进行ABI编码并计算哈希(交易哈希)，然后让多签人签名，并拼接到一起得到打包签名。
    // 交易哈希: 0xc1b055cf8e78338db21407b425114a2e258b0318879327945b661bfdea570e66
    // 多签人A签名: 0x014db45aa753fefeca3f99c2cb38435977ebb954f779c2b6af6f6365ba4188df542031ace9bdc53c655ad2d4794667ec2495196da94204c56b1293d0fbfacbb11c
    // 多签人B签名: 0xbe2e0e6de5574b7f65cad1b7062be95e7d73fe37dd8e888cef5eb12e964ddc597395fa48df1219e7f74f48d86957f545d0fbce4eee1adfbaff6c267046ade0d81c
    // 打包签名：0x014db45aa753fefeca3f99c2cb38435977ebb954f779c2b6af6f6365ba4188df542031ace9bdc53c655ad2d4794667ec2495196da94204c56b1293d0fbfacbb11cbe2e0e6de5574b7f65cad1b7062be95e7d73fe37dd8e888cef5eb12e964ddc597395fa48df1219e7f74f48d86957f545d0fbce4eee1adfbaff6c267046ade0d81c
// 4. 调用多签合约的执行函数，验证签名并执行交易（链上）。

contract MultisigWallet {
    event ExecutionSuccess(bytes32 txHash);
    event ExecutionFailure(bytes32 txHash);

    address[] public owners; // 多签持有人数组
    mapping(address => bool) public isOwner; // 记录一个地址是否为多签
    uint256 public ownerCount; // 多签持有人数量
    uint256 public threshold; // 多签执行门槛(交易至少有n个多签人签名才能被执行)
    uint256 public nonce; // 防止签名重放攻击

    receive() external payable { }

    constructor(address[] memory _owners, uint256 _threshold) {
       _setupOwners(_owners, _threshold);
    }

    // 初始化owners, isOwner, ownerCount,threshold 
    function _setupOwners(address[] memory _owners, uint256 _threshold) internal {
        require(_threshold == 0, unicode"threshold没被初始化过");
        require(_threshold <= _owners.length, unicode"多签执行门槛 小于或等于 多签人数");
        require(_threshold >= 1, unicode"多签执行门槛至少为1");

        for(uint256 i; i < _owners.length; i++) {
            address owner = _owners[i];
            require(owner != address(0) && owner != address(this) && !isOwner[owner], unicode"多签人不能为0地址，本合约地址，不能重复");
            
            owners.push(owner);
            isOwner[owner] = true;
        }

        ownerCount = _owners.length;
        threshold = _threshold;
    } 

    // 在收集足够的多签签名后，执行交易
    // signatures 打包的签名，对应的多签地址由小到大，方便检查
    function execTransaction(address to, uint256 value, bytes memory data, bytes memory signatures) public payable virtual returns (bool success) {
        // 编译交易数据，计算哈希
        bytes32 txHash = encodeTransactionData(to, value, data, nonce, block.chainid);
        nonce++;

        checkSignatures(txHash, signatures); // 检查签名

        (success, ) = to.call{value: value}(data); // 利用call执行交易，并获取交易结果
        if (success) emit ExecutionSuccess(txHash);
        else emit ExecutionFailure(txHash);
    }

    function checkSignatures(bytes32 dataHash, bytes memory signatures) public view {
        uint256 _threshold = threshold;
        require(_threshold > 0, unicode"多签执行门槛至少为1");
        require(signatures.length >= _threshold * 65, unicode"检查签名长度足够长"); // 多签人A签名长度为65

        // 通过一个循环，检查收集的签名是否有效
        // 大概思路：
        // 1. 用ecdsa先验证签名是否有效
        // 2. 利用 currentOwner > lastOwner 确定签名来自不同多签（多签地址递增）
        // 3. 利用 isOwner[currentOwner] 确定签名者为多签持有人
        address lastOwner = address(0); 
        address currentOwner;
        uint8 v;
        bytes32 r;
        bytes32 s;
        uint256 i;
        for (i = 0; i < _threshold; i++) {
            (v, r, s) = signatureSplit(signatures, i);
            // 利用ecrecover检查签名是否有效 <以太坊签名消息 和 签名 => 公钥(账户地址)>
            currentOwner = ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", dataHash)), v, r, s);
            require(currentOwner > lastOwner && isOwner[currentOwner], "WTF5007");
            lastOwner = currentOwner;
        }
    }

    /// 将单个签名从打包的签名分离出来
    /// @param signatures 打包的多签
    /// @param pos 要读取的多签index.
    function signatureSplit(bytes memory signatures, uint256 pos) internal pure returns (uint8 v, bytes32 r, bytes32 s) {
        // 签名的格式：{bytes32 r}{bytes32 s}{uint8 v}
        assembly {
            let signaturePos := mul(0x41, pos)
            r := mload(add(signatures, add(signaturePos, 0x20)))
            s := mload(add(signatures, add(signaturePos, 0x40)))
            v := and(mload(add(signatures, add(signaturePos, 0x41))), 0xff)
        }
    }

    //  编码交易数据
    function encodeTransactionData(address to, uint256 value, bytes memory data, uint256 _nonce, uint256 chainId) public pure returns (bytes32) {
        bytes32 safeTxHash = keccak256(abi.encode(to, value, data, _nonce, chainId));
        return safeTxHash;
    }
}