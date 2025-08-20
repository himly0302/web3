import { ethers } from "ethers";
import { MAIN_URL } from "../const.js";
// 在ethers中, Contract类是部署在以太坊网络上的合约（EVM字节码）的抽象。
// 开发者通过它可以非常容易的对合约进行读取call和交易transaction，并可以获得交易的结果和事件。

// 只读Contract：参数分别是合约地址，合约abi和provider变量（只读）。
// 只读Contract只能读取链上合约信息，执行call操作，即调用合约中view和pure的函数，而不能执行交易transaction。
// const contract = new ethers.Contract(`address`, `abi`, `provider`);

// 可读写Contract：参数分别是合约地址，合约abi和signer变量。Signer签名者是ethers中的另一个类，用于签名交易，之后我们会讲到。
// const contract = new ethers.Contract(`address`, `abi`, `signer`);

// 注意 ethers中的call指的是只读操作，与solidity中的call不同。

// 连接以太坊主网
const provider = new ethers.JsonRpcProvider(MAIN_URL);

// 创建只读Contract实例需要填入3个参数，分别是合约地址，合约abi和provider变量。

// 方式一：直接输入合约abi
// 从remix的编译页面中复制，在本地编译合约时生成的artifact文件夹的json文件中得到，
// 从etherscan开源合约的代码页面得到 https://etherscan.io/token/0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2#code
const abiWETH =
  '[{"constant":true,"inputs":[],"name":"name","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"guy","type":"address"},{"name":"wad","type":"uint256"}],"name":"approve","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"totalSupply","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"src","type":"address"},{"name":"dst","type":"address"},{"name":"wad","type":"uint256"}],"name":"transferFrom","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"wad","type":"uint256"}],"name":"withdraw","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"decimals","outputs":[{"name":"","type":"uint8"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"","type":"address"}],"name":"balanceOf","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"symbol","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"dst","type":"address"},{"name":"wad","type":"uint256"}],"name":"transfer","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[],"name":"deposit","outputs":[],"payable":true,"stateMutability":"payable","type":"function"},{"constant":true,"inputs":[{"name":"","type":"address"},{"name":"","type":"address"}],"name":"allowance","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"payable":true,"stateMutability":"payable","type":"fallback"},{"anonymous":false,"inputs":[{"indexed":true,"name":"src","type":"address"},{"indexed":true,"name":"guy","type":"address"},{"indexed":false,"name":"wad","type":"uint256"}],"name":"Approval","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"src","type":"address"},{"indexed":true,"name":"dst","type":"address"},{"indexed":false,"name":"wad","type":"uint256"}],"name":"Transfer","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"dst","type":"address"},{"indexed":false,"name":"wad","type":"uint256"}],"name":"Deposit","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"src","type":"address"},{"indexed":false,"name":"wad","type":"uint256"}],"name":"Withdrawal","type":"event"}]';
const addressWETH = "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2"; // WETH Contract
const contractWETH = new ethers.Contract(addressWETH, abiWETH, provider);

// 方式二：通过function signature和event signature来写abi
const abiERC20 = [
  "function name() view returns (string)",
  "function symbol() view returns (string)",
  "function totalSupply() view returns (uint256)",
  "function balanceOf(address) view returns (uint)",
];
const addressDAI = "0x6B175474E89094C44Da98b954EedeAC495271d0F"; // DAI Contract
const contractDAI = new ethers.Contract(addressDAI, abiERC20, provider);

async function main() {
  // 1. 读取WETH合约的链上信息（WETH abi）
  const nameWETH = await contractWETH.name();
  const symbolWETH = await contractWETH.symbol();
  const totalSupplyWETH = await contractWETH.totalSupply();
  console.log("\n1. 读取WETH合约信息");
  console.log(`合约地址: ${addressWETH}`);
  console.log(`名称: ${nameWETH}`);
  console.log(`代号: ${symbolWETH}`);
  console.log(`总供给: ${ethers.formatEther(totalSupplyWETH)}`);
  const balanceWETH = await contractWETH.balanceOf("vitalik.eth");
  console.log(`Vitalik持仓: ${ethers.formatEther(balanceWETH)}\n`);

  // 2. 读取DAI合约的链上信息（IERC20接口合约）
  const nameDAI = await contractDAI.name();
  const symbolDAI = await contractDAI.symbol();
  const totalSupplDAI = await contractDAI.totalSupply();
  console.log("\n2. 读取DAI合约信息");
  console.log(`合约地址: ${addressDAI}`);
  console.log(`名称: ${nameDAI}`);
  console.log(`代号: ${symbolDAI}`);
  console.log(`总供给: ${ethers.formatEther(totalSupplDAI)}`);
  const balanceDAI = await contractDAI.balanceOf("vitalik.eth");
  console.log(`Vitalik持仓: ${ethers.formatEther(balanceDAI)}\n`);
}

main();
