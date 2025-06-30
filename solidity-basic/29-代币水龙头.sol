// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "./28-ERC20/IERC20.sol";
import "./28-ERC20/ERC20.sol";

// 代币水龙头就是让用户免费领代币的网站/应用。

// 1. 账户A<管理员> 将数量N单位的 erc20模拟币 转到 水龙头合约Faucet
// 2. 普通用户是无法知晓 管理员地址的, 因此 账户A 直接转账 普通用户

contract Faucet {
    uint public amountAllowed = 100; // 每次领取100单位代币
    address public tokenContract;    // 发放代币合约地址
    mapping(address => bool) public requestedAddress; // 记录领取过代币的地址

    event SendToken(address indexed Receiver, uint indexed Amount);

    constructor(address _tokenContract) {
        tokenContract = _tokenContract;
    }

    function requestTokens() external {
        require(!requestedAddress[msg.sender], "Cint't Request Multiple Times!");
        // 接口实例化只需要合约地址​​，不会重新调用构造函数
        IERC20 token = IERC20(tokenContract);
        require(token.balanceOf(address(this)) >= amountAllowed, "Faucet Empty!"); // 水龙头空了

        token.transfer(msg.sender, amountAllowed); // 发送token
        requestedAddress[msg.sender] = true; // 记录领取地址 
        
        emit SendToken(msg.sender, amountAllowed);
    }
}