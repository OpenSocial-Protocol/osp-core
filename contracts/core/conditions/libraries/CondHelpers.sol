// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {CondDataTypes} from './CondDataTypes.sol';

library CondHelpers {
    /**
     * @dev Get the ETH price based on the length of the handle.
     * @param handle The handle to get the ETH price for.
     * @param fixedFeeCondData The fixed fee condition data.
     * @return The ETH price.
     */
    function getHandleETHPrice(
        string calldata handle,
        CondDataTypes.FixedFeeCondData memory fixedFeeCondData
    ) internal pure returns (uint256) {
        uint256 len = bytes(handle).length;
        uint256 ethPrice;
        if (len >= 7) {
            ethPrice = fixedFeeCondData.price7ToMoreLetter;
        } else if (len == 6) {
            ethPrice = fixedFeeCondData.price6Letter;
        } else if (len == 5) {
            ethPrice = fixedFeeCondData.price5Letter;
        } else if (len == 4) {
            ethPrice = fixedFeeCondData.price4Letter;
        } else if (len == 3) {
            ethPrice = fixedFeeCondData.price3Letter;
        } else if (len == 2) {
            ethPrice = fixedFeeCondData.price2Letter;
        } else {
            ethPrice = fixedFeeCondData.price1Letter;
        }
        return ethPrice;
    }
}
