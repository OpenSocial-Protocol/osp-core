// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {IFollowSBT} from '../../../contracts/interfaces/IFollowSBT.sol';
import '../../../contracts/core/base/OspNFTBase.sol';

/**
 * @dev This is a helper contract used for internal testing.
 *
 * NOTE: This contract is not meant to be deployed and is unsafe for use.
 */
contract MockNFTBase is OspNFTBase {
    uint256 counter;

    constructor(string memory name, string memory symbol) {
        super._initialize(name, symbol);
    }

    function mintTo(address to) public {
        _mint(to, ++counter);
    }
}
