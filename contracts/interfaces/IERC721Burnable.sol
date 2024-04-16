// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {IERC721} from '@openzeppelin/contracts/token/ERC721/IERC721.sol';

/**
 * @title IERC721Burnable
 * @author OpenSocial Protocol
 * @dev This is the interface for all ERC721Burnable contracts.
 */
interface IERC721Burnable is IERC721 {
    /**
     * @dev Burns an NFT, removing it from circulation and essentially destroying it. This function can only
     * be called by the NFT to burn's owner.
     *
     * @param tokenId The token ID of the token to burn.
     */
    function burn(uint256 tokenId) external;
}
