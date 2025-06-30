// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

// 空投是加密货币行业的一种营销策略，项目方会向特定用户群体免费发放代币。项目方通过空投获得种子用户，而用户则获得一定数量的收益，实现双赢。
// 由于通常接收空投的用户数量较多，项目方逐一发送转账并不实际。通过使用智能合约批量发送 ERC20 代币，可以显著提高空投的效率。

import "./28-ERC20/IERC20.sol";
import "./28-ERC20/ERC20.sol";


// 1. 账号A 向空头合约Airdrop 授权 数量N单位的 erc20模拟币
// 2. 空头合约Airdrop 发放代币时, 必须知道给他授权的 账号A，因为真正发币的地址 是 账号A

contract Airdrop {
   mapping(address => uint) failTransferList;

    // 向多个地址转账ERC20代币，使用前需要先授权
    function multiTransferToken(address _token, address[] calldata _addresses, uint256[] calldata _amounts) external  {
        require(_addresses.length == _amounts.length, "Lengths of Addresses and Amounts NOT EQUAL");

        IERC20 token = IERC20(_token); // 声明IERC合约变量
        uint _amountSum = getSum(_amounts); // 计算空投代币总量
        
        // 检查：授权代币数量 > 空投代币总量
        require(token.allowance(msg.sender, address(this)) > _amountSum, "Need Approve ERC20 token");

        // for循环，利用transferFrom函数发送空投
        for (uint256 i; i < _addresses.length; i++) {
            token.transferFrom(msg.sender, _addresses[i], _amounts[i]);
        }
    }

    // 向多个地址转账ETH
    function multiTransferETH(
        address payable[] calldata _addresses,
        uint256[] calldata _amounts
    ) public payable {
        // 检查：_addresses和_amounts数组的长度相等
        require(
            _addresses.length == _amounts.length,
            "Lengths of Addresses and Amounts NOT EQUAL"
        );
        uint _amountSum = getSum(_amounts); // 计算空投ETH总量
        // 检查转入ETH等于空投总量
        require(msg.value == _amountSum, "Transfer amount error");
        // for循环，利用transfer函数发送ETH
        for (uint256 i = 0; i < _addresses.length; i++) {
            // 注释代码有Dos攻击风险, 并且transfer 也是不推荐写法
            // Dos攻击 具体参考 https://github.com/AmazingAng/WTF-Solidity/blob/main/S09_DoS/readme.md
            // _addresses[i].transfer(_amounts[i]);
            (bool success, ) = _addresses[i].call{value: _amounts[i]}("");
            if (!success) {
                failTransferList[_addresses[i]] = _amounts[i];
            }
        }
    }

    // 给空投失败提供主动操作机会
    function withdrawFromFailList(address _to) public {
        uint failAmount = failTransferList[msg.sender];
        require(failAmount > 0, "You are not in failed list");
        failTransferList[msg.sender] = 0;
        (bool success, ) = _to.call{value: failAmount}("");
        require(success, "Fail withdraw");
    }

    function getSum(uint256[] calldata _arr) public pure returns (uint sum) {
        for (uint i = 0; i < _arr.length; i++) sum = sum + _arr[i];
    }
}