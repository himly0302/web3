// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

// BTC 和 ETH这类代币都属于同质化代币，第1枚BTC与第10000枚BTC都是等价的。
// ERC721标准 来抽象非同质化的物品。

// EIP全称 Ethereum Improvement Proposals(以太坊改进建议), 是以太坊开发者社区提出的改进建议, 是一系列以编号排定的文件。
// ERC全称 Ethereum Request For Comment(以太坊意见征求稿), 用以记录以太坊上应用级的各种开发标准和协议。
    // 典型的Token标准(ERC20, ERC721)
    // 名字注册(ERC26, ERC13)
    // URI范式(ERC67)
    // Library/Package格式(EIP82)
    // 钱包格式(EIP75,EIP85)

/* ERC165 

检查一个智能合约是不是支持了ERC721，ERC1155的接口。
*/
interface IERC165 {
    /**
     * @dev 如果合约实现了查询的`interfaceId`，则返回true
     * 规则详见：https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     *
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

/* IERC721 
利用tokenId来表示特定的非同质化代币，授权或转账都要明确tokenId

每个代币都有一个tokenId作为唯一标识，每个tokenId只对应一个代币
*/
interface IERC721 is IERC165 {
    // 在转账时被释放，记录代币的发出地址from，接收地址to和tokenid
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    // 在授权时释放，记录授权地址owner，被授权地址approved和tokenid。
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    // 在批量授权时释放，记录批量授权的发出地址owner，被授权地址operator和授权与否的approved
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    // 返回某地址的NFT持有量
    function balanceOf(address owner) external view returns (uint256 balance);

    // 返回某tokenId的主人
    function ownerOf(uint256 tokenId) external view returns (address owner);

    // 安全转账 参数为转出地址from，接收地址to和tokenId
    // 如果接收方是合约地址，此合约必须实现ERC721Receiver接口
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    // 普通转账 参数为转出地址from，接收地址to和tokenId
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    // 授权另一个地址使用你的NFT
    function approve(address to, uint256 tokenId) external;

    // 将自己持有的该系列NFT批量授权给某个地址
    function setApprovalForAll(address operator, bool _approved) external;

    // 查询tokenId被批准给了哪个地址
    function getApproved(uint256 tokenId) external view returns (address operator);

    // 查询某地址的NFT是否批量授权给了另一个operator地址
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

/* IERC721Metadata
实现了3个查询metadata元数据的常用函数
*/
interface IERC721Metadata is IERC721 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function tokenURI(uint256 tokenId) external view returns (string memory);
}

/* IERC721Receiver
如果一个合约没有实现ERC721的相关函数，转入的NFT就进了黑洞，永远转不出来了。

为了防止误转账：
    1. ERC721实现了safeTransferFrom()安全转账函数，
    2. 目标合约必须实现了IERC721Receiver接口才能接收ERC721代币，不然会revert。
*/
interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

