// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

// 时间锁：是一段代码，可以将智能合约的某些功能锁定一段时间(可以大大改善智能合约的安全性)。
// 在区块链，时间锁被DeFi和DAO大量采用。
// 举个例子，假如一个黑客黑了Uniswap的多签，准备提走金库的钱，但金库合约加了2天锁定期的时间锁，那么黑客从创建提钱的交易，到实际把钱提走，需要2天的等待期。在这一段时间，项目方可以找应对办法，投资者可以提前抛售代币减少损失。

// 时间锁合约
// 在创建合约时，项目方可以设定锁定期，并把合约的管理员设为自己。
// 时间锁主要有三个功能
// 1. 创建交易，并加入到时间锁队列
// 2. 在交易的锁定期满后，执行交易
// 3. 后悔了，取消时间锁队列中的某些交易
// 项目方一般会把时间锁合约设为重要合约的管理员
// 时间锁合约的管理员一般为项目的多签钱包，保证去中心化。

contract TimeLock {
    // 事件
    event QueueTransaction(bytes32 indexed txHash, address indexed target, uint value, string signature, bytes data, uint executeTime);   // 交易创建并进入队列 事件
    event CancelTransaction(bytes32 indexed txHash, address indexed target, uint value, string signature,  bytes data, uint executeTime); // 交易取消事件
    event ExecuteTransaction(bytes32 indexed txHash, address indexed target, uint value, string signature,  bytes data, uint executeTime);// 交易执行事件 
    event NewAdmin(address indexed newAdmin); // 修改管理员地址的 事件

    // 状态变量
    address public admin; // 管理员地址
    uint public constant GRACE_PERIOD = 7 days; // 交易有效期，过期的交易作废
    uint public delay; // 交易锁定时间(秒)
    mapping(bytes32 => bool) public queuedTransactions; // 记录所有在时间锁队列中的交易

    // 修饰器
    modifier onlyOwner() { // 被修饰的函数只能被管理员执行
        require(msg.sender == admin, "Timelock: Caller not admin");
        _;
    }
    modifier onlyTimelock() { // 被修饰的函数只能被时间锁合约执行。
        require(msg.sender == address(this), "Timelock: Caller not Timelock");
        _;
    }

    constructor(uint _delay) {
        delay = _delay;
        admin = msg.sender;
    }

    // 改变管理员地址，调用者必须是Timelock合约。
    function changeAdmin(address newAdmin) public onlyTimelock {
        admin = newAdmin;
        emit NewAdmin(newAdmin);
    }

    // 获取 交易的标识符
    function getTxHash(address target, uint256 value, string memory signature, bytes memory data, uint256 executeTime) public pure returns (bytes32) {
        return keccak256(abi.encode(target, value, signature, data, executeTime));
    }

    function getBlockTimestamp() public view returns (uint) {
        return block.timestamp;
    }

    // 创建交易 并 添加到时间锁队列中
    // target 目标合约；value 发送eth数额；signature 要调用的函数签名；data 在call data中的参数；executeTime 交易执行的区块链时间戳
    function queueTransaction(address target, uint256 value, string memory signature, bytes memory data, uint256 executeTime) public onlyOwner returns (bytes32) {
        require(executeTime > block.timestamp + delay, "Timelock::queueTransaction: Estimated execution block must satisfy delay.");
        bytes32 txHash = getTxHash(target, value, signature, data, executeTime);

        queuedTransactions[txHash] = true;

        emit QueueTransaction(txHash, target, value, signature, data, executeTime);

        return txHash;
    }

    // 取消特定交易
    function cancelTransaction(address target, uint256 value, string memory signature, bytes memory data, uint256 executeTime) public onlyOwner{
        bytes32 txHash = getTxHash(target, value, signature, data, executeTime);
        // 检查：交易在时间锁队列中
        require(queuedTransactions[txHash], "Timelock::cancelTransaction: Transaction hasn't been queued.");

        queuedTransactions[txHash] = false;

        emit CancelTransaction(txHash, target, value, signature, data, executeTime);
    }

    // 执行特定交易
    // 交易在时间锁队列中、达到交易的执行时间、交易没过期
    function executeTransaction(address target, uint256 value, string memory signature, bytes memory data, uint256 executeTime) public payable onlyOwner returns (bytes memory) {
        bytes32 txHash = getTxHash(target, value, signature, data, executeTime);
        require(queuedTransactions[txHash], "Timelock::executeTransaction: Transaction hasn't been queued.");
        require(block.timestamp >= executeTime, "Timelock::executeTransaction: Transaction hasn't surpassed time lock.");
        require(block.timestamp <= executeTime + GRACE_PERIOD, "Timelock::executeTransaction: Transaction is stale.");

        queuedTransactions[txHash] = false;

        bytes memory callData;
        if (bytes(signature).length == 0) {
            callData = data;
        } else {
            // 这里如果采用encodeWithSignature的编码方式来实现调用管理员的函数，请将参数data的类型改为address。
            // 不然会导致管理员的值变为类似"0x0000000000000000000000000000000000000020"的值。其中的0x20是代表字节数组长度的意思
            // callData = abi.encodeWithSignature(signature, data);
            callData = abi.encodePacked(bytes4(keccak256(bytes(signature))), data);
        }
        // 利用call执行交易
        (bool success, bytes memory returnData) = target.call{ value: value }(callData);
        require(success, "Timelock::executeTransaction: Transaction execution reverted.");

        emit ExecuteTransaction(txHash, target, value, signature, data, executeTime);

        return returnData;
    }
}


/**
构造更改管理员的交易。
为了构造交易，我们要分别填入以下参数： address target, uint256 value, string memory signature, bytes memory data, uint256 executeTime

target：因为调用的是Timelock自己的函数，填入合约地址。
value：不用转入ETH，这里填0。
signature：changeAdmin()的函数签名为："changeAdmin(address)"。
data：这里填要传入的参数，也就是新管理员的地址。但是要把地址填充为32字节的数据，以满足以太坊ABI编码标准。可以使用hashex网站进行参数的ABI编码。例子：
编码前地址：0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
编码后地址：0x000000000000000000000000ab8483f64d9c6d1ecf9b849ae677dd3315835cb2
executeTime：先调用getBlockTimestamp()得到当前区块链时间，再在它的基础上加个150秒填入。
*/