import { ethers } from "ethers";
import { W_Proivate_Key, TEST_URL } from "../const.js";

// 事件Event 智能合约释放出的事件存储于以太坊虚拟机的日志中。
// 日志分为两个主题topics和数据data部分:
// topics中: 存储其中的事件哈希和indexed变量，作为索引方便以后搜索。
// data中: 存储非indexed变量，不能被直接检索，但可以存储更复杂的数据结构。

// 检索事件
// const transferEvents = await contract.queryFilter('事件名', 起始区块, 结束区块)
// 分别是事件名（必填），起始区块（选填），和结束区块（选填）。检索结果会以数组的方式返回。

async function main() {
  // 链接ETH测试网络
  const provider = new ethers.JsonRpcProvider(TEST_URL);

  // WETH ABI，只包含关心的Transfer事件
  // 注：要检索的事件必须包含在合约abi中
  const abiWETH = [
    "event Transfer(address indexed from, address indexed to, uint amount)",
  ];

  // WETH合约地址
  const addressWETH = "0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9";

  // 声明合约实例
  const contract = new ethers.Contract(addressWETH, abiWETH, provider);

  console.log("\n1. 获取过去10个区块内的Transfer事件，并打印出1个");
  // 得到当前block
  const block = await provider.getBlockNumber();
  console.log(`当前区块高度: ${block}`);
  console.log(`打印事件详情:`);
  const transferEvents = await contract.queryFilter(
    "Transfer",
    block - 10,
    block
  );
  // 打印第1个Transfer事件
  console.log(transferEvents[0]);

  console.log("\n2. 解析事件：");
  const amount = ethers.formatUnits(
    ethers.getBigInt(transferEvents[0].args["amount"]),
    "ether"
  );
  console.log(
    `地址 ${transferEvents[0].args["from"]} 转账${amount} WETH 到地址 ${transferEvents[0].args["to"]}`
  );
}

main();
