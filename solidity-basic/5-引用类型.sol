// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract HelloTypes {
    /* 数组: 存储一组数组 */
    // 固定长度数组：在声明时指定数组的长度。用T[k]的格式声明，其中T是元素的类型，k是长度
    // 固定长度数组可以逐个元素赋值，或者在声明时初始化。
    uint[8] array1;
    bytes1[5] array2;
    address[3] array3;
    // 可变长度数组（动态数组）：在声明时不指定数组的长度。用T[]的格式声明，其中T是元素的类型
    // 动态数组需要先初始化存储空间，比如使用new uint(x)，或者直接赋值一个数组字面量，例如array4 = [1,2,3];。

    uint[] array4;
    bytes1[] array5 = [bytes1(0xaa), 0xbb];
    address[] array6;
    bytes array7; // 特殊数组, 不用加[]

    // 规则
    function getArray() public pure returns (uint[] memory, uint[3] memory) {
        // memory数组的长度在创建后是固定的。

        // 对于memory修饰的动态数组，可以用new操作符来创建，但是必须声明长度，并且声明后长度不能改变。
        uint[] memory array8 = new uint[](3);
        array8[0] = 1;
        array8[1] = 2;
        array8[2] = 3;
        
        // 数组字面常数 写作表达式形式的数组，用方括号包着来初始化array的一种方式，并且里面每一个元素的type是以第一个元素为准的。
        // 如果一个值没有指定type的话，会根据上下文推断出元素的类型，默认就是最小单位的type，这里默认最小单位类型是uint8。
        // uint[3] memory array9 = [1, 2, 3];
        uint[3] memory array9 = [uint(1), 2, 3];

        // 动态数组新增元素
        // array5.push(0xcc);

        return (array8, array9);
    }

    /* 结构体: 过构造结构体的形式定义新的类型。
       结构体中的元素可以是原始类型，也可以是引用类型；结构体可以作为数组或映射的元素。
    */
    struct Student {
        uint256 id;
        uint256 score;
    }
    Student student; // 初始化一个结构体

    // 赋值
    function initStudent() public {
        // 方法1:在函数中创建一个storage的struct引用
        Student storage _student = student;
        _student.id = 11;
        _student.score = 100;

        // 方法2:直接引用状态变量的struct
        student.id = 1;
        student.score = 80;

        // 方法3:构造函数式
        student = Student(3, 90);

        // 方法4:key value
        student = Student({id: 4, score: 60});
    }
}