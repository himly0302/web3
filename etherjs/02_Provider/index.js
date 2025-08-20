import { ethers } from "ethers";
import { MAIN_URL, TEST_URL } from "../const.js";

// provider类
// 是对以太坊网络连接的抽象，为标准以太坊节点功能提供简洁、一致的接口。
// Provider不接触用户私钥，只能读取链上信息，不能写入

// jsonRpcProvider 让用户连接到特定节点服务商的节点

// 链接以太坊主网
const providerETH = new ethers.JsonRpcProvider(MAIN_URL);
// 连接Sepolia测试网
const providerSepolia = new ethers.JsonRpcProvider(TEST_URL);

const main = async () => {
  console.log("查询vitalik在主网和Sepolia测试网的ETH余额"); // 测试网目前不支持ENS域名，只能用钱包地址查询
  const balance = await providerETH.getBalance("vitalik.eth");
  const balanceSepolia = await providerSepolia.getBalance(
    "0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045"
  );
  console.log(`ETH Balance of vitalik: ${ethers.formatEther(balance)} ETH`);
  console.log(
    `Sepolia ETH Balance of vitalik: ${ethers.formatEther(balanceSepolia)} ETH`
  );

  console.log("查询provider连接到了哪条链"); // homestead代表ETH主网
  const network = await providerETH.getNetwork();
  console.log(network.toJSON());

  console.log("查询区块高度");
  const blockNumber = await providerETH.getBlockNumber();
  console.log(blockNumber);

  console.log("查询 vitalik 钱包历史交易次数");
  const txCount = await providerETH.getTransactionCount("vitalik.eth");
  console.log(blockNumber);

  console.log("查询当前建议的gas设置");
  const feeData = await providerETH.getFeeData();
  console.log(feeData);

  console.log("查询区块信息");
  const block = await providerETH.getBlock(0);
  console.log(block);

  console.log("给定合约地址查询合约bytecode");
  const code = await providerETH.getCode(
    "0xc778417e063141139fce010982780140aa0cd5ab"
  );
  console.log(code);
};

main();
