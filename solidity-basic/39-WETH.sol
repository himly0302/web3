// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import './28-ERC20/ERC20.sol';

// WETH 是ETH的带包装版本。为什么要包装它们？
// 因为以太币本身并不符合ERC20标准。WETH是为了提高区块链之间的互操作性 ，并使ETH可用于去中心化应用程序（dApps）。
// 就像给原生代币穿了一件智能合约做的衣服：穿上衣服的时候，就变成了WETH，符合ERC20同质化代币标准，可以跨链，可以用于dApp；脱下衣服，它可1:1兑换ETH。

// WETH 符合ERC20标准
// 存款: 包装，用户将ETH存入WETH合约，并获得等量的WETH
// 取款: 拆包装，用户销毁WETH，并获得等量的ETH

contract WETH is ERC20 {
    // 事件 
    event Deposit(address indexed dst, uint wad);
    event Withdrawal(address indexed src, uint wad);

    constructor() ERC20("WETH", "WETH") {}

    // 回调函数，当用户往WETH合约转ETH时，会触发deposit()函数
    fallback() external payable { 
        deposit();
    }

    receive() external payable { 
        deposit();
    }

    // 存款函数，当用户存入ETH时，给他铸造等量的WETH
    function deposit() public payable {
        _mint(msg.sender, msg.value);
        emit Deposit(msg.sender, msg.value);
    }

    // 提款函数，用户销毁WETH，取回等量的ETH
    function withdraw(uint amount) public {
        require(balanceOf[msg.sender] >= amount);
        _burn(msg.sender, amount);

        payable(msg.sender).transfer(amount);
        emit Withdrawal(msg.sender, amount);
    }
}