import { ethers } from "ethers";
import { Infura_Key, W_Proivate_Key } from "../env.js";

// 过滤器 当合约创建日志（释放事件）时，它最多可以包含[4]条数据作为索引（indexed）。
// 因此，一个事件过滤器最多包含4个主题集，每个主题集是个条件，用于筛选目标事件。

// 如果一个主题集为null，则该位置的日志主题不会被过滤，任何值都匹配。
// 如果主题集是单个值，则该位置的日志主题必须与该值匹配。
// 如果主题集是数组，则该位置的日志主题至少与数组中其中一个匹配。
// const filter = contract.filters.EVENT_NAME( ...args )  => 其中EVENT_NAME为要过滤的事件名，..args为主题集/条件。

// 例子
// contract.filters.Transfer(myAddress) => 过滤来自myAddress地址的Transfer事件
// contract.filters.Transfer(null, myAddress) => 过滤所有发给 myAddress地址的Transfer事件
// contract.filters.Transfer(myAddress, otherAddress) => 过滤所有从 myAddress发给otherAddress的Transfer事件
// contract.filters.Transfer(null, [ myAddress, otherAddress ]) => 过滤所有发给myAddress或otherAddress的Transfer事件

// 某次交易日志 https://etherscan.io/tx/0xab1f7b575600c4517a2e479e46e3af98a95ee84dd3f46824e02ff4618523fff5

async function main() {
  // 链接ETH主网
  const provider = new ethers.JsonRpcProvider(
    `https://mainnet.infura.io/v3/${Infura_Key}`
  );

  // 合约地址
  const addressUSDT = "0xdac17f958d2ee523a2206206994597c13d831ec7";
  // 交易所地址
  const accountBinance = "0x28C6c06298d514Db089934071355E5743bf21d60";
  // 构建ABI
  const abi = [
    "event Transfer(address indexed from, address indexed to, uint value)",
    "function balanceOf(address) public view returns(uint)",
  ];
  // 构建合约对象
  const contractUSDT = new ethers.Contract(addressUSDT, abi, provider);

  try {
    // 1. 读取币安热钱包USDT余额
    console.log("\n1. 读取币安热钱包USDT余额");
    const balanceUSDT = await contractUSDT.balanceOf(accountBinance);
    console.log(`USDT余额: ${ethers.formatUnits(balanceUSDT, 6)}\n`);

    // 2. 创建过滤器，监听转移USDT进交易所
    console.log("\n2. 创建过滤器，监听USDT转进交易所");
    let filterBinanceIn = contractUSDT.filters.Transfer(null, accountBinance);
    console.log("过滤器详情：");
    console.log(filterBinanceIn);
    contractUSDT.on(filterBinanceIn, (res) => {
      console.log("---------监听USDT进入交易所--------");
      console.log(
        `${res.args[0]} -> ${res.args[1]} ${ethers.formatUnits(res.args[2], 6)}`
      );
    });

    // 3. 创建过滤器，监听交易所转出USDT
    let filterToBinanceOut = contractUSDT.filters.Transfer(accountBinance);
    console.log("\n3. 创建过滤器，监听USDT转出交易所");
    console.log("过滤器详情：");
    console.log(filterToBinanceOut);
    contractUSDT.on(filterToBinanceOut, (res) => {
      console.log("---------监听USDT转出交易所--------");
      console.log(
        `${res.args[0]} -> ${res.args[1]} ${ethers.formatUnits(res.args[2], 6)}`
      );
    });
  } catch (e) {
    console.log(e);
  }
}

main();
