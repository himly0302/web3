// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract ReceiveEth {
    event Log(uint amount, uint gas);
    event Log2(address send);

    // 有2个emit时, SendEth使用 transfer会revert, 使用call是正确的
    receive() external payable { 
        emit Log(msg.value, gasleft());

        // 发送者账号地址, 不是SendEth合约地址
        emit Log2(msg.sender);
    }

    // 查询合约eth余额
    function getBalance() public view returns(uint) {
        return address(this).balance;
    }
}

error SendFailed();
error CallFailed();

// 三种方法向其他合约发送ETH ：transfer()，send()和call()，其中call()是被鼓励的用法。
contract SendEth {
    // payable使得部署时 可以转eth进去
    constructor() payable {}
    receive() external payable { }

    /* transfer */
    // 1. _to是接收方地址 => 接收方地址.transfer(发送ETH数额)
    // 2. 其gas限制是2300，足够用于转账，但对方合约的fallback()或receive()函数不能实现太复杂的逻辑。
    // 3. 如果转账失败，会自动revert（回滚交易）。
    function transferETH(address payable _to, uint amount) external payable {
        _to.transfer(amount);
    }

    /* send */
    // 1. _to是接收方地址 => 接收方地址.transfer(发送ETH数额)
    // 2. 其 gas限制是2300，足够用于转账，但对方合约的fallback()或receive()函数不能实现太复杂的逻辑。
    // 3. 如果转账失败，不会revert。
    // 4. 返回值是bool，代表着转账成功或失败，需要额外代码处理一下。
    function sendETH(address payable _to, uint256 amount) external payable{
        // 处理下send的返回值，如果失败，revert交易并发送error
        bool success = _to.send(amount);
        if(!success){
            revert SendFailed();
        }
    }

    /* call */
    // 1. _to是接收方地址 => 接收方地址.call{value: 发送ETH数额}("")。
    // 2. 没有gas限制，可以支持对方合约fallback()或receive()函数实现复杂逻辑。
    // 3. 如果转账失败，不会revert。
    // 4. 返回值是(bool, bytes)，其中bool代表着转账成功或失败，需要额外代码处理一下。
    function callETH(address payable _to, uint256 amount) external payable{
        // 处理下call的返回值，如果失败，revert交易并发送error
        (bool success,) = _to.call{value: amount}("");
        if(!success){
            revert CallFailed();
        }
    }
}

// 使用优先级 call > transfer > send