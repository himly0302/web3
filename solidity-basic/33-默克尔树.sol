// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./31-ERC721/ERC721.sol";

// 生成Merkle Tree: https://lab.miguelmota.com/merkletreejs/example/
library MerkleProof {

    // 当通过`proof`和`leaf`重建出的`root`与给定的`root`相等时，返回`true`，数据有效。
    // 在重建时，叶子节点对和元素对都是排序过的。

    function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {
        return processProof(proof, leaf) == root;
    }

    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
        return computedHash;
    }

    function _hashPair(bytes32 a, bytes32 b) private pure returns (bytes32) {
        return a < b ? keccak256(abi.encodePacked(a, b)) : keccak256(abi.encodePacked(b, a));
    }
}

// 一份拥有800个地址的白名单，更新一次所需的gas fee很容易超过1个ETH。
// 而由于Merkle Tree验证时，leaf和proof可以存在后端，链上仅需存储一个root的值，非常节省gas，项目方经常用它来发放白名单。
contract MerkleTree is ERC721 {
    bytes32 immutable public root;
    mapping(address => bool) public mintedAddress;

    constructor(string memory name, string memory symbol, bytes32 merkleroot) ERC721(name, symbol) {
        root = merkleroot;
    }

    function mint(address account, uint256 tokenId, bytes32[] calldata proof) external {
        require(_verify(_leaf(account), proof), "Invalid merkle proof"); // Merkle检验通过(校验地址是否为白名单)
        require(!mintedAddress[account], "Already minted!");

        mintedAddress[account] = true;
        _mint(account, tokenId);
    }

    // 计算Merkle树叶子的哈希值
    function _leaf(address account) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(account));
    }

    // Merkle树验证
    function _verify(bytes32 leaf, bytes32[] memory proof) internal view returns (bool) {
        return MerkleProof.verify(proof, root, leaf);
    }
}


// 例子 [optimism]
// merkleroot = 0xeeefd63003e0e702cb41cd0043015a6e26ddb38073cc6ffeb0ba3e808ba8c097
// account = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
// proof = [   "0x999bf57501565dbd2fdcea36efa2b9aef8340a8901e3459f4a4c926275d36cdb",   "0x4726e4102af77216b09ccd94f40daa10531c87c4d60bba7f3b3faf5ff9f19b3c" ]