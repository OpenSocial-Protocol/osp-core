// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import '../../../libraries/OspDataTypes.sol';

/**
 * @title ICommunityLogic
 * @author OpenSocial Protocol
 *
 * @dev This is the interface for the ICommunityLogic contract.
 */
interface ICommunityLogic {
    /**
     * @dev Creates a community with the specified parameters, minting a community NFT to the msg sender.
     *
     * @param vars A CreateCommunityData struct containing the needed parameters.
     *
     * @return uint256 An integer representing the community's ID.
     */
    function createCommunity(
        OspDataTypes.CreateCommunityData calldata vars
    ) external payable returns (uint256);

    /**
     * @dev Sets a community's join condition, must be called by the community owner.
     * @param communityId The unique ID of the community to query the join condition for.
     * @param joinConditionInitCode The data to be passed to the join condition for initialization.
     */
    function setJoinCondition(uint256 communityId, bytes calldata joinConditionInitCode) external;

    /**
     * @dev emits a CommunityNFTTransfer event to facilitate the monitoring of events.
     *
     * @param communityId is CommunityNFT being transferred's token ID.
     * @param from The address the collectNFT is being transferred from.
     * @param to The address the collectNFT is being transferred to.
     */
    function emitCommunityNFTTransferEvent(uint256 communityId, address from, address to) external;

    /**
     * @dev Returns the struct with a community.
     *
     * @param communityId The ID of the community.
     *
     * @return string The struct of community.
     */
    function getCommunity(
        uint256 communityId
    ) external view returns (OspDataTypes.CommunityStruct memory);

    /**
     * @dev Returns the joinNFT associated with a given community, if any.
     * @param communityId The unique ID of the community to query the joinNFT for.
     * @return address The joinNFT associated with the given profile.
     */
    function getJoinNFT(uint256 communityId) external view returns (address);

    /**
     * @dev Returns the join condition associated witha  given community, if any.
     * @param communityId The unique ID of the community to query the join condition for.
     * @return address The address of the join condition associated with the given community.
     */
    function getJoinCondition(uint256 communityId) external view returns (address);

    /**
     * @dev Returns the tokenURI associated with a given community, if any.
     *
     * @param communityId The unique ID of the community to query the tokenURI for.
     * @return string The tokenURI associated with the given community.
     */
    function getCommunityTokenURI(uint256 communityId) external view returns (string memory);

    /**
     * @dev Returns the community ID associated with a given community handle, if any.
     *
     * @param handle The handle of the community to query the ID for.
     * @return uint256 The ID of the community associated with the given handle.
     */
    function getCommunityIdByHandle(string calldata handle) external view returns (uint256);

    /**
     * @dev Returns community nft 6551 account address.
     * @param communityId community nft token id
     */
    function getCommunityAccount(uint256 communityId) external view returns (address);

    /**
     * @dev Returns community nft 6551 account address.
     * @param handle community handle.
     */
    function getCommunityAccount(string calldata handle) external view returns (address);
}
