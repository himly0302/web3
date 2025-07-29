// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "./31-ERC721/IERC721.sol";

contract NFTSwap is IERC721Receiver {
    // 卖家事件
    event List(address indexed seller, address indexed nftAddr, uint256 indexed tokenId, uint256 price); // 挂单
    event Revoke(address indexed seller, address indexed nftAddr, uint256 indexed tokenId); // 撤单
    event Update(address indexed seller, address indexed nftAddr, uint256 indexed tokenId, uint256 newPrice); // 修改价格
    // 买家事件
    event Purchase(address indexed buyer, address indexed nftAddr, uint256 indexed tokenId, uint256 price); // 购买

    // 用户用eth购买NFT
    receive() external payable { }
    fallback() external payable { }

    struct Order {
        address owner;
        uint256 price;
    }

    // nft合约地址[nft的id] => order
    mapping(address => mapping(uint256 => Order)) public nftList;


    // 挂单: 卖家上架NFT
    function list(address _nftAddr, uint256 _tokenId, uint256 _price) public {
        IERC721 _nft = IERC721(_nftAddr);
        require(_nft.getApproved(_tokenId) == address(this), "Need Approval");
        require(_price > 0);

        //设置NFT持有人和价格
        Order storage _order = nftList[_nftAddr][_tokenId];
        _order.owner = msg.sender;
        _order.price = _price;

        _nft.safeTransferFrom(msg.sender, address(this), _tokenId); // 将NFT转账到合约？为什么转到合约

        emit List(msg.sender, _nftAddr, _tokenId, _price);
    }

    // 购买: 买家购买NFT
    function purchase(address _nftAddr, uint256 _tokenId) public payable {
        Order storage _order = nftList[_nftAddr][_tokenId];
        require(_order.price > 0, "Invalid Price"); // NFT价格大于0
        require(msg.value > _order.price, "Increase price"); // 购买价格大于标价

        IERC721 _nft = IERC721(_nftAddr);
        require(_nft.ownerOf(_tokenId) == address(this), "Invalid Order"); // NFT在合约中

        _nft.safeTransferFrom(address(this), msg.sender, _tokenId); // 将NFT转给买家
        payable(_order.owner).transfer(_order.price); //  将ETH转给卖家

        if (msg.value > _order.price) {
            payable(msg.sender).transfer(msg.value - _order.price);
        }

        emit Purchase(msg.sender, _nftAddr, _tokenId, _order.price);

        delete nftList[_nftAddr][_tokenId];
    }


    // 撤单: 卖家取消挂单
    function revoke(address _nftAddr, uint256 _tokenId) public {
        Order storage _order = nftList[_nftAddr][_tokenId];
        require(_order.owner == msg.sender, "Not Owner"); // 必须由持有人发起

        IERC721 _nft = IERC721(_nftAddr);
        require(_nft.ownerOf(_tokenId) == address(this), "Invalid Order");

        _nft.safeTransferFrom(address(this), msg.sender, _tokenId); // 将NFT转给卖家

        emit Revoke(msg.sender, _nftAddr, _tokenId);

        delete nftList[_nftAddr][_tokenId]; // 删除order
    }

    function update(address _nftAddr, uint256 _tokenId, uint256 _newPrice) public {
        require(_newPrice > 0, "Invalid Price"); // NFT价格大于0
        Order storage _order = nftList[_nftAddr][_tokenId];
        require(_order.owner == msg.sender, "Not Owner"); // 必须由持有人发起
        
        IERC721 _nft = IERC721(_nftAddr);
        require(_nft.ownerOf(_tokenId) == address(this), "Invalid Order");

        _order.price = _newPrice; // 调整NFT价格

        emit Update(msg.sender, _nftAddr, _tokenId, _newPrice);
    }


    // 实现{IERC721Receiver}的onERC721Received，能够接收ERC721代币
    function onERC721Received(address operator, address from, uint tokenId, bytes calldata data) external pure override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}