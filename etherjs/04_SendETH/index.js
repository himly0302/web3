import { ethers } from "ethers";
import { W_Proivate_Key } from "../env.js";

// Signer签名者类
// Web3.js认为用户会在本地部署以太坊节点，私钥和网络连接状态由这个节点管理（实际并不是这样）
// ethers.js中，Provider提供器类管理网络连接状态，Signer签名者类或Wallet钱包类管理密钥，安全且灵活。
// 在ethers中，Signer签名者类是以太坊账户的抽象，可用于对消息和交易进行签名，并将签名的交易发送到以太坊网络，并更改区块链状态。
// 注: Signer类是抽象类，不能直接实例化，我们需要使用它的子类：Wallet钱包类。

const provider = new ethers.JsonRpcProvider(
  "https://eth-sepolia.public.blastapi.io"
);

// Wallet钱包类
// 1. 创建随机私钥的wallet对象
const wallet1 = ethers.Wallet.createRandom(); // 单机钱包
const wallet1WithProvider = wallet1.connect(provider); // 连接到以太坊节点
const mnemonic = wallet1.mnemonic; // 获取助记词

// 2. 利用私钥和provider创建wallet对象
const privateKey = W_Proivate_Key;
const wallet2 = new ethers.Wallet(privateKey, provider);

// 3. 从助记词创建wallet对象
const wallet3 = ethers.Wallet.fromPhrase(mnemonic.phrase); // 使用的是wallet1的助记词, 则创建出钱包的私钥和公钥都和wallet1相同

async function main() {
  console.log(`1. 获取钱包地址`);
  const address1 = await wallet1.getAddress();
  const address2 = await wallet2.getAddress();
  const address3 = await wallet3.getAddress();
  console.log(`钱包1地址: ${address1}`);
  console.log(`钱包2地址: ${address2}`);
  console.log(`钱包3地址: ${address3}`);
  console.log(`钱包1和钱包3的地址是否相同: ${address1 === address3}`);

  console.log(`\n2. 获取助记词`);
  console.log(`钱包1助记词: ${wallet1.mnemonic.phrase}`);
  // console.log(wallet2.mnemonic.phrase) // 注意：从private key生成的钱包没有助记词

  console.log(`\n3. 获取私钥`);
  console.log(`钱包1私钥: ${wallet1.privateKey}`); // 0x1e5682ddf10317b728f2f0594d79bb8682696fc37e535117a167c06fed1e5c53
  console.log(`钱包2私钥: ${wallet2.privateKey}`);

  console.log(`\n4. 获取链上交易次数`);
  const txCount1 = await provider.getTransactionCount(wallet1WithProvider);
  const txCount2 = await provider.getTransactionCount(wallet2);
  console.log(`钱包1发送交易次数: ${txCount1}`);
  console.log(`钱包2发送交易次数: ${txCount2}`);

  console.log(`\n5. 发送ETH（测试网）`);
  // i. 打印交易前余额
  console.log(`i. 发送前余额`);
  console.log(
    `钱包1: ${ethers.formatEther(
      await provider.getBalance(wallet1WithProvider)
    )} ETH`
  );
  console.log(
    `钱包2: ${ethers.formatEther(await provider.getBalance(wallet2))} ETH`
  );

  // ii. 构造交易请求，参数：to为接收地址，value为ETH数额
  const tx = {
    to: address1,
    value: ethers.parseEther("0.001"),
  };

  // iii. 发送交易，获得收据
  console.log(`\nii. 等待交易在区块链确认（需要几分钟）`);
  // const receipt = await wallet2.sendTransaction(tx);
  // await receipt.wait(); // 等待链上确认交易
  console.log(receipt); // 打印交易详情

  // iv. 打印交易后余额
  console.log(`\niii. 发送后余额`);
  console.log(
    `钱包1: ${ethers.formatEther(
      await provider.getBalance(wallet1WithProvider)
    )} ETH`
  );
  console.log(
    `钱包2: ${ethers.formatEther(await provider.getBalance(wallet2))} ETH`
  );
}

main();
