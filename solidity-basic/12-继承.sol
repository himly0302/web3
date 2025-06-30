// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

// 规则
// virtual: 父合约中的函数，如果希望子合约重写，需要加上virtual关键字。
// override：子合约重写了父合约中的函数，需要加上override关键字。


/* 简单继承 */
contract Yeye {
    event Log(string msg);

    function hip() public virtual {
        emit Log('Yeye');
    }
    function pop() public virtual {
        emit Log('Yeye');
    }
    function yeye() public virtual {
        emit Log('yeye()');
    }

    function say() public {}
}

// is 关键字
contract Baba is Yeye {
    // 重写父合约函数
    function hip() public virtual override {
        emit Log('baba');
    }
    function pop() public virtual override {
        emit Log('baba');
    }
    function baba() public virtual {
        emit Log('baba');
    }
}

/* 多重继承 */
// 1.继承时要按辈分最高到最低的顺序排。如果写成 contract Erzi is Baba, Yeye 就会报错。
// 2.如果某一个函数在多个继承的合约里都存在，比如例子中的hip()和pop()，在子合约里必须重写，不然会报错。
// 3.重写在多个父合约中都重名的函数时，override关键字后面要加上所有父合约名字，例如override(Yeye, Baba)。

contract Erzi is Yeye, Baba {
    function hip() public virtual override(Yeye, Baba) {
        emit Log('Erzi');
    }
    function pop() public virtual override(Yeye, Baba) {
        emit Log('Ezri');
    }

    /* 调用父合约的函数 */
    // 1.  直接调用：子合约可以直接用 父合约名.函数名() 的方式来调用父合约函数
    function callParent() public  {
        Yeye.pop();
    }
    // 2. super关键字：子合约可以利用 super.函数名() 来调用最近的父合约函数。
    // 继承关系按声明时从右到左的顺序是：contract Erzi is Yeye, Baba，那么Baba是最近的父合约，super.pop()将调用Baba.pop()而不是Yeye.pop()：
    function callParentSuper() public{
        super.pop(); // Baba.pop()
    }
}

/* 修饰器的继承 */
contract Base1 {
    modifier exactDivideBy2And3(uint _a) virtual {
        require(_a % 2 == 0 && _a % 3 == 0);
        _;
    }
}

contract Identifier is Base1 {
    // 重写父合约中的修饰器
    // modifier exactDivideBy2And3(uint _a) override  {
    //     _;
    //     require(_a % 2 == 0 && _a % 3 == 0);
    // }

    // 直接使用父合约中的修饰器
    function getExtactData(uint _dividend) public exactDivideBy2And3(_dividend) pure returns (uint, uint) {
        uint div2 = _dividend / 2;
        uint div3 = _dividend / 3;
        return (div2, div3);
    }
}

/* 构造函数的继承 */
contract A {
    uint public a;

    constructor(uint _a) {
        a = _a;
    }
}

// 1. 在继承时声明父构造函数的参数
contract B is A(1) {}

// 2. 在子合约的构造函数中声明构造函数的参数
contract C is A {
    constructor(uint _c) A(_c * _c) {}
}




/* 钻石继承 */
// 调用合约people中的super.bar()会依次调用Eve、Adam，最后是God合约
contract God {
    event Log(string message);

    function foo() public virtual {
        emit Log("God.foo called");
    }

    function bar() public virtual {
        emit Log("God.bar called");
    }
}

contract Adam is God {
    function foo() public virtual override {
        emit Log("Adam.foo called");
        super.foo();
    }

    function bar() public virtual override {
        emit Log("Adam.bar called");
        super.bar();
    }
}

contract Eve is God {
    function foo() public virtual override {
        emit Log("Eve.foo called");
        super.foo();
    }

    function bar() public virtual override {
        emit Log("Eve.bar called");
        super.bar();
    }
}

contract people is Adam, Eve {
    function foo() public override(Adam, Eve) {
        super.foo();
    }

    function bar() public override(Adam, Eve) {
        super.bar();
    }
}