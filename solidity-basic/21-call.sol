// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract OtherContract {
    uint256 private _x = 0; // 状态变量x
    // 收到eth的事件，记录amount和gas
    event Log(uint amount, uint gas);
    
    receive() external payable { }
    fallback() external payable{}

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

    // 读取x
    function getX() external view returns(uint x){
        x = _x;
    }
}


/* Call */
// 1. 官方推荐的发送ETH的方法, 触发fallback或receive函数
// 2. 调用对方合约的函数 推荐使用声明合约变量来调用函数; 但是当不知道对方合约的源代码或ABI，就没法生成合约变量；这时，仍可以通过call调用对方合约的函数。

// 调用对方合约的函数
// 1. 目标合约地址.call(字节码)
// 2. 字节码 利用结构化编码函数abi.encodeWithSignature获得 => abi.encodeWithSignature("函数签名", 逗号分隔的具体参数)
// 3. 函数签名 => "函数名（逗号分隔的参数类型）"。例如abi.encodeWithSignature("f(uint256,address)", _x, _addr)
// 4. 调用合约时可以指定交易发送的ETH数额和gas数额 => 目标合约地址.call{value:发送数额, gas:gas数额}(字节码);

contract CallContract {
    event Response(bool success, bytes data);

    function callSetX(address _addr, uint256 x) public payable {
        (bool success, bytes memory data) = _addr.call{value: msg.value}(
            abi.encodeWithSignature("setX(uint256)", x)
        );

        emit Response(success, data); 
    }

    function callGetX(address _addr) external returns(uint256){
        (bool success, bytes memory data) = _addr.call(
            abi.encodeWithSignature("getX()")
        );

        emit Response(success, data); //释放事件
        return abi.decode(data, (uint256));
    }

    function callNonExist(address _addr) external{
        // call 不存在的函数, 其实调用的目标合约fallback函数
        (bool success, bytes memory data) = _addr.call(
            abi.encodeWithSignature("foo(uint256)")
        );

        emit Response(success, data); //释放事件
    }
}

// call 是address类型的函数
// 1. 给合约发送代币 _addr.call{value:10}('')
// 2. 调用合约的方法 _addr.call(字节码) | _addr.call{value: 10}(字节码)