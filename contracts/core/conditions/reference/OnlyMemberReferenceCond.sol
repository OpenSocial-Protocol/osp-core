// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {OspErrors} from '../../../libraries/OspErrors.sol';
import {ReferenceConditionBase} from '../../base/ReferenceConditionBase.sol';

contract OnlyMemberReferenceCond is ReferenceConditionBase {
    constructor(address osp) ReferenceConditionBase(osp) {}

    function _initializeReferenceCondition(
        uint256 /*profileId*/,
        uint256 /*communityId*/,
        uint256 /*contendId*/,
        bytes calldata /*data*/
    ) internal override {
        // nothing to do
    }

    function _processReactionReference(
        uint256 /*profileId*/,
        uint256 communityId,
        uint256 referencedProfileId,
        uint256 referencedContentId,
        bytes calldata /*data*/
    ) internal override nonPayable {
        uint256 referencedCommunityId = OSP.getCommunityIdByContent(
            referencedProfileId,
            referencedContentId
        );
        if (communityId != referencedCommunityId) {
            revert OspErrors.InvalidCommunityId();
        }
    }
}
