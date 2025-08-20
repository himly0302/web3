// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract HelloControl {


    function isTest(uint _num) public pure {
        if (_num > 3) {} else {}

        for (uint i = 0; i < _num; i++) {}

        uint j = 0; 
        while (j < _num) {}

        do {} while(j < _num);

        
    }
}