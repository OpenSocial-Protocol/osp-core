// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {OspContext} from './OspContext.sol';
import {IReferenceCondition} from '../../interfaces/IReferenceCondition.sol';
import {IERC165} from '@openzeppelin/contracts/interfaces/IERC165.sol';

abstract contract ReferenceConditionBase is OspContext, IERC165, IReferenceCondition {
    constructor(address osp) OspContext(osp) {}

    function supportsInterface(bytes4 interfaceId) external pure override returns (bool) {
        return
            interfaceId == type(IReferenceCondition).interfaceId ||
            interfaceId == type(IERC165).interfaceId;
    }

    function initializeReferenceCondition(
        uint256 profileId,
        uint256 contendId,
        uint256 communityId,
        bytes calldata data
    ) external onlyOsp {
        _initializeReferenceCondition(profileId, communityId, contendId, data);
    }

    function processReactionReference(
        uint256 profileId,
        uint256 communityId,
        uint256 referencedProfileId,
        uint256 referencedContentId,
        bytes calldata data
    ) external payable onlyOsp {
        _processReactionReference(
            profileId,
            communityId,
            referencedProfileId,
            referencedContentId,
            data
        );
    }

    function _initializeReferenceCondition(
        uint256 profileId,
        uint256 contendId,
        uint256 communityId,
        bytes calldata data
    ) internal virtual;

    function _processReactionReference(
        uint256 profileId,
        uint256 communityId,
        uint256 referencedProfileId,
        uint256 referencedContentId,
        bytes calldata data
    ) internal virtual;
}
