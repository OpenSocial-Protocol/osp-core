// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

/**
 * @title ICommunityNFT
 * @author OpenSocial Protocol
 *
 * @dev This is the standard interface for all OSP-compatible CollectConditions.
 */
interface ICommunityNFT {
    /**
     * @dev Mints a collect NFT to the specified address. This can only be called by the osp;
     *
     * @param to The address to mint the NFT to.
     *
     * @return uint256 An interger representing the minted token ID.
     */
    function mint(address to) external returns (uint256);

    /**
     * @dev updates the metadata for the NFT.
     */
    function updateMetadata() external;
}
