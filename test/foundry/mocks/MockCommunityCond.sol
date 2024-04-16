// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {IERC721} from '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import {ICommunityCondition} from '../../../contracts/interfaces/ICommunityCondition.sol';
import {OspContext} from '../../../contracts/core/base/OspContext.sol';
import {IERC165} from '@openzeppelin/contracts/interfaces/IERC165.sol';

/**
 * @title MockCondition
 * @author OpenSocial Protocol
 *
 * @dev for community creation
 */
contract MockCommunityCond is OspContext, ICommunityCondition, IERC165 {
    constructor(address osp) OspContext(osp) {}

    function supportsInterface(bytes4 interfaceId) external pure override returns (bool) {
        return
            interfaceId == type(ICommunityCondition).interfaceId ||
            interfaceId == type(IERC165).interfaceId;
    }

    function processCreateCommunity(
        address /*to*/,
        bytes calldata data
    ) external payable override onlyOsp {
        uint256 number = abi.decode(data, (uint256));
        require(number == 1, 'MockCreateCommunityCond: processCreateCommunity invalid');
    }
}
