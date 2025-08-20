import { ethers } from "ethers";
import { W_Proivate_Key, TEST_URL } from "../const.js";

// staticCall 在发送交易之前检查交易是否会失败，节省大量gas
// 在以太坊上发交易需要付昂贵的gas，并且有失败的风险，发送失败的交易并不会把gas返还给你。

// 这种调用适用于任何函数，无论它在智能合约中是标记为 view/pure 还是普通的状态改变函数。它使你能够安全地预测状态改变操作的结果，而不实际执行这些操作。
/**
const tx = await contract.函数名.staticCall(参数, {override})
{override}：选填，可包含以下参数：
from：执行时的msg.sender，也就是你可以模拟任何一个人的调用，比如Vitalik。
value：执行时的msg.value。
blockTag：执行时的区块高度。
gasPrice
gasLimit
nonce
*/

async function main() {
  // 链接ETH 测试网
  const provider = new ethers.JsonRpcProvider(TEST_URL);

  // WETH合约
  const abiWETH = [
    "function balanceOf(address) public view returns(uint)",
    "function transfer(address, uint) public returns (bool)",
  ];
  const addressWETH = "0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9";
  const contract = new ethers.Contract(addressWETH, abiWETH, provider);

  try {
    const wallet = new ethers.Wallet(W_Proivate_Key, provider);
    const address = wallet.getAddress();

    console.log("\n1. 读取测试钱包的WETH余额");
    const balanceDAI = await contract.balanceOf(address);
    const balanceDAIVitalik = await contract.balanceOf("vitalik.eth");
    console.log(`测试钱包 DAI持仓: ${ethers.formatEther(balanceDAI)}\n`);
    console.log(`vitalik DAI持仓: ${ethers.formatEther(balanceDAIVitalik)}\n`);

    console.log(
      "\n2.  用staticCall尝试调用transfer转账0.1WETH，msg.sender为Vitalik地址"
    );
    const tx = await contract.transfer.staticCall(
      "vitalik.eth",
      ethers.parseEther("0.1"),
      { from: await provider.resolveName("vitalik.eth") }
    );
    console.log(`交易会成功吗？：`, tx);

    console.log(
      "\n3.  用staticCall尝试调用transfer转账100WETH，msg.sender为测试钱包地址"
    );
    const tx2 = await contract.transfer.staticCall(
      "vitalik.eth",
      ethers.parseEther("100"),
      { from: address }
    );
    console.log(`交易会成功吗？：`, tx2);
  } catch (error) {
    console.log(error);
  }
}

main();
