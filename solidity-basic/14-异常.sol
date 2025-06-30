// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

// 在contract之外定义异常
error TransferNotOwner();
// error TransferNotOwner(address sender); // 带参数的error

contract HelloError {
    mapping(uint256 => address) _owners;

    // error 方便且高效（省gas）地向用户解释操作失败的原因，同时还可以在抛出异常的同时携带参数，帮助开发者更好地调试。
    function transferOwner1(uint256 tokenId, address newOwner) public {
        if (_owners[tokenId] != msg.sender) {
            // error必须搭配revert（回退）命令使用
            revert TransferNotOwner();
        }
        _owners[tokenId] = newOwner;
    }

    // require 唯一的缺点就是gas随着描述异常的字符串长度增加，比error命令要高。
    function transferOwner2(uint256 tokenId, address newOwner) public  {
        require(_owners[tokenId] == msg.sender, "Transfer Not Owner");
        _owners[tokenId] = newOwner;
    }

    // assert 一般用于程序员写程序debug, 当检查条件不成立的时候，就会抛出异常。
    function transferOwner3(uint256 tokenId, address newOwner) public  {
        assert(_owners[tokenId] == msg.sender);
        _owners[tokenId] = newOwner;
    }
}

// 结论：error既可以告知用户抛出异常的原因，又能省gas