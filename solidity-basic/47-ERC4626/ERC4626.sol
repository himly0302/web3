// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

// 极简版的代币化金库合约
// 构造函数初始化基础资产的合约地址，金库份额的代币名称和符号。注意，金库份额的代币名称和符号要和基础资产有关联，比如基础资产叫 WTF，金库份额最好叫 vWTF。
// 存款时，当用户向金库存 x 单位的基础资产，会铸造 x 单位（等量）的金库份额。
// 取款时，当用户销毁 x 单位的金库份额，会提取 x 单位（等量）的基础资产。

import {ERC20, IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./IERC4626.sol";

contract ERC4626 is ERC20, IERC4626 {
    ERC20 private immutable _asset;
    uint8 private immutable _decimals;

    constructor(ERC20 asset_, string memory name_, string memory symbol_) ERC20(name_, symbol_) {
        _asset = asset_;
        _decimals = asset_.decimals();
    }

    // IERC4626
    function asset() public view virtual override returns (address) {
        return address(_asset);
    }

    // IERC20Metadata
    function decimals() public view virtual override(IERC20Metadata, ERC20) returns (uint8) {
        return _decimals;
    }

    // IERC4626 存款<存入 基础资产 获取 金库份额>
    function deposit(uint256 assets, address receiver) public virtual returns (uint256 shares) {
        shares = previewDeposit(assets); // 计算将获得的金库份额
        
        // msg.sender(用户) 已授权 ERC4626(当前合约) 转帐 _asset币 的权限
        // 因此 在当前合约中 使用_asset.transferFrom进行转帐操作 
        _asset.transferFrom(msg.sender, address(this), assets); // 先 transfer 后 mint，防止重入
        _mint(receiver, shares);

        emit Deposit(msg.sender, receiver, assets, shares);
    }

    // IERC4626 提款<提取 基础资产 销毁 金库份额>
    function withdraw(uint256 assets, address receiver, address owner) public virtual returns (uint256 shares) {
        shares = previewWithdraw(assets); // 计算将销毁的金库份额

        // 如果调用者不是 owner，则检查并更新授权
        if (msg.sender != owner) {
            _spendAllowance(owner, msg.sender, shares);
        }

        _burn(owner, shares); // 先销毁后 transfer，防止重入?
        _asset.transfer(receiver, assets);

        emit Withdraw(msg.sender, receiver, owner, assets, shares);
    }

    // IERC4626 铸币<铸造 金币份额 存入 基础资产>
    function mint(uint256 shares, address receiver) public virtual returns (uint256 assets) {
        assets = previewMint(shares); // 计算需要存款的基础资产数额

        _asset.transferFrom(msg.sender, address(this), assets); // 先 transfer 后 mint，防止重入
        _mint(receiver, shares);

        emit Deposit(msg.sender, receiver, assets, shares);
    }

    // IERC4626 赎回<销毁 金库份额 获取 基础资产>
    function redeem(uint256 shares, address receiver, address owner) public virtual returns (uint256 assets) {
        assets = previewMint(shares); // 计算需要存款的基础资产数额

        // 如果调用者不是 owner，则检查并更新授权
        if (msg.sender != owner) {
            _spendAllowance(owner, msg.sender, shares);
        }

        _burn(owner, shares);
        _asset.transfer(receiver, assets);

        emit Withdraw(msg.sender, receiver, owner, assets, shares);
    }


    // IERC4626 返回合约中基础资产持仓
    function totalAssets() public view virtual returns (uint256){
        return _asset.balanceOf(address(this));
    }

    // IERC4626  基础资产 => 金库份额
    function convertToShares(uint256 assets) public view virtual returns (uint256) {
        uint256 supply = totalSupply();
        // 如果 supply 为 0，那么 1:1 铸造金库份额
        // 如果 supply 不为0，那么按比例铸造
        return supply == 0 ? assets : assets * supply / totalAssets();
    }

    // IERC4626  金库份额 => 基础资产
   function convertToAssets(uint256 shares) public view virtual returns (uint256) {
        uint256 supply = totalSupply();
        // 如果 supply 为 0，那么 1:1 赎回基础资产
        // 如果 supply 不为0，那么按比例赎回
        return supply == 0 ? shares : shares * totalAssets() / supply;
    }

    // IERC4626
    function previewDeposit(uint256 assets) public view virtual returns (uint256) {
        return convertToShares(assets);
    }

    // IERC4626
    function previewWithdraw(uint256 assets) public view virtual  returns (uint256) {
        return convertToShares(assets);
    }

    // IERC4626
    function previewMint(uint256 shares) public view virtual returns (uint256) {
        return convertToAssets(shares);
    }
    
    // IERC4626
    function previewRedeem(uint256 shares) public view virtual returns (uint256) {
        return convertToAssets(shares);
    }

    function maxDeposit(address) public view virtual returns (uint256) {
        return type(uint256).max;
    }

    function maxMint(address) public view virtual returns (uint256) {
        return type(uint256).max;
    }

    function maxWithdraw(address owner) public view virtual returns (uint256) {
        return convertToAssets(balanceOf(owner));
    }

    function maxRedeem(address owner) public view virtual returns (uint256) {
        return balanceOf(owner);
    }
}