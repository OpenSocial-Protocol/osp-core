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
     * @dev Sets the admin role for the specified account.
     *
     * @param account The account to set the admin role for.
     * @param enable A boolean indicating whether to enable or disable the admin role.
     *
     * @return bool A boolean indicating whether the operation was successful.
     */
    function setAdmin(address account, bool enable) external returns (bool);

    /**
     * @dev Sets the mods role for the specified account.
     *
     * @param account The account to set the mods role for.
     * @param enable A boolean indicating whether to enable or disable the mods role.
     *
     * @return bool A boolean indicating whether the operation was successful.
     */
    function setModerator(address account, bool enable) external returns (bool);

    /**
     * @dev Sets the member level for the specified account.
     *
     * @param account The account to set the member level for.
     * @param level The level to set for the account.
     *
     * @return bool A boolean indicating whether the operation was successful.
     */
    function setMemberLevel(address account, uint256 level) external returns (bool);

    /**
     * @dev Adds or removes the specified account from the block list.
     *
     * @param account The account to add or remove from the block list.
     * @param enable A boolean indicating whether to add or remove the account from the block list.
     *
     * @return bool A boolean indicating whether the operation was successful.
     */
    function setBlockList(address account, bool enable) external returns (bool);

    /**
     * @dev Returns the source community pointer mapped to this collect NFT.
     *
     * @return communityId.
     */
    function getSourceCommunityPointer() external view returns (uint256);

    /**
     * @dev Returns `true` if `account` has been granted the `role`.
     */
    function hasOneRole(uint256 roles, address account) external view returns (bool);

    /**
     * @dev Returns `true` if `account` has been granted all `role`.
     */
    function hasAllRole(uint256 roles, address account) external view returns (bool);

    /**
     * @dev Returns the member level of the account.
     */
    function getMemberLevel(address account) external view returns (uint256);

    /**
     * @dev Returns the block status of the account.
     */
    function isBlock(address account) external view returns (bool);
}
