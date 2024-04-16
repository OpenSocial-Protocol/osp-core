// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {OspNFTBase} from './OspNFTBase.sol';
import {OspErrors} from '../../libraries/OspErrors.sol';

/**
 * @title OspSBTBase
 * @author OpenSocial Protocol
 *
 * @dev This is an abstract base contract to be inherited by other OpenSocial Protocol SBTs, it includes
 * the ERC721EnumerableUpgradeable and ERC721BurnableUpgradeable.
 * SBTs are not transferable, they can only be minted and burned.
 */
abstract contract OspSBTBase is OspNFTBase {
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 /*tokenId*/
    ) internal virtual override {
        if (from != address(0) && to != address(0)) {
            revert OspErrors.SBTTransferNotAllowed();
        }
        if (from == address(0) && to != address(0) && balanceOf(to) > 1) {
            revert OspErrors.SBTTokenAlreadyExists();
        }
    }
}
