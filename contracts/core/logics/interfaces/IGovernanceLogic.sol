// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import '../../../libraries/OspDataTypes.sol';
import '../../base/IERC4906.sol';
import '@openzeppelin/contracts/interfaces/IERC5267.sol';
import '../../../libraries/Constants.sol';
import '@openzeppelin/contracts/access/IAccessControl.sol';

/**
 * @title IGovernanceLogic
 * @author OpenSocial Protocol
 *
 * @dev This is the interface for the GovernanceLogic contract.
 */
interface IGovernanceLogic is IERC4906, IERC5267, IAccessControl {
    /**
     * @dev Initializes the Profile SBT, setting the initial governance address as well as the name and symbol.
     *
     * @param name The name to set for the osp NFT.
     * @param symbol The symbol to set for the osp NFT.
     */
    function initialize(
        string calldata name,
        string calldata symbol,
        address followSBTImpl,
        address joinNFTImpl,
        address communityNFT
    ) external;

    /**
     * @dev Sets the protocol state to either a global pause, a publishing pause or an unpaused state. This function
     * can only be called by the governance address or the emergency admin address.
     *
     * Note that this reverts if the emergency admin calls it if:
     *      1. The emergency admin is attempting to unpause.
     *      2. The emergency admin is calling while the protocol is already paused.
     *
     * @param newState The state to set, as a member of the ProtocolState enum.
     */
    function setState(OspDataTypes.ProtocolState newState) external;

    /**
     *@dev Adds or removes a super community creator from the whitelist. This function can only be called by the current
     * governance address.
     *
     * @param communityCreator The community creator address to add or remove from the whitelist.
     * @param whitelist Whether or not the community creator should be whitelisted.
     */
    function whitelistSuperCommunityCreator(address communityCreator, bool whitelist) external;

    /**
     * @dev Adds or removes a app from the whitelist. This function can only be called by the
     * current governance address.
     *
     * @param app Reaction about the activity.
     * @param whitelist Whether or not the reaction should be whitelisted.
     */
    function whitelistApp(address app, bool whitelist) external;

    /**
     * @dev Adds or removes a ERC20 token from the whitelist. This function can only be called by the current
     * governance address.
     *
     * @param token ERC20 token address
     * @param whitelist whether or not the token should be whitelisted
     */
    function whitelistToken(address token, bool whitelist) external;

    /**
     * @dev Adds or removes a reserve community handle.This function can only be called by the current governance address.
     *
     * @param handle The handle to reserve.
     * @param isReserve Reserve or not the handle should be reserved.
     */
    function reserveCommunityHandle(string calldata handle, bool isReserve) external;

    /**
     * @dev Sets the base URI for NFTs. This function can only be called by the current governance
     * address.
     *
     * @param baseURI The base URI to set.
     */
    function setBaseURI(string calldata baseURI) external;

    function setERC6551AccountImpl(address accountImpl) external;

    /// ************************
    /// *****VIEW FUNCTIONS*****
    /// ************************

    /**
     * @dev Returns whether or not a super community creator is whitelisted.
     *
     * @param communityCreator The address of the super community creator to check.
     *
     * @return bool True if the super community creator is whitelisted, false otherwise.
     */
    function isSuperCommunityCreatorWhitelisted(
        address communityCreator
    ) external view returns (bool);

    function isAppWhitelisted(address app) external view returns (bool);

    /**
     * @dev Returns whether or not a token is whitelisted.
     *
     * @param token The address of the token to check.
     *
     * @return bool True if the the token whitelisted, false otherwise.
     */
    function isTokenWhitelisted(address token) external view returns (bool);

    /**
     * @dev Returns whether or not a community handle is reserved.
     *
     * @param handle The handle to check.
     *
     * @return bool True if the the handle is reserved, false otherwise.
     */
    function isReserveCommunityHandle(string calldata handle) external view returns (bool);

    /**
     * @dev Returns the base URI for the NFTs.
     *
     * @return string The base URI for the NFTs.
     */
    function getBaseURI() external view returns (string memory);

    /**
     * @dev Returns the follow NFT implementation address.
     *
     * @return address The follow NFT implementation address.
     */
    function getFollowSBTImpl() external view returns (address);

    /**
     * @dev Returns the join NFT implementation address.
     *
     * @return address The join NFT implementation address.
     */
    function getJoinNFTImpl() external view returns (address);

    /**
     * @dev Returns the community NFT address.
     *
     * @return address The community NFT address.
     */
    function getCommunityNFT() external view returns (address);

    function getERC6551AccountImpl() external view returns (address);

    /**
     * @dev Returns the current protocol state.
     *
     * @return ProtocolState The Protocol state, an enum, where:
     *      0: Unpaused
     *      1: PublishingPaused
     *      2: Paused
     */
    function getState() external view returns (OspDataTypes.ProtocolState);

    function updateMetadata() external;
}
