import { ethers } from "ethers";
import { W_Proivate_Key, TEST_URL } from "../const.js";

// 接口类 Interface
// ethers.js的接口类抽象了与以太坊网络上的合约交互所需的ABI编码和解码。
/**
const interface = ethers.Interface(abi) // 利用abi生成
const interface2 = contract.interface // 直接从contract中获取

// 获取函数选择器，参数为函数名或函数签名。
interface.getSighash("balanceOf");

// 编码构造器的参数，然后可以附在合约字节码的后面。
interface.encodeDeploy("Wrapped ETH", "WETH");

// 编码函数的calldata
interface.encodeFunctionData("balanceOf", ["0xfc9cDDc1BBE4936B7A270880DfD6C8F87b9897Aa"]);

// 解码函数的返回值。
interface.decodeFunctionResult("balanceOf", resultData)
*/

async function main() {
  const provider = new ethers.JsonRpcProvider(TEST_URL);
  const wallet = new ethers.Wallet(W_Proivate_Key, provider);

  // WETH合约
  const abiWETH = [
    "function balanceOf(address) public view returns(uint)",
    "function deposit() public payable",
  ];
  const addressWETH = "0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9";
  const contract = new ethers.Contract(addressWETH, abiWETH, provider);

  const address = await wallet.getAddress();

  console.log("\n1. 读取WETH余额");
  const param1 = contract.interface.encodeFunctionData("balanceOf", [address]);
  console.log(`编码结果： ${param1}`);
  const tx1 = { to: addressWETH, data: param1 };
  const balanceWETH = await provider.call(tx1);
  console.log(`存款前WETH持仓: ${ethers.formatEther(balanceWETH)}\n`);

  //读取钱包内ETH余额
  const balanceETH = await provider.getBalance(address);
  console.log(`ETH持仓: ${ethers.formatEther(balanceETH)}\n`);
}

main();
