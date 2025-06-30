// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

/*
// create  => 新地址 = hash(创建者地址, nonce)
创建者的地址(通常为部署的钱包地址或者合约地址)和nonce(该地址发送交易的总数,对于合约账户是创建的合约总数,每创建一个合约nonce+1)的哈希。
创建者地址不会变，但nonce可能会随时间而改变，因此用CREATE创建的合约地址不好预测。

// create2 => 新地址 = hash("0xFF",创建者地址, salt, initcode)
0xFF：一个常数，避免和CREATE冲突
salt（盐）：一个创建者指定的bytes32类型的值，它的主要目的是用来影响新创建的合约的地址。
initcode: 新合约的初始字节码（合约的Creation Code和构造函数的参数）。

注: create2使智能合约部署在以太坊网络之前就能预测合约的地址，为了让合约地址独立于未来的事件。

// create2 实际应用场景
1. 交易所为新用户预留创建钱包合约地址。
2. 可以得到一个确定的pair地址, 使得 Router中就可以通过 (tokenA, tokenB) 计算出pair地址, 不再需要执行一次 Factory.getPair(tokenA, tokenB) 的跨合约调用。
*/

contract Pair{
    address public factory; // 工厂合约地址
    address public token0; // 代币1
    address public token1; // 代币2

    constructor() payable {
        factory = msg.sender;
    }

    // called once by the factory at time of deployment
    function initialize(address _token0, address _token1) external {
        require(msg.sender == factory, 'UniswapV2: FORBIDDEN'); // sufficient check
        token0 = _token0;
        token1 = _token1;
    }
}

contract PairFactory{
    mapping(address => mapping(address => address)) public getPair; // 通过两个代币地址查Pair地址
    address[] public allPairs; // 保存所有Pair地址

    function createPair(address tokenA, address tokenB) external returns (address pairAddr) {
        // ===> 创建新合约
        Pair pair = new Pair(); 
        // 调用新合约的initialize方法
        pair.initialize(tokenA, tokenB);
        // 更新地址map
        pairAddr = address(pair);
        allPairs.push(pairAddr);
        getPair[tokenA][tokenB] = pairAddr;
        getPair[tokenB][tokenA] = pairAddr;
    }

    function createPair2(address tokenA, address tokenB) external returns (address pairAddr) {
        require(tokenA != tokenB, 'IDENTICAL_ADDRESSES'); //避免tokenA和tokenB相同产生的冲突
        // 用tokenA和tokenB地址计算salt
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA); //将tokenA和tokenB按大小排序
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        // ===> 用create2部署新合约
        Pair pair = new Pair{salt: salt}(); 
        // 调用新合约的initialize方法
        pair.initialize(tokenA, tokenB);
        // 更新地址map
        pairAddr = address(pair);
        allPairs.push(pairAddr);
        getPair[tokenA][tokenB] = pairAddr;
        getPair[tokenB][tokenA] = pairAddr;
    }

    // 事先计算Pair合约的地址
    function calculateAddr(address tokenA, address tokenB) public view returns(address predictedAddress){
        require(tokenA != tokenB, 'IDENTICAL_ADDRESSES'); //避免tokenA和tokenB相同产生的冲突
        // 计算用tokenA和tokenB地址计算salt
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA); //将tokenA和tokenB按大小排序
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        // 计算合约地址方法 hash()
        predictedAddress = address(uint160(uint(keccak256(abi.encodePacked(
            bytes1(0xff),
            address(this),
            salt,
            keccak256(type(Pair).creationCode)
            )))));
    }
}
