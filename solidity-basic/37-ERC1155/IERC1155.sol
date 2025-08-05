// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import '../31-ERC721/IERC721.sol';

// ERC1155 多代币标准, 允许一个合约包含多种同质化和非同质化代币。=> 在ERC20和ERC721标准中，每个合约都对应一种独立的代币。

// 怎么区分ERC1155中的某类代币是同质化还是非同质化代币呢？
// 其实很简单：如果某个id对应的代币总量为1，那么它就是非同质化代币，类似ERC721；如果某个id对应的代币总量大于1，那么他就是同质化代币，因为这些代币都分享同一个id，类似ERC20

/*
ERC1155合约

在ERC1155中，每一种代币都有一个id作为唯一标识，每个id对应一种代币。
因此 代币种类就可以非同质的在同一个合约里管理了，并且每种代币都有一个网址uri来存储它的元数据。
*/
interface IERC1155 is IERC165 {
    
    // 单类代币转账事件
    // 当`value`个`id`种类的代币被`operator`从`from`转账到`to`时释放.
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    // 批量代币转账事件
    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);

    // 批量授权事件
    // 当`account`将所有代币授权给`operator`时释放
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    // 当`id`种类的代币的URI发生变化时释放，`value`为新的URI
    event URI(string value, uint256 indexed id);

    // 持仓查询
    // 返回`account`拥有的`id`种类的代币的持仓量
    function balanceOf(address account, uint256 id) external view returns (uint256);

    // 批量持仓查询
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);

    // 批量授权
    // 将调用者的代币授权给`operator`地址
    function setApprovalForAll(address operator, bool approved) external;

    // 批量授权查询
    // 如果地址`operator`被`account`授权，则返回`true`
    function isApprovedForAll(address account, address operator) external  view returns (bool);

    // 安全转账
    // 将`amount`单位`id`种类的代币从`from`转账给`to`
    // 如果调用者不是`from`地址而是授权地址，则需要得到`from`的授权
    // 如果接收方是合约，需要实现`IERC1155Receiver`的`onERC1155Received`方法，并返回相应的值
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;

    // 批量安全转账
    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;
}

// ERC1155 元数据
interface IERC1155MetadataURI is IERC1155  {
    function uri(uint256 id) external view returns (string memory);
}

// ERC1155 接收合约
// 为了避免代币被转入黑洞合约，ERC1155要求代币接收合约继承IERC1155Receiver并实现两个接收函数
interface IERC1155Receiver is IERC165 {
    
    // 接受ERC1155安全转账`safeTransferFrom` 
    // 需要返回 0xf23a6e61 或 `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
    function onERC1155Received(address operator, address from, uint256 id, uint256 value, bytes calldata data) external returns (bytes4);

    // 接受ERC1155批量安全转账`safeBatchTransferFrom` 
    // 需要返回 0xbc197c81 或 `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
    function onERC1155BatchReceived(address operator, address from, uint256[] calldata ids, uint256[] calldata values, bytes calldata data) external returns (bytes4);
}