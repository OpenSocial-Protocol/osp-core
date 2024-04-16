// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

/**
 * @title IFollowSBT
 * @author OpenSocial Protocol
 *
 * @dev This is the interface for the FollowSBT contract, which is cloned upon the first follow for any profile.
 */
interface IFollowSBT {
    /**
     * @dev Initializes the follow NFT, setting the osp as the privileged minter and storing the associated profile ID.
     *
     * @param profileId The token ID of the profile in the osp associated with this FollowSBT, used for transfer hooks.
     * @param name The name to set for this NFT.
     * @param symbol The symbol to set for this NFT.
     */
    function initialize(uint256 profileId, string calldata name, string calldata symbol) external;

    /**
     * @dev Mints a follow NFT to the specified address. This can only be called by the osp, and is called
     * upon follow.
     *
     * @param to The address to mint the NFT to.
     *
     * @return uint256 An interger representing the minted token ID.
     */
    function mint(address to) external returns (uint256);
}
