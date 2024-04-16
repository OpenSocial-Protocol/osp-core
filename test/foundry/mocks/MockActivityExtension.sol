// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {IActivityExtension} from '../../../contracts/interfaces/IActivityExtension.sol';
import {OspContext} from '../../../contracts/core/base/OspContext.sol';
import {IERC165} from '@openzeppelin/contracts/interfaces/IERC165.sol';

contract MockActivityExtension is OspContext, IActivityExtension, IERC165 {
    constructor(address osp) OspContext(osp) {}

    function supportsInterface(bytes4 interfaceId) external pure override returns (bool) {
        return
            interfaceId == type(IActivityExtension).interfaceId ||
            interfaceId == type(IERC165).interfaceId;
    }

    function initializeActivityExtension(
        uint256 /*profileId*/,
        uint256 /*contentId*/,
        bytes calldata initData
    ) external payable onlyOsp {
        uint256 number = abi.decode(initData, (uint256));
        require(number == 1, 'MockActivityExtension: initializeActivityExtension invalid');
    }
}
