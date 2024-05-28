// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {IERC721} from '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import {CommunityCondBase} from '../../base/CommunityCondBase.sol';
import {Payment} from '../../../libraries/Payment.sol';
import {ECDSA} from '@openzeppelin/contracts/utils/cryptography/ECDSA.sol';
import {CondErrors} from '../libraries/CondErrors.sol';
import {CondDataTypes} from '../libraries/CondDataTypes.sol';
import {CondHelpers} from '../libraries/CondHelpers.sol';

/**
 * @title FixedFeeCommunityCond
 * @author OpenSocial Protocol
 *
 * @dev This contract specifies that pay the specified amount of ETH to create the community.
 * The amount of ETH paid is related to the handle length of the community.
 */
contract FixedFeeCommunityCond is CommunityCondBase {
    event FixFeeCondDataSet(CondDataTypes.FixedFeeCondData data, uint256 timestamp);
    event FixFeePaid(address indexed to, uint256 price, string handle, uint256 timestamp);

    CondDataTypes.FixedFeeCondData public fixedFeeCondData;

    constructor(address osp) CommunityCondBase(osp) {}

    /**
     * @dev process create community,if the slotNFT is used, revert.
     */
    function _processCreateCommunity(
        address to,
        string calldata handle,
        bytes calldata data
    ) internal override {
        /// @dev if createStartTime is not set, indicates no initialization.
        if (
            block.timestamp < fixedFeeCondData.createStartTime ||
            fixedFeeCondData.createStartTime == 0
        ) {
            revert CondErrors.NotCreateTime();
        }
        uint256 price = CondHelpers.getHandleETHPrice(handle, fixedFeeCondData);
        _charge(price, to);
        emit FixFeePaid(to, price, handle, block.timestamp);
    }

    function setFixedFeeCondData(
        CondDataTypes.FixedFeeCondData calldata data
    ) external onlyOperation {
        fixedFeeCondData = CondDataTypes.FixedFeeCondData({
            price1Letter: data.price1Letter,
            price2Letter: data.price2Letter,
            price3Letter: data.price3Letter,
            price4Letter: data.price4Letter,
            price5Letter: data.price5Letter,
            price6Letter: data.price6Letter,
            price7ToMoreLetter: data.price7ToMoreLetter,
            createStartTime: data.createStartTime,
            treasure: data.treasure
        });
        emit FixFeeCondDataSet(data, block.timestamp);
    }

    /**
     * @dev Get the handle price based on the length of the handle.
     */
    function getHandlePrice(string calldata handle) external view returns (uint256) {
        return CondHelpers.getHandleETHPrice(handle, fixedFeeCondData);
    }

    function _charge(uint256 price, address to) internal virtual {
        if (msg.value < price) {
            revert CondErrors.InsufficientPayment();
        }
        uint256 overpayment;
        unchecked {
            overpayment = msg.value - price;
        }
        if (overpayment > 0) {
            Payment.payNative(to, overpayment);
        }
        Payment.payNative(fixedFeeCondData.treasure, price);
    }
}
