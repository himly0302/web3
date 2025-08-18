import { ethers } from "ethers";

// ethers内置的rpc访问速度有限制，仅测试用
const provider = ethers.getDefaultProvider();

const main = async () => {
  // ENS 域名是建立在 以太坊区块链 上的去中心化域名系统
  // 将人类可读的名字（比如vitalik.eth）映射到机器可读的标识符上，用于替代复杂的区块链地址和哈希值。
  const balance = await provider.getBalance("vitalik.eth");

  // 从链上获取的以太坊余额以wei为单位，而1 ETH = 10^18 wei
  console.log(`Balance: ${ethers.formatEther(balance)} ETH`);
};

main();
