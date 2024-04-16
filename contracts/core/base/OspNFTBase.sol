// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {ERC721BurnableUpgradeable} from '@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721BurnableUpgradeable.sol';
import {ERC721EnumerableUpgradeable} from '@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol';
import {ERC721Upgradeable} from '@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol';

/**
 * @title OspNFTBase
 * @author OpenSocial Protocol
 *
 * @dev This is an abstract base contract to be inherited by other OpenSocial Protocol NFTs, it includes
 * the ERC721EnumerableUpgradeable and ERC721BurnableUpgradeable.
 */
abstract contract OspNFTBase is ERC721EnumerableUpgradeable, ERC721BurnableUpgradeable {
    function _initialize(string memory name, string memory symbol) internal initializer {
        __ERC721_init(name, symbol);
    }

    function _update(
        address to,
        uint256 tokenId,
        address auth
    )
        internal
        override(ERC721EnumerableUpgradeable, ERC721Upgradeable)
        returns (address previousOwner)
    {
        previousOwner = ERC721EnumerableUpgradeable._update(to, tokenId, auth);
        _afterTokenTransfer(previousOwner, to, tokenId);
    }

    function _afterTokenTransfer(address from, address to, uint256 tokenId) internal virtual {}

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC721EnumerableUpgradeable, ERC721Upgradeable) returns (bool) {
        return ERC721EnumerableUpgradeable.supportsInterface(interfaceId);
    }

    function _increaseBalance(
        address account,
        uint128 amount
    ) internal virtual override(ERC721EnumerableUpgradeable, ERC721Upgradeable) {
        ERC721EnumerableUpgradeable._increaseBalance(account, amount);
    }
}
