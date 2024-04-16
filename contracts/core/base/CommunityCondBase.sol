// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {OspContext} from './OspContext.sol';
import {ICommunityCondition} from '../../interfaces/ICommunityCondition.sol';
import {IERC165} from '@openzeppelin/contracts/interfaces/IERC165.sol';

abstract contract CommunityCondBase is OspContext, ICommunityCondition, IERC165 {
    constructor(address osp) OspContext(osp) {}

    function processCreateCommunity(
        address to,
        bytes calldata data
    ) external payable override onlyOsp {
        _processCreateCommunity(to, data);
    }

    function supportsInterface(bytes4 interfaceId) external pure override returns (bool) {
        return
            interfaceId == type(ICommunityCondition).interfaceId ||
            interfaceId == type(IERC165).interfaceId;
    }

    function _processCreateCommunity(address to, bytes calldata data) internal virtual;
}
