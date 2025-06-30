// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

// 1.通过源文件相对位置导入
// import './Yeye.sol';

// 2.通过源文件网址导入网上的合约的全局符号，例子：
import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol';

// 3. 通过npm的目录导入，例子：
// import '@openzeppelin/contracts/access/Ownable.sol';
 
// 4. 通过指定全局符号导入合约特定的全局符号，例子：
// import {Yeye} from './Yeye.sol';

contract Import {
    using Address for address;
}