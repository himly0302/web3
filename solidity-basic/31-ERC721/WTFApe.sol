// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "./ERC721.sol";
import "./IERC721.sol";

contract WTFApe is ERC721 {
    uint public constant MAX_APES = 10000;

    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {}

    
}