// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {IFollowCondition} from '../../../contracts/interfaces/IFollowCondition.sol';
import {OspContext} from '../../../contracts/core/base/OspContext.sol';
import {IERC165} from '@openzeppelin/contracts/interfaces/IERC165.sol';

contract MockFollowCond is IFollowCondition, OspContext, IERC165 {
    constructor(address osp) OspContext(osp) {}

    function supportsInterface(bytes4 interfaceId) external pure override returns (bool) {
        return
            interfaceId == type(IFollowCondition).interfaceId ||
            interfaceId == type(IERC165).interfaceId;
    }

    function initializeFollowCondition(
        uint256 profileId,
        bytes calldata data
    ) external pure override {
        uint256 number = abi.decode(data, (uint256));
        require(number == 1, 'MockFollowModule: initializeFollowCondition invalid');
    }

    function processFollow(
        address /*follower*/,
        uint256 /*profileId*/,
        bytes calldata data
    ) external payable override onlyOsp {
        uint256 number = abi.decode(data, (uint256));
        require(number == 1, 'MockFollowModule: processFollow invalid');
    }
}
