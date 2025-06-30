// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "./IERC721.sol";
import "./Strings.sol";


/* ERC721
实现了IERC721，IERC165和IERC721Metadata定义的所有功能，包含4个状态变量和17个函数。
*/

contract ERC721 is IERC721, IERC721Metadata {
    using Strings for uint256;

    // IERC721Metadata name | symbol
    string public override name;
    string public override symbol;

    // IERC721
    mapping(uint => address) private _owners;   // tokenId 到 owner address 的持有人映射
    mapping(address => uint) private _balances; // address 到 持仓数量 的持仓量映射
    mapping(uint => address) private _tokenApprovals; // tokenId 到 授权地址 的授权映射
    mapping(address => mapping(address => bool)) private _operatorApprovals; // owner地址 到 operator地址 的批量授权映射

    error ERC721InvalidReceiver(address receiver); // 错误 无效的接收者

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }

    // 实现IERC165 supportsInterface
    function supportsInterface(bytes4 interfaceId) external pure override returns(bool) {
        return interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC165).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId;
    }

    // 实现IERC721 balanceOf => 利用_balances变量查询owner地址的balance。
    function balanceOf(address owner) external view override returns (uint) {
        require(owner != address(0), "owner = zero address");
        return _balances[owner];
    }

    // 实现IERC721 ownerOf => 利用_owners变量查询tokenId的owner。
    function ownerOf(uint tokenId) public view override returns (address owner) {
        owner = _owners[tokenId];
        require(owner != address(0), "token doesn't exist");
    }

    // 实现IERC721 isApprovedForAll => 利用_operatorApprovals变量查询owner地址是否将所持NFT批量授权给了operator地址。
    function isApprovedForAll(address owner, address operator) external view override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    // 实现IERC721 setApprovalForAll => 将持有代币全部授权给operator地址。
    function setApprovalForAll(address operator, bool approved) external override {
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    // 实现IERC721 getApproved => 利用_tokenApprovals变量查询tokenId的授权地址。
    function getApproved(uint tokenId) external view override returns (address) {
        require(_owners[tokenId] != address(0), "token doesn't exist");
        return _tokenApprovals[tokenId];
    }

    // 授权函数。
    function _approve(address owner, address to, uint tokenId) private {
        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    // 实现IERC721 approve => 将tokenId授权给 to 地址。
    // 条件：to不是owner，且msg.sender是owner或授权地址。
    function approve(address to, uint tokenId) external override {
        address owner = _owners[tokenId];
        require(owner == msg.sender || _operatorApprovals[owner][msg.sender], "not owner nor approved fro all");
        _approve(owner, to, tokenId);
    }

    // 查询spender地址是否可以使用tokenId（需要是owner或被授权地址）
    function _isApprovedOrOwner(address owner, address spender, uint tokenId) private returns (bool) {
        return owner == spender || _tokenApprovals[tokenId] == spender || _operatorApprovals[owner][spender];
    }

    // 转账函数。
    // 条件: 1. tokenId 被 from 拥有; 2. to 不是0地址
    function _transfer(address owner, address from, address to, uint tokenId) private {
        require(owner == from, "not owner");
        require(to != address(0), "transfer to the zero address");

        _approve(owner, address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    // 实现IERC721 transferFrom => 非安全转账，不建议使用。
    function transferFrom(address from, address to, uint tokenId) external override {
        address owner = ownerOf(tokenId);
        // 当前账户必须是 tokenId 的拥有者或授权者 => 当前用户是否可以操作tokenId
        require(_isApprovedOrOwner(owner, msg.sender, tokenId), "not owner nor approved");
        _transfer(owner, from, to, tokenId);
    }


    /**
     * 安全转账。
     * 条件: 
        1. to 不能是0地址 
        2. tokenId 代币必须存在，并且被 from拥有 
        3. 如果 to 是智能合约, 他必须支持 IERC721Receiver-onERC721Received.
     * 安全地将 tokenId 代币从 from 转移到 to，会检查合约接收者是否了解 ERC721 协议，以防止代币被永久锁定。
     */
    function _safeTransfer(
        address owner,
        address from,
        address to,
        uint tokenId,
        bytes memory _data
    ) private {
        _transfer(owner, from, to, tokenId);
        _checkOnERC721Received(from, to, tokenId, _data);
    }

    // 实现IERC721 safeTransferFrom  => 安全转账
    function safeTransferFrom(
        address from,
        address to,
        uint tokenId,
        bytes memory _data
    ) public override {
        address owner = ownerOf(tokenId);
        require(_isApprovedOrOwner(owner, msg.sender, tokenId), "not owner nor approved");
        _safeTransfer(owner, from, to, tokenId, _data);
    }

    // safeTransferFrom重载函数
    function safeTransferFrom(
        address from,
        address to,
        uint tokenId
    ) external override {
        safeTransferFrom(from, to, tokenId, "");
    }

    // _checkOnERC721Received函数
    // 用于在 to 为合约的时候调用IERC721Receiver-onERC721Received, 以防 tokenId 被不小心转入黑洞。
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory data) private {
        // 通过检查 to 地址的代码长度大于 0 来判断是否为合约地址（普通用户的地址没有代码）。
        if (to.code.length > 0) {
            // 接收方合约(to) 必须返回 IERC721Receiver.onERC721Received.selector（即该方法的选择器，一个固定的bytes4值：0x150b7a02）。
            try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, data) returns (bytes4 retval) {
                if (retval != IERC721Receiver.onERC721Received.selector) {
                    revert ERC721InvalidReceiver(to);
                }
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert ERC721InvalidReceiver(to);
                } else {
                    // 内联汇编处理异常: 使用内联汇编来重新抛出原始异常数据，使得调用者能够看到具体的错误原因。
                    // reason是一个字节数组, 在内存中的布局为: 1.前32字节是数组长度 2.  mload(reason) 字节是实际的错误数据
                    // add(32, reason)：计算错误数据的起始位置（跳过长度字段，地址为 reason+32）
                    // mload(reason)：从reason的内存位置加载数据，得到数组长度（即错误数据的长度）。
                    // revert(offset, length)：回滚状态，并返回从内存位置 offset 开始的 length 个字节的错误信息。
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        }
    }

    /** 
     * 铸造函数。通过调整_balances和_owners变量来铸造tokenId并转账给 to，同时释放Transfer事件。
     * 这个mint函数所有人都能调用，实际使用需要开发人员重写，加上一些条件。
     * 条件:
     * 1. tokenId尚不存在。
     * 2. to不是0地址.
     */
    function _mint(address to, uint tokenId) internal virtual {
        require(to != address(0), "mint to zero address");
        require(_owners[tokenId] == address(0), "token already minted");

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    // 销毁函数，通过调整_balances和_owners变量来销毁tokenId，同时释放Transfer事件。
    // 条件：tokenId存在。
    function _burn(uint tokenId) internal virtual {
        address owner = ownerOf(tokenId);
        require(msg.sender == owner, "not owner of token");

        _approve(owner, address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }


    // 实现IERC721Metadata => tokenURI函数，查询metadata。
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_owners[tokenId] != address(0), "Token Not Exist");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * 计算{tokenURI}的BaseURI，tokenURI就是把baseURI和tokenId拼接在一起，需要开发重写。
     * BAYC的baseURI为ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/ 
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }
}