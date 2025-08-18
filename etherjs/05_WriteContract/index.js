import { ethers } from "ethers";
import { W_Proivate_Key } from "../env.js";

// 1.创建可写Contract变量
// address: 合约地址 abi: 合约abi接口 signer: wallet对象
// const contract = new ethers.Contract(address, abi, signer)

// 2. 将可读合约转换为可写合约
// const contract = contract.connect(signer)

// 合约交互
// 读取合约信息，不需要gas; 写入合约信息，要构建交易并且支付gas; 此交易将由整个网络上的每个节点以及矿工验证，并改变区块链状态。
/*
// 发送交易
const tx = await contract.METHOD_NAME(args [, overrides])
// 等待链上确认交易
await tx.wait()

[, overrides] 可选传入的数据

gasPrice：gas价格
gasLimit：gas上限
value：调用时传入的ether（单位是wei）
nonce：nonce
*/

async function main() {
  // 链接ETH测试网络
  const provider = new ethers.JsonRpcProvider(
    "https://eth-sepolia.public.blastapi.io"
  );

  // 利用私钥创建wallet对象
  const wallet = new ethers.Wallet(W_Proivate_Key, provider);

  // WETH的ABI
  const abiWETH = [
    "function balanceOf(address) public view returns(uint)",
    "function deposit() public payable",
    "function transfer(address, uint) public returns (bool)",
    "function withdraw(uint) public",
  ];

  // WETH合约地址
  const addressWETH = "0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9";

  // 声明可写合约
  const contractWETH = new ethers.Contract(addressWETH, abiWETH, wallet);

  // 钱包地址
  const address = await wallet.getAddress();

  console.log("\n1. 读取WETH余额");
  const balanceWETH = await contractWETH.balanceOf(address);
  console.log(`存款前WETH持仓: ${ethers.formatEther(balanceWETH)}\n`);

  console.log("\n2. 调用desposit()函数，存入0.001 ETH");
  // 发起交易
  const tx = await contractWETH.deposit({ value: ethers.parseEther("0.001") });
  // 等待交易上链
  await tx.wait();
  console.log(`交易详情：`);
  console.log(tx);
  const balanceWETH_deposit = await contractWETH.balanceOf(address);
  console.log(`存款后WETH持仓: ${ethers.formatEther(balanceWETH_deposit)}\n`);

  console.log("\n3. 调用transfer()函数，给vitalik转账0.001 WETH");
  // 发起交易
  const tx2 = await contractWETH.transfer(
    "vitalik.eth",
    ethers.parseEther("0.001")
  );
  // 等待交易上链
  await tx2.wait();
  const balanceWETH_transfer = await contractWETH.balanceOf(address);
  console.log(`转账后WETH持仓: ${ethers.formatEther(balanceWETH_transfer)}\n`);
}

main();
