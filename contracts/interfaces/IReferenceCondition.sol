// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

/**
 * @title IReferenceCondition
 * @author Osp Protocol
 *
 * @dev This is the standard interface for all Osp-compatible ReferenceConditions.
 */
interface IReferenceCondition {
    function initializeReferenceCondition(
        uint256 profileId,
        uint256 contendId,
        uint256 communityId,
        bytes calldata data
    ) external;

    function processReactionReference(
        uint256 profileId,
        uint256 communityId,
        uint256 referencedProfileId,
        uint256 referencedContentId,
        bytes calldata data
    ) external payable;
}
