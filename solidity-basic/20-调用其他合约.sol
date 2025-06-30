// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract OtherContract {
    uint256 private _x = 0; // 状态变量_x
    // 收到eth的事件，记录amount和gas
    event Log(uint amount, uint gas);
    
    // 返回合约ETH余额
    function getBalance() view public returns(uint) {
        return address(this).balance;
    }

    // 可以调整状态变量_x的函数，并且可以往合约转ETH (payable)
    function setX(uint256 x) external payable{
        _x = x;
        // 如果转入ETH，则释放Log事件
        if(msg.value > 0){
            emit Log(msg.value, gasleft());
        }
    }

    // 读取_x
    function getX() external view returns(uint x){
        x = _x;
    }
}

contract CallContract {
    // 传入合约地址
    // 1. 传入目标合约地址
    function callSetX(address _Address, uint x) external {
        // 2. 生成目标合约的引用，然后调用目标函数。
        OtherContract(_Address).setX(x);
    }

    // 传入合约变量
    // 1. 传入合约的引用
    function callGetX(OtherContract _Address) external view returns (uint x) {
        // 2. 调用目标合约的函数
        x = _Address.getX();
    }

    // 创建合约变量
    function callGetX2(address _Address) external view returns(uint x){
        // 1. 创建合约变量
        OtherContract oc = OtherContract(_Address);
        // 2. 然后通过它来调用目标函数
        x = oc.getX();
    }

    // 调用合约并发送
    function setXTransferETH(address otherContract, uint256 x) external payable {
        // 1. 目标合约的函数是payable
        // 2. _Name(_Address).f{value: _Value}()，其中_Name是合约名，_Address是合约地址，f是目标函数名，_Value是要转的ETH数额（以wei为单位）。
        OtherContract(otherContract).setX{value: msg.value}(x);
    }
}