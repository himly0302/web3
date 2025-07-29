// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

// 荷兰拍卖(减价拍卖): 指拍卖标的的竞价由高到低依次递减直到第一个竞买人应价（达到或超过底价）时击槌成交的一种拍卖。
// 1. 荷兰拍卖的价格由最高慢慢下降，能让项目方获得最大的收入。
// 2. 拍卖持续较长时间（通常6小时以上），可以避免gas war

import "@openzeppelin/contracts/access/Ownable.sol";
import "./31-ERC721/ERC721.sol";


contract DutchAuction is Ownable, ERC721 {

    uint256 public constant COLLECTION_SIZE = 10000; // // NFT总数
    uint256 public constant AUCTION_START_PRICE = 1 ether; // 起拍价(最高价)
    uint256 public constant AUCTION_END_PRICE = 0.1 ether; // 结束价(最低价/地板价)
    uint256 public constant AUCTION_TIME = 10 minutes; // 拍卖时间，为了测试方便设为10分钟
    uint256 public constant AUCTION_DROP_INTERVAL = 1 minutes; // 每过多久时间，价格衰减一次
    uint256 public constant AUCTION_DROP_PER_STEP =
        (AUCTION_START_PRICE - AUCTION_END_PRICE) /
        (AUCTION_TIME / AUCTION_DROP_INTERVAL); // 每次价格衰减步长
    
    uint256 public auctionStartTime; // 拍卖开始时间戳
    string private _baseTokenURI;   // metadata URI
    uint256[] private _allTokens; // 记录所有存在的tokenId

    constructor() Ownable(msg.sender) ERC721("WTF Dutch Auction", "WTF Dutch Auction") {
        auctionStartTime = block.timestamp;
    }

    function setAuctionStartTime(uint32 timestamp) external onlyOwner {
        auctionStartTime = timestamp;
    }

    function totalSupply() public view returns (uint256) {
        return _allTokens.length;
    }

    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokens.push(tokenId);
    }

    // 获取拍卖实时价格
    function getAuctionPrice() public view returns (uint256) {
        if (block.timestamp < auctionStartTime) {
        return AUCTION_START_PRICE;
        }else if (block.timestamp - auctionStartTime >= AUCTION_TIME) {
        return AUCTION_END_PRICE;
        } else {
        uint256 steps = (block.timestamp - auctionStartTime) /
            AUCTION_DROP_INTERVAL;
        return AUCTION_START_PRICE - (steps * AUCTION_DROP_PER_STEP);
        }
    }

    // 拍卖
    function auctionMint(uint256 quantity) external payable {
        uint256 _saleStartTime = auctionStartTime; // 建立local变量，减少gas花费

        // 检查是否设置起拍时间，拍卖是否开始
        require(_saleStartTime != 0 && block.timestamp >= _saleStartTime, "sale has not started yet");
        // 检查是否超过NFT上限
        require(totalSupply() + quantity <= COLLECTION_SIZE, "not enough remaining reserved for auction to support desired mint amount");
        
        uint256 totalCost = getAuctionPrice() * quantity; // 计算成本 = 购买数量 * 当前价格
        require(msg.value >= totalCost, "Need to send more ETH"); // 检查用户是否支付足够ETH

        // Mint NFT
        for(uint256 i = 0; i < quantity; i++) {
            uint256 mintIndex = totalSupply();
            _mint(msg.sender, mintIndex);
            _addTokenToAllTokensEnumeration(mintIndex);
        }

        // 多余ETH退款
        if (msg.value > totalCost) {
            payable(msg.sender).transfer(msg.value - totalCost); //注意一下这里是否有重入的风险
        }
    }

    // BaseURI
    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    // BaseURI setter函数, onlyOwner
    function setBaseURI(string calldata baseURI) external onlyOwner {
        _baseTokenURI = baseURI;
    }

    function withdrawMoney() external onlyOwner {
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "Transfer failed.");
    }
}