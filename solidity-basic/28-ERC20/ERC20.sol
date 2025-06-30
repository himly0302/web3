// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "./IERC20.sol";
// ERC20 是以太坊上的代币标准, 实现了代币转账的基本逻辑。
    // 账户余额(balanceOf())
    // 授权转账额度(allowance())
    // 转账(transfer())
    // 授权转账(transferFrom())
    // 授权(approve())
    // 代币总供给(totalSupply())
    // 代币信息（可选）：名称(name())，代号(symbol())，小数位数(decimals())


contract ERC20 is IERC20 {
    /* 
    状态变量：记录账户余额，授权额度和代币信息。
    
    Solidity会自动为public类型的mapping生成匹配的balanceOf(address)函数，因此无需手动实现。
    */
    mapping(address => uint256) public override balanceOf;
    mapping(address => mapping(address => uint256)) public override allowance;
    uint256 public override totalSupply;
    string public name;   // 名称
    string public symbol;  // 代号
    uint8 public decimals = 18; // 小数位数

    /* 函数 */
    // 部署ERC20合约​时 要​提供 名称和符号；构造函数参数仅需在部署时提供​​一次
    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }

    // 调用方扣除amount数量代币
    // 通常是另一个地址
    function transfer(address recipient, uint256 amount) external returns (bool){
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    // 被授权方spender可以支配授权方的amount数量的代币。
    // 通常是一个合约或服务
    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    // 被授权方将授权方sender的amount数量的代币转账给接收方recipient
    // A 授权 B v1数量  allowance[A][B] += v1;
    // B 要将A授权的 数量v2 进行转帐 allowance[A][B] -= v2;
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool){
        // 此处 sender 是授权方 A; 而 msg.sender 是 被授权方B
        allowance[sender][msg.sender] -= amount;
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    // 铸造代币函数，不在IERC20标准中。这里为了教程方便，任何人可以铸造任意数量的代币，实际应用中会加权限管理，只有owner可以铸造代币：
    function mint(uint amount) external {
        balanceOf[msg.sender] += amount;
        totalSupply += amount;
        emit Transfer(address(0), msg.sender, amount);
    }

    // 销毁代币函数，不在IERC20标准中
    function burn(uint amount) external {
        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }
}