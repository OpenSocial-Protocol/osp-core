// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {OspDataTypes} from './OspDataTypes.sol';

library OspEvents {
    event OSPInitialized(
        string name,
        string symbol,
        address followSBTImpl,
        address joinNFTImpl,
        address communityNFT,
        address communityAccountProxy,
        uint256 timestamp
    );

    /**
     * @dev Emitted when the osp state is set.
     *
     * @param caller The caller who set the state.
     * @param prevState The previous protocol state, an enum of either `Paused`, `PublishingPaused` or `Unpaused`.
     * @param newState The newly set state, an enum of either `Paused`, `PublishingPaused` or `Unpaused`.
     * @param timestamp The current block timestamp.
     */
    event StateSet(
        address indexed caller,
        OspDataTypes.ProtocolState indexed prevState,
        OspDataTypes.ProtocolState indexed newState,
        uint256 timestamp
    );

    event BaseURISet(string communityNFTBaseURI, uint256 timestamp);

    /**
     * @dev Emitted when a app is added to or removed from the whitelist.
     *
     * @param app The address of the app.
     * @param whitelisted Whether or not the reaction is being added to the whitelist.
     * @param timestamp The current block timestamp.
     */
    event AppWhitelisted(address indexed app, bool indexed whitelisted, uint256 timestamp);

    /**
     * @dev Emitted when a super community creator is added to or removed from the whitelist.
     *
     * @param superCommunityCreator The address of the super community creator.
     * @param whitelisted Whether or not the super community creator is being added to the whitelist.
     * @param timestamp The current block timestamp.
     */
    event SuperCommunityCreatorWhitelisted(
        address indexed superCommunityCreator,
        bool indexed whitelisted,
        uint256 timestamp
    );

    event TokenWhitelisted(address indexed token, bool indexed whitelisted, uint256 timestamp);

    /**
     * @dev Emitted when add or remove a reserve community handle.
     *
     * @param handleHash The hash of the handle to add or remove.
     * @param handle The handle to add or remove.
     * @param isReserved Whether or not the handle is being added to the reserve list.
     * @param timestamp The current block timestamp.
     */
    event CommunityHandleReserve(
        bytes32 indexed handleHash,
        bool indexed isReserved,
        string handle,
        uint256 timestamp
    );

    /**
     * @dev Emitted when a profile is created.
     *
     * @param profileId The newly created profile's token ID.
     * @param to The address receiving the profile with the given profile ID.
     * @param handle The handle set for the profile.
     * @param followCondition The profile's newly set follow condition. This CAN be the zero address.
     * @param timestamp The current block timestamp.
     */
    event ProfileCreated(
        uint256 indexed profileId,
        address indexed to,
        string handle,
        address followCondition,
        uint256 inviter,
        bytes ctx,
        uint256 timestamp
    );

    /**
     * @dev Emitted when a dispatcher is set for a specific profile.
     *
     * @param profileId The token ID of the profile for which the dispatcher is set.
     * @param dispatcher The dispatcher set for the given profile.
     * @param timestamp The current block timestamp.
     */
    event DispatcherSet(uint256 indexed profileId, address indexed dispatcher, uint256 timestamp);

    /**
     * @dev Emitted when a profile's follow condition is set.
     *
     * @param profileId The profile's token ID.
     * @param followCondition The profile's newly set follow condition. This CAN be the zero address.
     * @param timestamp The current block timestamp.
     */
    event FollowConditionSet(uint256 indexed profileId, address followCondition, uint256 timestamp);

    /**
     * @dev Emitted when a FollowSBT clone is deployed using a lazy deployment pattern.
     *
     * @param profileId The token ID of the profile to which this FollowSBT is associated.
     * @param followSBT The address of the newly deployed FollowSBT clone.
     * @param timestamp The current block timestamp.
     */
    event FollowSBTDeployed(
        uint256 indexed profileId,
        address indexed followSBT,
        uint256 timestamp
    );

    /**
     * @dev Emitted when a profile is updated.
     *
     * @param follower The address updating the profile.
     * @param followerProfileId The token ID of the profile updating the profile.
     * @param profileId The token ID of the profile being updated.
     * @param followConditionData The data passed to the follow condition.
     * @param timestamp The current block timestamp.
     */
    event Followed(
        address indexed follower,
        uint256 indexed followerProfileId,
        uint256 profileId,
        bytes followConditionData,
        bytes ctx,
        uint256 timestamp
    );

    /**
     * @dev Emitted upon a successful follow action.
     */
    event BatchFollowed(
        address indexed follower,
        uint256 followerProfileId,
        uint256[] profileIds,
        bytes[] followConditionDatas,
        bytes ctx,
        uint256 timestamp
    );

    /**
     * @dev Emitted via callback when a FollowSBT is transferred.
     *
     * @param profileId The token ID of the profile associated with the FollowSBT being transferred.
     * @param followSBTId The FollowSBT being transferred's token ID.
     * @param from The address the FollowSBT is being transferred from.
     * @param to The address the FollowSBT is being transferred to.
     * @param timestamp The current block timestamp.
     */
    event FollowSBTTransferred(
        uint256 indexed profileId,
        uint256 indexed followSBTId,
        address from,
        address to,
        uint256 timestamp
    );

    /**
     * @dev Emitted via callback when a communityNFT is transferred.
     *
     * @param communityId The token ID of the community associated with the communityNFT being transferred.
     * @param from The address the communityNFT is being transferred from.
     * @param to The address the communityNFT is being transferred to.
     * @param timestamp The current block timestamp.
     */
    event CommunityNFTTransferred(
        uint256 indexed communityId,
        address from,
        address to,
        uint256 timestamp
    );

    /**
     * @dev Emitted via callback when a JoinNFT is transferred.
     *
     * @param joinNFTId The token ID of the profile associated with the JoinNFT being transferred.
     * @param from The address the JoinNFT is being transferred from.
     * @param to The address the JoinNFT is being transferred to.
     * @param timestamp The current block timestamp.
     */
    event JoinNFTTransferred(
        uint256 indexed communityId,
        uint256 indexed joinNFTId,
        address from,
        address to,
        uint256 timestamp
    );

    /**
     * @dev Emitted when a newly deployed follow NFT is initialized.
     *
     * @param profileId The token ID of the profile connected to this follow NFT.
     * @param timestamp The current block timestamp.
     */
    event FollowSBTInitialized(uint256 indexed profileId, uint256 timestamp);

    /**
     * @dev Emitted when a newly deployed join NFT is initialized.
     *
     * @param communityId The unique ID of the community mapped to this collect NFT.
     * @param timestamp The current block timestamp.
     */
    event JoinNFTInitialized(uint256 indexed communityId, uint256 timestamp);

    /**
     * @dev Emitted when a JoinNFT clone is deployed using a lazy deployment pattern.
     *
     * @param communityId The unique ID of the community mapped to this join NFT.
     * @param joinNFT The address of the newly deployed joinNFT clone.
     * @param timestamp The current block timestamp.
     */
    event JoinNFTDeployed(uint256 indexed communityId, address indexed joinNFT, uint256 timestamp);

    /**
     * @dev Emitted when a community is created.
     *
     * @param communityId The token ID of the community being created.
     * @param to The address receiving the community with the given community ID.
     * @param handle The handle set for the community.
     * @param communityConditionAndData Conditions for creating the community.
     * @param joinCondition The community's newly set join condition. This CAN be the zero address.
     * @param joinNFT The community's newly set join NFT.
     */
    event CommunityCreated(
        uint256 indexed communityId,
        address indexed to,
        string handle,
        bytes communityConditionAndData,
        address joinCondition,
        address joinNFT,
        string[] tags,
        bytes ctx,
        uint256 timestamp
    );

    /**
     * @dev Emitted when you join a community.
     *
     * @param joiner The address joining the community.
     * @param joinerProfileId The token ID of the profile joining the community.
     * @param communityId The token ID of the community being joined.
     * @param joinConditionData The data passed to the join condition.
     * @param ctx The context passed to the join condition.
     */
    event Joined(
        address indexed joiner,
        uint256 joinerProfileId,
        uint256 communityId,
        bytes joinConditionData,
        bytes ctx,
        uint256 timestamp
    );

    /**
     * @dev Emitted when a batch of communities are joined.
     */
    event BatchJoined(
        address indexed joiner,
        uint256 joinerProfileId,
        uint256[] communityIds,
        bytes[] joinConditionDatas,
        bytes ctx,
        uint256 timestamp
    );

    /**
     * @dev Emitted when a community's join condition is set.
     *
     * @param communityId The community's token ID.
     * @param joinCondition The community's newly set join condition. This CAN be the zero address.
     * @param timestamp The current block timestamp.
     */
    event JoinConditionSet(uint256 indexed communityId, address joinCondition, uint256 timestamp);

    event ActivityCreated(
        uint256 indexed profileId,
        uint256 indexed contentId,
        uint256 communityId,
        string contentURI,
        address extension,
        address referenceCondition,
        bytes ctx,
        uint256 timestamp
    );

    event CommentCreated(
        uint256 indexed profileId,
        uint256 indexed contentId,
        uint256 communityId,
        string contentURI,
        uint256 referencedProfileId,
        uint256 referencedContentId,
        address referenceCondition,
        bytes ctx,
        uint256 timestamp
    );

    event OpenReactionCreated(
        uint256 indexed profileId,
        uint256 indexed referencedProfileId,
        uint256 indexed referencedContentId,
        uint256 communityId,
        address openReaction,
        bytes openReactionData,
        bytes ctx,
        uint256 timestamp
    );

    event MegaphoneCreated(
        uint256 indexed megaphoneId,
        uint256 indexed referencedProfileId,
        uint256 indexed referencedContentId,
        uint256 profileId,
        string[] tags,
        uint256 startTime,
        uint256 duration,
        address currency,
        uint256 amount,
        bytes ctx,
        uint256 timestamp
    );

    event ERC6551AccountImplSet(address accountImpl, uint256 timestamp);
}
