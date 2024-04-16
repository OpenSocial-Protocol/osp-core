// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';

contract MockNFT is ERC721 {
    uint256 public counter;

    constructor(string memory name, string memory symbol) ERC721(name, symbol) {}

    function mintTo(address to) public {
        _mint(to, ++counter);
    }
}
