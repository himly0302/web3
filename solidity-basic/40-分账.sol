// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

// 分账合约: 该合约允许将ETH按权重转给一组账户中，进行分账。
// 1. 在创建合约时定好 分账受益人 和 每人的份额；份额可以是相等，也可以是其他任意比例。
// 2. 付款不会自动转入账户，而是保存在此合约中。受益人通过调用release()函数触发实际转账。

contract PaymentSplit {
    event PayeeAdded(address account, uint256 shares); // 增加受益人事件
    event PaymentReleased(address to, uint256 amount); // 受益人提款事件
    event PaymentReceived(address from, uint256 amount); // 合约收款事件

    uint256 public totalShares; // 总份额，为shares的和。
    uint256 public totalReleased; // 总支付
    mapping(address => uint256) public shares; // 每个受益人的份额
    mapping(address => uint256) public released; // 支付给每个受益人的金额
    address[] public payees; // 受益人数组

    constructor(address[] memory _payees, uint256[] memory _shares) payable {
        require(_payees.length == _shares.length, "PaymentSplitter: payees and shares length mismatch");
        require(_payees.length > 0, "PaymentSplitter: no payees");

        for(uint256 i = 0; i < _payees.length; i++) {
            _addPayee(_payees[i], _shares[i]);
        }
    }

    // 回调函数，收到ETH
    receive() external payable { 
        emit PaymentReceived(msg.sender, msg.value);
    }

    // 为有效受益人地址_account分帐，相应的ETH直接发送到受益人地址。
    // 任何人都可以触发这个函数，但钱会打给account地址。
    function release(address payable _account) public virtual {
        require(shares[_account] > 0, "PaymentSplitter: account has no shares");
        // 计算account应得的eth
        uint256 payment = releasable(_account);
        // 应得的eth不能为0
        require(payment != 0, "PaymentSplitter: account is not due payment");

        // 更新总支付totalReleased和支付给每个受益人的金额released
        totalReleased += payment;
        released[_account] += payment;
        
        // 转账
        _account.transfer(payment);
        emit PaymentReleased(_account, payment);
    }

    // 计算一个账户能够领取的eth
    function releasable(address _account) public view returns (uint256) {
        uint256 totalReceived = address(this).balance + totalReleased;
        uint _alreadyReleased = released[_account]; // 该地址已领取的钱
        return totalReceived * shares[_account] / totalShares - _alreadyReleased;
    }


    // 新增受益人以及对应的份额
    function _addPayee(address _account, uint256 _share) private {
        require(_account != address(0), "PaymentSplitter: account is the zero address");
        require(_share > 0, "PaymentSplitter: shares are 0");
        require(shares[_account] != 0, "PaymentSplitter: account already has shares");

        payees.push(_account);
        shares[_account] = _share;
        totalShares += _share;

        emit PayeeAdded(_account, _share);
    }
}