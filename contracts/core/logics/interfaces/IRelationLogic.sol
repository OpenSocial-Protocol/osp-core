// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import '../../../libraries/OspDataTypes.sol';

/**
 * @title IReactionLogic
 * @author OpenSocial Protocol
 *
 * @dev This is the interface for the ReactionLogic contract.
 */
interface IRelationLogic {
    /**
     * @dev Follow a profile, executing the profile's follow condition logic (if any) and minting followSBTs to the caller.
     *
     * @return uint256 An integer representing the minted follow SBTs token ID.
     */
    function follow(OspDataTypes.FollowData calldata vars) external payable returns (uint256);

    /**
     * @dev Follow a profile, executing the profile's follow condition logic (if any) and minting followSBTs to the caller.
     *  NOTE: Both the `profileIds` and `datas` arrays must be of the same length, regardless if the profiles do not have a follow condition set.
     *
     * @return uint256 An integer representing the minted follow SBTs token ID.
     */
    function batchFollow(
        OspDataTypes.BatchFollowData calldata vars
    ) external payable returns (uint256[] memory);

    /**
     * @dev Join a community, executing the community's join condition logic (if any) and minting joinNFTs to the caller.
     *
     * @return uint256 An integer representing the minted join NFTs token ID.
     */
    function join(OspDataTypes.JoinData calldata vars) external payable returns (uint256);

    /**
     * @dev Join a community, executing the community's join condition logic (if any) and minting joinNFTs to the caller.
     *  NOTE: Both the `communityIds` and `datas` arrays must be of the same length, regardless if the communities do not have a join condition set.
     *
     * @return uint256 An integer representing the minted join NFTs token ID.
     */
    function batchJoin(
        OspDataTypes.BatchJoinData calldata vars
    ) external payable returns (uint256[] memory);

    /**
     * @dev Returns the URI for a followSBT token.
     *
     * @param profileId  The token ID of the profile associated with the follow SBT.
     * @param tokenId  The followSBTId being transferred's token ID.
     */
    function getFollowSBTURI(
        uint256 profileId,
        uint256 tokenId
    ) external view returns (string memory);

    /**
     * @dev Returns addr is follower for a gave profile.
     *
     * @param profileId The profileID to query.
     * @param addr The address of the follower.
     */
    function isFollow(uint256 profileId, address addr) external view returns (bool);

    /**
     * @dev Returns addr is member for a gave community.
     *
     * @param communityId The communityID to query.
     * @param addr The address of the member.
     */
    function isJoin(uint256 communityId, address addr) external view returns (bool);

    /**
     * @dev Returns the URI for a joinNFT token.
     *
     * @param communityId  The communityId associated with the join NFT.
     * @param tokenId  The joinNFTId being transferred's token ID.
     */
    function getJoinNFTURI(
        uint256 communityId,
        uint256 tokenId
    ) external view returns (string memory);

    /**
     *  @dev emit FollowSBTTransaction event to facilitate the monitoring of events.
     *
     * @param profileId The token ID of the profile associated with the follow SBT being transferred.
     * @param followSBTId The followSBTId being transferred's token ID.
     * @param from The address the collectNFT is being transferred from.
     * @param to The address the collectNFT is being transferred to.
     */
    function emitFollowSBTTransferEvent(
        uint256 profileId,
        uint256 followSBTId,
        address from,
        address to
    ) external;

    /**
     * @dev emit JoinNFTTransaction event to facilitate the monitoring of events.
     *
     * @param communityId The communityId associated with the join NFT being transferred.
     * @param joinNFTId The joinNFTId being transferred's token ID.
     * @param from The address the joinNFT is being transferred from.
     * @param to The address the joinNFT is being transferred to.
     */
    function emitJoinNFTTransferEvent(
        uint256 communityId,
        uint256 joinNFTId,
        address from,
        address to
    ) external;

    function emitJoinNFTRoleChangedEvent(
        uint256 communityId,
        address account,
        uint256 role,
        bool enable
    ) external;

    function emitJoinNFTAccountBlockedEvent(
        uint256 communityId,
        address account,
        bool isBlock
    ) external;
}
