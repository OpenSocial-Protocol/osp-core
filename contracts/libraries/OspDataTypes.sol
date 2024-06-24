// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

/**
 * @title OspDataTypes
 * @author OpenSocial Protocol
 *
 * @dev The OspDataTypes library contains data types used throughout the OpenSocial Protocol.
 */
library OspDataTypes {
    bytes32 internal constant EIP712_DOMAIN_TYPEHASH =
        keccak256(
            'EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)'
        );
    bytes32 internal constant CREATE_ACTIVITY_WITH_SIG_TYPEHASH =
        keccak256(
            'CreateActivityWithSig(uint256 profileId,uint256 communityId,string contentURI,bytes extensionInitCode,bytes referenceConditionInitCode,bytes ctx,uint256 nonce,uint256 deadline)'
        );

    bytes32 internal constant CREATE_OPEN_REACTION_WITH_SIG_TYPEHASH =
        keccak256(
            'CreateOpenReactionWithSig(uint256 profileId,uint256 communityId,uint256 referencedProfileId,uint256 referencedContentId,bytes reactionAndData,bytes referenceConditionData,bytes ctx,uint256 nonce,uint256 deadline)'
        );

    bytes32 internal constant CREATE_COMMENT_WITH_SIG_TYPEHASH =
        keccak256(
            'CreateCommentWithSig(uint256 profileId,uint256 communityId,string contentURI,uint256 referencedProfileId,uint256 referencedContentId,bytes referenceConditionInitCode,bytes referenceConditionData,bytes ctx,uint256 nonce,uint256 deadline)'
        );
    /*///////////////////////////////////////////////////////////////
                        Common Type
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev An enum containing the different states the protocol can be in, limiting certain actions.
     *
     * @param Unpaused The fully unpaused state.
     * @param PublishingPaused The state where only content creation functions are paused.
     * @param Paused The fully paused state.
     */
    enum ProtocolState {
        Unpaused,
        PublishingPaused,
        Paused
    }

    /**
     * @dev A struct containing the necessary information to reconstruct an EIP-712 typed data signature.
     *
     * @param signature Signature
     * @param deadline The signature's deadline
     */
    struct EIP712Signature {
        address signer;
        bytes signature;
        uint256 deadline;
    }

    /*///////////////////////////////////////////////////////////////
                        Storage Struct
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev A struct containing profile data.
     *
     * @param contentCount The number of publications made to this profile.
     * @param followCondition The address of the current follow condition in use by this profile, can be empty.
     * @param followSBT The address of the FollowSBT associated with this profile, can be empty..
     * @param handle The profile's associated handle.
     * @param owner The profile's owner.
     * @param dispatcher The profile's dispatcher.
     * @param mintTimestamp The timestamp at which this profile was minted.
     */
    struct ProfileStruct {
        uint256 contentCount;
        address followCondition;
        address followSBT;
        string handle;
        address owner;
        uint96 mintTimestamp;
        uint256 inviter;
    }

    /**
     * @dev A struct containing community data.
     * @param handle The community's associated handle.
     * @param joinCondition The address of the current join condition in use by this community, can be empty.
     * @param joinNFT The address of the JoinNFT associated with this community.
     */
    struct CommunityStruct {
        string handle;
        address joinCondition;
        address joinNFT;
    }

    struct ContentStruct {
        uint256 communityId;
        uint256 referencedProfileId;
        uint256 referencedContentId;
        string contentURI;
        address extension;
        address referenceCondition;
    }

    struct PluginStruct {
        bool isEnable;
        address tokenAddress;
        uint256 amount;
    }

    /*///////////////////////////////////////////////////////////////
                        Call Params
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev A struct containing the parameters required for the `createProfile()` function.
     *
     * @param handle The handle to set for the profile, must be unique and non-empty.
     * @param followCondition The follow condition to use, can be the zero address.
     * @param followConditionInitData The follow condition initialization data, if any.
     */
    struct CreateProfileData {
        string handle;
        bytes followConditionInitCode;
        uint256 inviter;
        bytes ctx;
    }

    /**
     * Create Activity Data
     * @param profileId The profile id of the creator.
     * @param communityId The community id of the content, if zero then it's a global content.
     * @param contentURI The URI of the content.
     * @param extensionInitCode If set, the extension will be set.
     * @param referenceConditionInitCode If set,the reference condition will be set. contains 20 bytes of condition address, followed by calldata.
     * @param ctx The context data.
     */
    struct CreateActivityData {
        uint256 profileId;
        uint256 communityId;
        string contentURI;
        bytes extensionInitCode;
        bytes referenceConditionInitCode;
        bytes ctx;
    }

    /**
     * Create Comment Data
     * @param profileId The profile id of the commenter.
     * @param communityId
     * @param contentURI
     * @param referencedProfileId
     * @param referencedContentId
     * @param referenceConditionInitCode If set,the reference condition will be set. contains 20 bytes of condition address, followed by calldata.
     * @param referenceConditionData The data passed to the reference condition.
     * @param ctx The context data.
     */
    struct CreateCommentData {
        uint256 profileId;
        uint256 communityId;
        string contentURI;
        uint256 referencedProfileId;
        uint256 referencedContentId;
        bytes referenceConditionInitCode;
        bytes referenceConditionData;
        bytes ctx;
    }

    /**
     * @dev A struct containing the parameters required for the `createMegaphone()` function.
     *
     * @param profileId The profile ID of the user creating the megaphone.
     * @param referencedProfileId The profile ID of the user who created the content being megaphoned.
     * @param referencedContentId The content ID being megaphoned.
     * @param tags The tags to associate with the megaphone.
     * @param startTime The start time of the megaphone.
     * @param duration The duration of the megaphone.
     * @param currency The currency to use for the megaphone.
     * @param amount The amount to pay for the megaphone.
     * @param ctx The context data.
     */
    struct CreateMegaphoneData {
        uint256 profileId;
        uint256 referencedProfileId;
        uint256 referencedContentId;
        string[] tags;
        uint256 startTime;
        uint256 duration;
        address currency;
        uint256 amount;
        bytes ctx;
    }

    /**
     * @dev A struct containing the parameters required for the `createOpenReaction()` function.
     *
     * @param profileId The profile ID of the user creating the reaction.
     * @param communityId The community ID of the content being reacted to.
     * @param referencedProfileId The profile ID of the user who created the content being reacted to.
     * @param referencedContentId The content ID being reacted to.
     * @param reactionAndData The reaction and data to use.
     * @param referenceConditionData The reference condition data to use.
     * @param ctx The context data.
     */
    struct CreateOpenReactionData {
        uint256 profileId;
        uint256 communityId;
        uint256 referencedProfileId;
        uint256 referencedContentId;
        uint256 reactionValue;
        bytes reactionAndData;
        bytes referenceConditionData;
        bytes ctx;
    }

    /**
     * @dev A struct containing the parameters required for the `createCommunity()` function.
     *
     * @param handle The handle to set for the community, must be unique and non-empty.
     * @param communityConditionAndData The community condition and data to use, can be the zero address.
     * @param joinConditionInitCode The join condition initialization data, if any.
     * @param tags The tags to associate with the community.
     * @param ctx The context data.
     */
    struct CreateCommunityData {
        string handle;
        bytes communityConditionAndData;
        bytes joinConditionInitCode;
        string[] tags;
        bytes ctx;
    }

    /**
     * @dev A struct containing the parameters required for the `follow()` function.
     *
     * @param profileId The profile token ID to follow.
     * @param data The data passed to the follow condition.
     * @param ctx The context data.
     */
    struct FollowData {
        uint256 profileId;
        bytes data;
        bytes ctx;
    }

    /**
     * @dev A struct containing the parameters required for the `batchFollow()` function.
     *
     * @param profileIds The array of profile token IDs to follow.
     * @param datas The array of follow condition data parameters to pass to each profile's follow condition.
     * @param ctx The context data.
     */
    struct BatchFollowData {
        uint256[] profileIds;
        bytes[] datas;
        uint256[] values;
        bytes ctx;
    }

    /**
     * @dev A struct containing the parameters required for the `join()` function.
     *
     * @param communityId The ID of the community to join.
     * @param data The data passed to the join condition.
     * @param ctx The context data.
     */
    struct JoinData {
        uint256 communityId;
        bytes data;
        bytes ctx;
    }

    /**
     * @dev A struct containing the parameters required for the `batchJoin()` function.
     * @param communityIds The array of community token IDs to join.
     * @param datas The array of join condition data parameters to pass to each community's join condition.
     * @param values The array of values to pass to each community's join condition.
     * @param ctx The context data.
     */
    struct BatchJoinData {
        uint256[] communityIds;
        bytes[] datas;
        uint256[] values;
        bytes ctx;
    }

    struct RoyaltyInfo {
        uint128 royaltyFraction;
        uint128 ospTreasureFraction;
    }
}
