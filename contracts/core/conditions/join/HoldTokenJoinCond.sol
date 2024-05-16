// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {CondErrors} from '../libraries/CondErrors.sol';
import {JoinConditionBase} from '../../base/JoinConditionBase.sol';

/**
 * @title HoldTokenJoinCond
 * @param token token address,if token is address(0) means native token.
 * @param amount token amount.
 */
struct CommunityData {
    address token;
    uint256 amount;
}

/**
 * @title IToken
 * @dev Used to check erc20 or erc721 token balance
 */
interface IToken {
    function balanceOf(address owner) external view returns (uint256);
}

/**
 * @title HoldTokenJoinCond
 * @author OpenSocial
 * @dev This condition allows users to join a community by holding a certain amount of tokens.
 */
contract HoldTokenJoinCond is JoinConditionBase {
    mapping(uint256 => CommunityData) _dataByCommunity;

    constructor(address osp) JoinConditionBase(osp) {}

    function _initializeCommunityJoinCondition(
        uint256 communityId,
        bytes calldata data
    ) internal override {
        (address _token, uint256 _amount) = abi.decode(data, (address, uint256));
        _dataByCommunity[communityId].token = _token;
        _dataByCommunity[communityId].amount = _amount;
    }

    function _processJoin(
        address joiner,
        uint256 communityId,
        bytes calldata data
    ) internal override nonPayable {
        (data); //unused
        address token = _dataByCommunity[communityId].token;
        if (token == address(0) && joiner.balance >= _dataByCommunity[communityId].amount) {
            //native token
            return;
        } else if (
            token != address(0) &&
            IToken(token).balanceOf(joiner) >= _dataByCommunity[communityId].amount
        ) {
            //ERC20 or ERC721 token
            return;
        }
        revert CondErrors.JoinInvalid();
    }

    function _processTransferJoinNFT(
        uint256 communityId,
        uint256 joinNFTId,
        address from,
        address to
    ) internal override {
        if (from != address(0) && to != address(0)) {
            revert CondErrors.JoinNFTTransferInvalid();
        }
    }

    /**
     * @dev Returns the community data for a given community, or an empty struct if that community was not initialized
     * with this condition.
     */
    function getCommunityData(uint256 communityId) external view returns (CommunityData memory) {
        return _dataByCommunity[communityId];
    }
}
