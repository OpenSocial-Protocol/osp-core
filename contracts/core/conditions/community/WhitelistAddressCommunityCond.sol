// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {CondErrors} from '../libraries/CondErrors.sol';
import {CommunityCondBase} from '../../base/CommunityCondBase.sol';

/**
 * @title WhitelistAddressCommunityCond
 * @author OpenSocial Protocol
 *
 * @dev This contract specifies that whitelisted address can create communities.
 *
 */
contract WhitelistAddressCommunityCond is CommunityCondBase {
    event MaxCreationNumberSet(address indexed to, uint256 maxCreationNumber, uint256 timestamp);

    constructor(address osp) CommunityCondBase(osp) {}

    mapping(address => uint256) public maxCreationNumber;
    mapping(address => uint256) public creationCount;

    /**
     *  @dev process create community,if the address is not whitelisted, revert.
     */
    function _processCreateCommunity(
        address to,
        string calldata /*handle*/,
        bytes calldata /*data*/
    ) internal override nonPayable {
        if (maxCreationNumber[to] <= creationCount[to]) {
            revert CondErrors.NotWhitelisted();
        }
        creationCount[to]++;
    }

    /**
     *  @dev set the max creation number of an address, only openSocial governance can call this function.
     */
    function setMaxCreationNumber(address to, uint256 _maxCreationNumber) external onlyOperation {
        maxCreationNumber[to] = _maxCreationNumber;
        emit MaxCreationNumberSet(to, _maxCreationNumber, block.timestamp);
    }

    /**
     *  @return The number of communities allowed to be created.
     */
    function allowedCreationNumber(address to) external view returns (uint256) {
        return
            maxCreationNumber[to] > creationCount[to]
                ? maxCreationNumber[to] - creationCount[to]
                : 0;
    }
}
