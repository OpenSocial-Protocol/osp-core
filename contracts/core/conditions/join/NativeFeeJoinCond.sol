// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {OspErrors} from '../../../libraries/OspErrors.sol';
import {JoinConditionBase} from '../../base/JoinConditionBase.sol';
import {Payment} from '../../../libraries/Payment.sol';

/**
 * @title CommunityData
 * @param amount The amount of native tokens to charge for joining
 * @param recipient The address to send the native tokens to
 */
struct CommunityData {
    uint256 amount;
    address recipient;
}

/**
 * @title NativeFeeJoinCond
 * @author OpenSocial
 * @dev The condition allows users to join a community by paying a fee in native tokens.
 */
contract NativeFeeJoinCond is JoinConditionBase {
    mapping(uint256 => CommunityData) internal _dataByCommunity;

    constructor(address osp) JoinConditionBase(osp) {}

    /**
     * @dev Initializes the condition data for a given community.
     */
    function _initializeCommunityJoinCondition(
        uint256 communityId,
        bytes calldata data
    ) internal override onlyOsp {
        (uint256 amount, address recipient) = abi.decode(data, (uint256, address));
        if (recipient == address(0) || amount == 0) revert OspErrors.InitParamsInvalid();
        _dataByCommunity[communityId].amount = amount;
        _dataByCommunity[communityId].recipient = recipient;
    }

    /**
     * @dev process join,transfer native token to recipient.
     */
    function _processJoin(
        address follower,
        uint256 communityId,
        bytes calldata data
    ) internal override onlyOsp {
        uint256 value = msg.value;
        if (value != _dataByCommunity[communityId].amount) revert OspErrors.ConditionDataMismatch();
        Payment.payNative(_dataByCommunity[communityId].recipient, value);
        (follower, data); //unused
    }

    /**
     * @dev Returns the community data for a given community, or an empty struct if that community was not initialized
     * with this condition.
     */
    function getCommunityData(uint256 communityId) external view returns (CommunityData memory) {
        return _dataByCommunity[communityId];
    }
}
