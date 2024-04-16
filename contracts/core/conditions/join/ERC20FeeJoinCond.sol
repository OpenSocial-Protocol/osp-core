// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {OspErrors} from '../../../libraries/OspErrors.sol';
import {FeeConditionBase} from '../FeeConditionBase.sol';
import {JoinConditionBase} from '../../base/JoinConditionBase.sol';
import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {SafeERC20} from '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';

/**
 * @param currency The address of the ERC20 token to be used for the fee.
 * @param amount The amount of the ERC20 token to be used for the fee.
 * @param recipient The address of the recipient of the fee.
 */
struct CommunityData {
    address currency;
    uint256 amount;
    address recipient;
}

/**
 * @title ERC20FeeJoinCond
 * @author OpenSocial
 * @notice The condition allows users to join a community by paying a fee in ERC20 tokens.
 */
contract ERC20FeeJoinCond is FeeConditionBase, JoinConditionBase {
    using SafeERC20 for IERC20;

    mapping(uint256 => CommunityData) internal _dataByCommunity;

    constructor(address osp) JoinConditionBase(osp) {}

    /**
     * @dev Initializes the condition data for a given community.
     */
    function _initializeCommunityJoinCondition(
        uint256 communityId,
        bytes calldata data
    ) internal override {
        (address currency, uint256 amount, address recipient) = abi.decode(
            data,
            (address, uint256, address)
        );
        if (!_tokenWhitelisted(currency) || recipient == address(0) || amount == 0)
            revert OspErrors.InitParamsInvalid();
        _dataByCommunity[communityId].amount = amount;
        _dataByCommunity[communityId].currency = currency;
        _dataByCommunity[communityId].recipient = recipient;
    }

    /**
     * @dev process join,transfer ERC20 token to recipient.
     */
    function _processJoin(
        address follower,
        uint256 communityId,
        bytes calldata data
    ) internal override nonPayable {
        uint256 amount = _dataByCommunity[communityId].amount;
        address currency = _dataByCommunity[communityId].currency;
        _validateDataIsExpected(data, currency, amount);
        IERC20(currency).safeTransferFrom(
            follower,
            _dataByCommunity[communityId].recipient,
            amount
        );
    }

    /**
     * @dev Returns the community data for a given community, or an empty struct if that community was not initialized
     * with this condition.
     */
    function getCommunityData(uint256 communityId) external view returns (CommunityData memory) {
        return _dataByCommunity[communityId];
    }
}
