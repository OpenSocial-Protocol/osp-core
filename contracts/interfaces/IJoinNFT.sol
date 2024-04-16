// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

/**
 * @title IJoinNFT
 * @author OpenSocial Protocol
 *
 * @dev This is the interface for the JoinNFT contract. Deploy this NFT contract when creating the community
 */
interface IJoinNFT {
    /**
     * @dev Initializes the Join NFT, setting the feed as the privileged minter, storing the collected content pointer
     * and initializing the name and symbol in the OspNFTBase contract.
     *
     * @param communityId The community unique ID  this JoinNFT points to.
     * @param name The name to set for this NFT.
     * @param symbol The symbol to set for this NFT.
     */
    function initialize(uint256 communityId, string calldata name, string calldata symbol) external;

    /**
     * @dev Mints a join NFT to the specified address. This can only be called by the osp, and is called
     * upon collection.
     *
     * @param to The address to mint the NFT to.
     *
     * @return uint256 An interger representing the minted token ID.
     */
    function mint(address to) external returns (uint256);

    /**
     * @dev Returns the source community pointer mapped to this collect NFT.
     *
     * @return communityId.
     */
    function getSourceCommunityPointer() external view returns (uint256);
}
