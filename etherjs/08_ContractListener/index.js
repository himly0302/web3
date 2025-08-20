import { ethers } from "ethers";
import { W_Proivate_Key, MAIN_URL } from "../const.js";

async function main() {
  // 链接ETH主网
  const provider = new ethers.JsonRpcProvider(MAIN_URL);

  // 构建USDT的Transfer的ABI
  const abiWETH = [
    "event Transfer(address indexed from, address indexed to, uint amount)",
  ];

  // USDT的合约地址
  const addressWETH = "0xdac17f958d2ee523a2206206994597c13d831ec7";

  // 声明合约实例
  const contractUSDT = new ethers.Contract(addressWETH, abiWETH, provider);

  // 监听USDT合约的Transfer事件
  try {
    // 只监听一次
    console.log("\n1. 利用contract.once()，监听一次Transfer事件");
    contractUSDT.once("Transfer", (from, to, value) => {
      // 打印结果
      console.log(
        `${from} -> ${to} ${ethers.formatUnits(ethers.getBigInt(value), 6)}`
      );
    });

    // 持续监听USDT合约
    console.log("\n2. 利用contract.on()，持续监听Transfer事件");
    contractUSDT.on("Transfer", (from, to, value) => {
      console.log(
        // 打印结果
        `${from} -> ${to} ${ethers.formatUnits(ethers.getBigInt(value), 6)}`
      );
    });
  } catch (e) {
    console.log(e);
  }
}

main();
