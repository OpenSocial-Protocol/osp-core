// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {OspContext} from './OspContext.sol';
import {IJoinCondition} from '../../interfaces/IJoinCondition.sol';
import {IERC165} from '@openzeppelin/contracts/interfaces/IERC165.sol';

abstract contract JoinConditionBase is OspContext, IERC165, IJoinCondition {
    constructor(address osp) OspContext(osp) {}

    function supportsInterface(bytes4 interfaceId) external pure override returns (bool) {
        return
            interfaceId == type(IJoinCondition).interfaceId ||
            interfaceId == type(IERC165).interfaceId;
    }

    function initializeCommunityJoinCondition(
        uint256 communityId,
        bytes calldata data
    ) external onlyOsp {
        _initializeCommunityJoinCondition(communityId, data);
    }

    function processJoin(
        address joiner,
        uint256 community,
        bytes calldata data
    ) external payable onlyOsp {
        _processJoin(joiner, community, data);
    }

    function processTransferJoinNFT(
        uint256 communityId,
        uint256 joinNFTId,
        address from,
        address to
    ) external onlyOsp {
        _processTransferJoinNFT(communityId, joinNFTId, from, to);
    }

    function _initializeCommunityJoinCondition(
        uint256 communityId,
        bytes calldata data
    ) internal virtual;

    function _processJoin(address joiner, uint256 community, bytes calldata data) internal virtual;

    function _processTransferJoinNFT(
        uint256 communityId,
        uint256 joinNFTId,
        address from,
        address to
    ) internal virtual {}
}
