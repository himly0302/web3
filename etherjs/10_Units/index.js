import { ethers } from "ethers";

// 以太坊中，许多计算都对超出JavaScript整数的安全值（js中最大安全整数为9007199254740991）。因此，ethers.js使用 JavaScript ES2020 版本原生的 BigInt 类 安全地对任何数量级的数字进行数学运算。
// 在ethers.js中，大多数需要返回值的操作将返回 BigInt，而接受值的参数也会接受它们。

const oneGwei = ethers.getBigInt("1000000000"); // 从十进制字符串生成
console.log(oneGwei);
console.log(ethers.getBigInt("0x3b9aca00")); // 从hex字符串生成
console.log(ethers.getBigInt(1000000000)); // 从数字生成
// 不能从js最大的安全整数之外的数字生成BigNumber，下面代码会报错
// ethers.getBigInt(Number.MAX_SAFE_INTEGER);
console.log("js中最大安全整数：", Number.MAX_SAFE_INTEGER);

// 运算
console.log("加法：", oneGwei + 1n);
console.log("减法：", oneGwei - 1n);
console.log("乘法：", oneGwei * 2n);
console.log("除法：", oneGwei / 2n);
// 比较
console.log("是否相等：", oneGwei == 1000000000n);

// 经常将数值在用户可读的字符串（以ether为单位）和机器可读的数值（以wei为单位）之间转换。
// 例如，钱包可以为用户界面指定余额（以ether为单位）和gas价格（以gwei为单位），但是在发送交易时，两者都必须转换成以wei为单位的数值。

// 2. 格式化：小单位转大单位 wei => xxx
console.group("\n2. 格式化：小单位转大单位，formatUnits");
console.log(ethers.formatUnits(oneGwei, "gwei")); // '1.0'
console.log(ethers.formatUnits(oneGwei, "ether")); // `0.000000001`
console.log(ethers.formatEther(oneGwei)); // `0.000000001` 等同于formatUnits(value, "ether")

// 3. 解析：大单位转小单位 xxx => wei
// 例如将ether转换为wei：parseUnits(变量, 单位),parseUnits默认单位是 ether
console.group("\n3. 解析：大单位转小单位，parseUnits");
console.log(ethers.parseUnits("1.0", "ether").toString()); // { BigNumber: "1000000000000000000" }
console.log(ethers.parseUnits("1.0", "gwei").toString()); // { BigNumber: "1000000000" }
console.log(ethers.parseEther("1.0").toString()); // { BigNumber: "1000000000000000000" } 等同于parseUnits(value, "ether")
