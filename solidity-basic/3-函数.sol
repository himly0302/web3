// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract HelloFunc {

    uint256 public number = 5;

    /* view pure 函数权限*/

    // 读取、修改 合约中的状态变量
    function add() external {
        number = number + 1;
    }
    // pure 不能读取、修改变量 => 只能返回新变量
    function addPure(uint256 _number) external pure returns (uint256 new_number) {
        new_number = _number + 1;
    }
    // view 只能读取，不能修改 => 返回新变量
    function addView() external view returns (uint256 new_number2) {
        new_number2 = number + 1;
    }

    /* internal external
       函数可见性 必须指定, 没有默认值
    */

    // internal 内部函数
    function minus() internal {
        number = number - 1;
    }
    // external 合约内的函数 可以调用内部函数
    function minusCall() external {
        minus();
    }

    /* payable: 递钱，能给合约支付eth的函数 */

    function minusPayable() external payable returns (uint256 balance) {
        minus();
        // this.minusCall();
        // this 引用合约地址
        balance = address(this).balance;
    }

    /* return returns */
    function returnMul() public pure returns (uint256, bool, uint256[3] memory) {
        // 因为[1,2,3]会默认为uint8(3)，因此[uint256(1),2,5]中首个元素必须强转uint256来声明该数组内的元素皆为此类型。
        return (1, true, [uint256(1), 3, 5]);
    }

    // 命名返回
    function returnNamed() public pure returns (uint256 _number, bool _bool, uint256[3] memory _array) {
        // _number = 2;
        // _bool = true;
        // _array = [uint256(1), 3, 5];
        return (2, false, [uint256(1), 3, 5]);
    }

    // 解构赋值: 解构赋值不能直接写在合约顶层
    function assignValues() public pure {
        uint256 _number;
        bool _bool;
        uint256[3] memory _array;
        (_number, _bool, _array) = returnNamed();

        (, _bool,) = returnNamed();
    }
}