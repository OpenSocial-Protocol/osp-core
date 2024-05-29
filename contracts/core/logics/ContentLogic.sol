// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {IActivityExtension} from '../../interfaces/IActivityExtension.sol';
import {IReferenceCondition} from '../../interfaces/IReferenceCondition.sol';
import {IOpenReaction} from '../../interfaces/IOpenReaction.sol';
import {OspHelpers} from '../../libraries/OspHelpers.sol';
import {OspDataTypes} from '../../libraries/OspDataTypes.sol';
import {Constants} from '../../libraries/Constants.sol';
import {OspErrors} from '../../libraries/OspErrors.sol';
import {OspEvents} from '../../libraries/OspEvents.sol';
import {IContentLogic} from './interfaces/IContentLogic.sol';
import {OspLogicBase} from './OspLogicBase.sol';
import {Payment} from '../../libraries/Payment.sol';
import {IERC721} from '@openzeppelin/contracts/token/ERC721/IERC721.sol';

/**
 * @title ContentLogic
 * @author OpenSocial Protocol
 */
contract ContentLogic is IContentLogic, OspLogicBase {
    /*///////////////////////////////////////////////////////////////
                        Public functions
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IContentLogic
    function createActivity(
        OspDataTypes.CreateActivityData calldata vars
    ) external payable override whenPublishingEnabled returns (uint256 contentId) {
        _validateIsProfileOwner(msg.sender, vars.profileId);
        contentId = _createActivity(vars);
    }

    /// @inheritdoc IContentLogic
    function createActivityWithSig(
        OspDataTypes.CreateActivityData calldata vars,
        OspDataTypes.EIP712Signature calldata sig
    ) external whenPublishingEnabled returns (uint256 contentId) {
        unchecked {
            _validateRecoveredAddress(
                _calculateDigest(
                    keccak256(
                        abi.encode(
                            OspDataTypes.CREATE_ACTIVITY_WITH_SIG_TYPEHASH,
                            vars.profileId,
                            vars.communityId,
                            keccak256(bytes(vars.contentURI)),
                            keccak256(vars.extensionInitCode),
                            keccak256(vars.referenceConditionInitCode),
                            keccak256(vars.ctx),
                            _getProfileStorage()._sigNonces[sig.signer]++,
                            sig.deadline
                        )
                    )
                ),
                sig
            );
        }
        _validateIsProfileOwner(sig.signer, vars.profileId);
        contentId = _createActivity(vars);
    }

    /// @inheritdoc IContentLogic
    function createComment(
        OspDataTypes.CreateCommentData calldata vars
    ) external payable whenPublishingEnabled returns (uint256 contentId) {
        _validateIsProfileOwner(msg.sender, vars.profileId);
        contentId = _createComment(vars);
    }

    /// @inheritdoc IContentLogic
    function createCommentWithSig(
        OspDataTypes.CreateCommentData calldata vars,
        OspDataTypes.EIP712Signature calldata sig
    ) external whenPublishingEnabled returns (uint256 contentId) {
        unchecked {
            _validateRecoveredAddress(
                _calculateDigest(
                    keccak256(
                        abi.encode(
                            OspDataTypes.CREATE_COMMENT_WITH_SIG_TYPEHASH,
                            vars.profileId,
                            vars.communityId,
                            keccak256(bytes(vars.contentURI)),
                            vars.referencedProfileId,
                            vars.referencedContentId,
                            keccak256(vars.referenceConditionInitCode),
                            keccak256(vars.referenceConditionData),
                            keccak256(vars.ctx),
                            _getProfileStorage()._sigNonces[sig.signer]++,
                            sig.deadline
                        )
                    )
                ),
                sig
            );
        }
        _validateIsProfileOwner(sig.signer, vars.profileId);
        contentId = _createComment(vars);
    }

    /// @inheritdoc IContentLogic
    function createOpenReaction(
        OspDataTypes.CreateOpenReactionData calldata vars
    ) external payable whenPublishingEnabled {
        _validateIsProfileOwner(msg.sender, vars.profileId);
        _createOpenReaction(vars);
    }

    /// @inheritdoc IContentLogic
    function createOpenReactionWithSig(
        OspDataTypes.CreateOpenReactionData calldata vars,
        OspDataTypes.EIP712Signature calldata sig
    ) external whenPublishingEnabled {
        unchecked {
            _validateRecoveredAddress(
                _calculateDigest(
                    keccak256(
                        abi.encode(
                            OspDataTypes.CREATE_OPEN_REACTION_WITH_SIG_TYPEHASH,
                            vars.profileId,
                            vars.communityId,
                            vars.referencedProfileId,
                            vars.referencedContentId,
                            keccak256(vars.reactionAndData),
                            keccak256(vars.referenceConditionData),
                            keccak256(vars.ctx),
                            _getProfileStorage()._sigNonces[sig.signer]++,
                            sig.deadline
                        )
                    )
                ),
                sig
            );
        }
        _validateIsProfileOwner(sig.signer, vars.profileId);
        _createOpenReaction(vars);
    }

    /// @inheritdoc IContentLogic
    function createMegaphone(
        OspDataTypes.CreateMegaphoneData calldata vars
    ) external payable whenPublishingEnabled returns (uint256 megaphoneId) {
        _validateIsProfileOwner(msg.sender, vars.profileId);
        return _createMegaphone(vars);
    }

    /*///////////////////////////////////////////////////////////////
                        Public Read functions
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IContentLogic
    function getContentCount(uint256 profileId) external view override returns (uint256) {
        return _getProfileStorage()._profileById[profileId].contentCount;
    }

    /// @inheritdoc IContentLogic
    function getContent(
        uint256 profileId,
        uint256 contentId
    ) external view override returns (OspDataTypes.ContentStruct memory) {
        return _getContentStorage()._contentByIdByProfile[profileId][contentId];
    }

    /// @inheritdoc IContentLogic
    function getCommunityIdByContent(
        uint256 profileId,
        uint256 contentId
    ) external view returns (uint256) {
        return _getContentStorage()._contentByIdByProfile[profileId][contentId].communityId;
    }

    /*///////////////////////////////////////////////////////////////
                        Internal functions
    //////////////////////////////////////////////////////////////*/

    function _createActivity(
        OspDataTypes.CreateActivityData calldata vars
    ) internal returns (uint256 contentId) {
        if (bytes(vars.contentURI).length == 0) {
            revert OspErrors.InvalidContentURI();
        }
        uint256 profileId = vars.profileId;
        _validateCallerIsJoinCommunity(profileId, vars.communityId);

        contentId = ++_getProfileStorage()._profileById[profileId].contentCount;
        OspDataTypes.ContentStruct storage activityContent = _getContentStorage()
            ._contentByIdByProfile[vars.profileId][contentId];
        //init activity
        activityContent.contentURI = vars.contentURI;
        activityContent.communityId = vars.communityId;

        address extension;
        if (vars.extensionInitCode.length != 0) {
            extension = _initActivityExtension(
                profileId,
                contentId,
                vars.extensionInitCode,
                msg.value
            );
            activityContent.extension = extension;
        }

        address referenceCondition;
        if (vars.referenceConditionInitCode.length != 0) {
            referenceCondition = _initReferenceCondition(
                vars.profileId,
                contentId,
                vars.communityId,
                vars.referenceConditionInitCode
            );
            activityContent.referenceCondition = referenceCondition;
        }

        emit OspEvents.ActivityCreated(
            vars.profileId,
            contentId,
            vars.communityId,
            vars.contentURI,
            extension,
            referenceCondition,
            vars.ctx,
            block.timestamp
        );
    }

    function _createComment(
        OspDataTypes.CreateCommentData calldata vars
    ) internal returns (uint256 contentId) {
        if (bytes(vars.contentURI).length == 0) {
            revert OspErrors.InvalidContentURI();
        }
        _validateCallerIsJoinCommunity(vars.profileId, vars.communityId);
        _validateReferenced(
            vars.profileId,
            vars.communityId,
            vars.referencedProfileId,
            vars.referencedContentId,
            vars.referenceConditionData,
            msg.value
        );

        contentId = ++_getProfileStorage()._profileById[vars.profileId].contentCount;
        OspDataTypes.ContentStruct storage commentContent = _getContentStorage()
            ._contentByIdByProfile[vars.profileId][contentId];

        commentContent.referencedProfileId = vars.referencedProfileId;
        commentContent.referencedContentId = vars.referencedContentId;
        commentContent.contentURI = vars.contentURI;
        commentContent.communityId = vars.communityId;

        address referenceCondition;
        if (vars.referenceConditionInitCode.length != 0) {
            referenceCondition = _initReferenceCondition(
                vars.profileId,
                contentId,
                vars.communityId,
                vars.referenceConditionInitCode
            );
            commentContent.referenceCondition = referenceCondition;
        }

        emit OspEvents.CommentCreated(
            vars.profileId,
            contentId,
            vars.communityId,
            vars.contentURI,
            vars.referencedProfileId,
            vars.referencedContentId,
            referenceCondition,
            vars.ctx,
            block.timestamp
        );
    }

    function _createMegaphone(
        OspDataTypes.CreateMegaphoneData calldata vars
    ) internal returns (uint256 megaphoneId) {
        if (vars.tags.length > Constants.MAX_TAGS_NUMBER) revert OspErrors.TooManyTags();

        ContentStorage storage contentStorage = _getContentStorage();

        if (
            vars.referencedContentId == 0 ||
            _getProfileStorage()._profileById[vars.referencedProfileId].contentCount <
            vars.referencedContentId
        ) {
            revert OspErrors.ContentDoesNotExist();
        }

        if (
            contentStorage
            ._contentByIdByProfile[vars.referencedProfileId][vars.referencedContentId]
                .referenceCondition != address(0)
        ) {
            revert OspErrors.ContentNotPublic();
        }
        if (!_getGovernanceStorage()._tokenWhitelisted[vars.currency]) {
            revert OspErrors.InvalidToken();
        }
        megaphoneId = ++_getContentStorage()._megaphoneCount;
        address treasure = _getGovernanceStorage()._treasure;
        if (treasure == address(0)) revert OspErrors.InvalidTreasure();
        if (vars.currency == address(0)) {
            if (msg.value != vars.amount) revert OspErrors.DataMismatch();
            Payment.payNative(treasure, vars.amount);
        } else {
            Payment.payERC20(vars.currency, msg.sender, treasure, vars.amount);
        }
        emit OspEvents.MegaphoneCreated(
            megaphoneId,
            vars.referencedProfileId,
            vars.referencedContentId,
            vars.profileId,
            vars.tags,
            vars.startTime,
            vars.duration,
            vars.currency,
            vars.amount,
            vars.ctx,
            block.timestamp
        );
    }

    function _createOpenReaction(OspDataTypes.CreateOpenReactionData calldata vars) internal {
        _validateCallerIsJoinCommunity(vars.profileId, vars.communityId);
        if (msg.value < vars.reactionValue) {
            revert OspErrors.InvalidValue();
        }
        _validateReferenced(
            vars.profileId,
            vars.communityId,
            vars.referencedProfileId,
            vars.referencedContentId,
            vars.referenceConditionData,
            msg.value - vars.reactionValue
        );

        (address openReaction, bytes memory openReactionData) = _initOpenReaction(
            vars.profileId,
            vars.referencedProfileId,
            vars.referencedContentId,
            vars.reactionAndData,
            vars.reactionValue
        );

        emit OspEvents.OpenReactionCreated(
            vars.profileId,
            vars.referencedProfileId,
            vars.referencedContentId,
            vars.communityId,
            openReaction,
            openReactionData,
            vars.ctx,
            block.timestamp
        );
    }

    function _initReferenceCondition(
        uint256 profileId,
        uint256 contentId,
        uint256 communityId,
        bytes calldata initCode
    ) internal returns (address referenceCondition) {
        referenceCondition = address(bytes20(initCode[:20]));
        _checkReferenceCondition(referenceCondition);
        bytes memory initCallData = initCode[20:];
        IReferenceCondition(referenceCondition).initializeReferenceCondition(
            profileId,
            contentId,
            communityId,
            initCallData
        );
    }

    function _initActivityExtension(
        uint256 profileId,
        uint256 contentId,
        bytes calldata initCode,
        uint256 value
    ) internal returns (address extension) {
        extension = address(bytes20(initCode[:20]));
        _checkActivityExtension(extension);
        bytes memory initCallData = initCode[20:];
        IActivityExtension(extension).initializeActivityExtension{value: value}(
            profileId,
            contentId,
            initCallData
        );
    }

    function _initOpenReaction(
        uint256 profileId,
        uint256 referencedProfileId,
        uint256 referencedContentId,
        bytes calldata initCode,
        uint256 value
    ) internal returns (address openReaction, bytes memory openReactionData) {
        openReaction = address(bytes20(initCode[:20]));
        _checkOpenReaction(openReaction);
        openReactionData = initCode[20:];
        IOpenReaction(openReaction).processReaction{value: value}(
            profileId,
            referencedProfileId,
            referencedContentId,
            openReactionData
        );
    }

    function _validateReferenced(
        uint256 profileId,
        uint256 communityId,
        uint256 referencedProfileId,
        uint256 referencedContentId,
        bytes calldata referenceConditionData,
        uint256 value
    ) internal {
        OspDataTypes.ContentStruct storage referencedContent = _getContentStorage()
            ._contentByIdByProfile[referencedProfileId][referencedContentId];

        // Because contentId is a Hash in the offChainServer, not an increment.
        // We cannot use the contentCount of the Profile here to determine whether the article exists.
        if (
            bytes(referencedContent.contentURI).length != 0 ||
            referencedContent.referencedProfileId != 0
        ) {
            address referenceCondition = referencedContent.referenceCondition;
            if (referenceCondition != address(0)) {
                IReferenceCondition(referenceCondition).processReactionReference{value: value}(
                    profileId,
                    communityId,
                    referencedProfileId,
                    referencedContentId,
                    referenceConditionData
                );
            }
        } else {
            revert OspErrors.ContentDoesNotExist();
        }
    }

    function _validateCallerIsJoinCommunity(uint256 profileId, uint256 communityId) internal view {
        if (communityId != 0) {
            address owner = _ownerOf(profileId);
            address joinNFT = _getCommunityStorage()._communityById[communityId].joinNFT;
            if (joinNFT == address(0)) {
                revert OspErrors.InvalidCommunityId();
            }
            uint256 isJoin = IERC721(joinNFT).balanceOf(owner);
            if (isJoin == 0) {
                revert OspErrors.NotJoinCommunity();
            }
        }
    }
}
