// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

// trt-catch 只能被用于external函数或public函数或创建合约时constructor（被视为external函数）的调用。
    // 只能用于外部合约调用和合约创建。
    // 如果try执行成功，返回变量必须声明，并且与返回的变量类型相同。

contract OnlyEven {
    constructor(uint a) {
        require(a != 0, "invalid number");
        assert(a != 1);
    }

    function onlyEven(uint256 b) external pure returns (bool success) {
        require(b % 2 == 0, "Ups! Reverting");
        success = true;
    }
}

contract TryCatchContract {
    // 成功event
    event SuccessEvent();

    // 失败event
    event CatchEvent(string message);
    event CatchByte(bytes data);

    // 声明合约变量
    OnlyEven even;

    constructor() {
        even = new OnlyEven(2);
    }

    function execute(uint amount) external returns (bool success) {
        // 函数有返回值 必须声明returns
        try even.onlyEven(amount) returns (bool _success) {
            // 成功情况下
            emit SuccessEvent();
            return _success;
        } catch Error(string memory reason) {
            // 不成功情况下
            emit CatchEvent(reason);
        }
    }

    // 在创建新合约中使用try-catch （合约创建被视为external call）
    // executeNew(0)会失败并释放`CatchEvent`
    // executeNew(1)会失败并释放`CatchByte`
    // executeNew(2)会成功并释放`SuccessEvent`
    function executeNew(uint a) external returns (bool success) {
        try new OnlyEven(a) returns(OnlyEven _even){
            // call成功的情况下
            emit SuccessEvent();
            success = _even.onlyEven(a);
        } catch Error(string memory reason) {
            // catch失败的 revert() 和 require()
            emit CatchEvent(reason);
        } catch (bytes memory reason) {
            // catch失败的 assert()
            emit CatchByte(reason);
        }
    }
}