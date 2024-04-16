// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {IOpenReaction} from '../../interfaces/IOpenReaction.sol';
import {OspContext} from './OspContext.sol';
import {IERC165} from '@openzeppelin/contracts/utils/introspection/IERC165.sol';

abstract contract OpenReactionBase is OspContext, IOpenReaction, IERC165 {
    constructor(address osp) OspContext(osp) {}

    function processReaction(
        uint256 profileId,
        uint256 referencedProfileId,
        uint256 referencedContentId,
        bytes calldata data
    ) external payable override onlyOsp {
        _processReaction(profileId, referencedProfileId, referencedContentId, data);
    }

    function _processReaction(
        uint256 profileId,
        uint256 referencedProfileId,
        uint256 referencedContentId,
        bytes calldata data
    ) internal virtual;

    function supportsInterface(bytes4 interfaceId) external pure override returns (bool) {
        return
            interfaceId == type(IOpenReaction).interfaceId ||
            interfaceId == type(IERC165).interfaceId;
    }
}
