// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

// DeFi 是货币乐高，可以通过组合多个协议来创造新的协议；但由于 DeFi 缺乏标准，严重影响了它的可组合性。
// 而 ERC4626 扩展了 ERC20 代币标准，旨在推动收益金库的标准化。

// 金库合约 允许把基础资产（代币）质押到合约中，换取一定收益
// 收益农场：可以质押 USDT 获取利息
// 借贷：可以出借 ETH 获取存款利息和贷款
// 质押：可以质押 ETH 参与 ETH 2.0 质押，得到可以生息的 stETH

// ERC4626 代币化金库标准
// 优点
// 1. 代币化：ERC4626 继承了 ERC20，向金库存款时，将得到同样符合 ERC20 标准的金库份额；比如质押 ETH，自动获得 stETH。
// 2. 更好的流通性：由于代币化，你可以在不取回基础资产的情况下，利用金库份额做其他事情。比如 Lido 的 stETH 为例，你可以用它在 Uniswap 上提供流动性或交易，而不需要取出其中的 ETH。
// 3. 更好的可组合性： 有了标准之后，用一套接口可以和所有 ERC4626 金库交互，让基于金库的应用、插件、工具开发更容易。

// 主要逻辑
// 1. ERC20：用户将特定的 ERC20 基础资产（比如 WETH）存进金库，合约会给他铸造特定数量的金库份额代币；当用户从金库中提取基础资产时，会销毁相应数量的金库份额代币。
// 2. 存款逻辑：让用户存入基础资产，并铸造相应数量的金库份额。
// 3. 提款逻辑：让用户销毁金库份额，并提取金库中相应数量的基础资产。
// 4. 会计和限额逻辑：统计金库中的资产，存款/提款限额，和存款/提款的基础资产和金库份额数量。

import {IERC20, IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * ERC4626 "代币化金库标准"的接口合约
 * https://eips.ethereum.org/EIPS/eip-4626[ERC-4626].
 */
interface IERC4626 is IERC20, IERC20Metadata {
    
    event Deposit(address indexed sender, address indexed owner, uint256 assets, uint256 shares); // 存款时触发
    event Withdraw(address indexed sender, address indexed receiver, address indexed owner, uint256 assets, uint256 shares); // 取款时触发

    // 返回金库的基础资产代币地址(用于 存款、取款)
    function asset() external view returns (address assetTokenAdress);

    // 存款函数: 用户向金库存入 assets 单位的基础资产，然后合约铸造 shares 单位的金库额度给 receiver 地址
    function deposit(uint256 assets, address receiver) external returns (uint256 shares);

    // 铸造函数: 用户需要存入 assets 单位的基础资产，然后合约给 receiver 地址铸造 share 数量的金库额度
    function mint(uint256 shares, address receiver) external returns (uint256 assets);

    // 提款函数: owner 地址销毁 share 单位的金库额度，然后合约将 assets 单位的基础资产发送给 receiver 地址
    function withdraw(uint256 assets, address receiver, address owner) external returns (uint256 shares);

    // 赎回函数: owner 地址销毁 shares 数量的金库额度，然后合约将 assets 单位的基础资产发给 receiver 地址
    function redeem(uint256 shares, address receiver, address owner) external returns (uint256 assets);

    // 返回金库中管理的基础资产代币总额 => 要包含利息|要包含费用|不能revert
    function totalAssets() external view returns (uint256 totalManageAssets);

    // 返回利用一定数额基础资产可以换取的金库额度 => 不要包含费用|不包含滑点|不能revert
    function convertToShares(uint256 assets) external view returns (uint256 shares);

    // 返回利用一定数额金库额度可以换取的基础资产 => 不要包含费用|不包含滑点|不能revert
    function convertToAssets(uint256 shares) external view returns (uint256 assets);

    /**
     * @dev 用于链上和链下用户在当前链上环境模拟存款一定数额的基础资产能够获得的金库额度
     * - 返回值要接近且不大于在同一交易进行存款得到的金库额度
     * - 不要考虑 maxDeposit 等限制，假设用户的存款交易会成功
     * - 要考虑费用
     * - 不能revert
     * NOTE: 可以利用 convertToAssets 和 previewDeposit 返回值的差值来计算滑点
     */
    function previewDeposit(uint256 assets) external view returns (uint256 shares);

    /**
     * @dev 用于链上和链下用户在当前链上环境模拟铸造 shares 数额的金库额度需要存款的基础资产数量
     * - 返回值要接近且不小于在同一交易进行铸造一定数额金库额度所需的存款数量
     * - 不要考虑 maxMint 等限制，假设用户的存款交易会成功
     * - 要考虑费用
     * - 不能revert
     */
    function previewMint(uint256 shares) external view returns (uint256 assets);

    /**
     * @dev 用于链上和链下用户在当前链上环境模拟提款 assets 数额的基础资产需要赎回的金库份额
     * - 返回值要接近且不大于在同一交易进行提款一定数额基础资产所需赎回的金库份额
     * - 不要考虑 maxWithdraw 等限制，假设用户的提款交易会成功
     * - 要考虑费用
     * - 不能revert
     */
    function previewWithdraw(uint256 assets) external view returns (uint256 shares);

    /**
     * @dev 用于链上和链下用户在当前链上环境模拟销毁 shares 数额的金库额度能够赎回的基础资产数量
     * - 返回值要接近且不小于在同一交易进行销毁一定数额的金库额度所能赎回的基础资产数量
     * - 不要考虑 maxRedeem 等限制，假设用户的赎回交易会成功
     * - 要考虑费用
     * - 不能revert.
     */
    function previewRedeem(uint256 shares) external view returns (uint256 assets);

    // 返回某个用户地址单次存款可存的最大基础资产数额
    // 如果有存款上限，那么返回值应该是个有限值 | 返回值不能超过 2 ** 256 - 1  | 不能revert
    function maxDeposit(address receiver) external view returns (uint256 maxAssets);

    // 返回某个用户地址单次铸造可以铸造的最大金库额度
    // 如果有存款上限，那么返回值应该是个有限值 | 返回值不能超过 2 ** 256 - 1  | 不能revert
    function maxMint(address receiver) external view returns (uint256 maxShares);

    // 返回某个用户地址单次取款可以提取的最大基础资产额度
    function maxWithdraw(address owner) external view returns (uint256 maxAssets);

    // 返回某个用户地址单次赎回可以销毁的最大金库额度
    function maxRedeem(address owner) external view returns (uint256 maxShares);
}