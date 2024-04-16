// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {IJoinCondition} from '../../../contracts/interfaces/IJoinCondition.sol';
import {OspContext} from '../../../contracts/core/base/OspContext.sol';
import {IERC165} from '@openzeppelin/contracts/interfaces/IERC165.sol';

contract MockJoinCond is IJoinCondition, OspContext, IERC165 {
    constructor(address osp) OspContext(osp) {}

    function supportsInterface(bytes4 interfaceId) external pure override returns (bool) {
        return
            interfaceId == type(IJoinCondition).interfaceId ||
            interfaceId == type(IERC165).interfaceId;
    }

    function initializeCommunityJoinCondition(
        uint256 /*communityId*/,
        bytes calldata data
    ) external override onlyOsp {
        uint256 number = abi.decode(data, (uint256));
        require(number == 1, 'MockJoinCond: initializeCommunityJoinCondition invalid');
    }

    function processJoin(
        address /*joiner*/,
        uint256 community,
        bytes calldata data
    ) external payable override onlyOsp {
        uint256 number = abi.decode(data, (uint256));
        require(number == 1, 'MockJoinCond: processJoin invalid');
    }

    function processTransferJoinNFT(
        uint256 communityId,
        uint256 joinNFTId,
        address from,
        address to
    ) external {}
}
