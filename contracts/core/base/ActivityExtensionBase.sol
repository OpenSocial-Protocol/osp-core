// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {OspContext} from './OspContext.sol';
import {IERC165} from '@openzeppelin/contracts/utils/introspection/IERC165.sol';
import {IActivityExtension} from '../../interfaces/IActivityExtension.sol';

abstract contract ActivityExtensionBase is OspContext, IActivityExtension, IERC165 {
    constructor(address osp) OspContext(osp) {}

    function initializeActivityExtension(
        uint256 profileId,
        uint256 contentId,
        bytes calldata initData
    ) external payable onlyOsp {
        _initializeActivityExtension(profileId, contentId, initData);
    }

    function _initializeActivityExtension(
        uint256 profileId,
        uint256 contentId,
        bytes calldata initData
    ) internal virtual;

    function supportsInterface(bytes4 interfaceId) external pure override returns (bool) {
        return
            interfaceId == type(IActivityExtension).interfaceId ||
            interfaceId == type(IERC165).interfaceId;
    }
}
