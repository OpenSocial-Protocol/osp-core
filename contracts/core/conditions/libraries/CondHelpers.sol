// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {CondDataTypes} from './CondDataTypes.sol';

library CondHelpers {
    /**
     * @dev Get the ETH price based on the length of the handle.
     * @param handle The handle to get the ETH price for.
     * @param fixFeeCondData The fixed fee condition data.
     * @return The ETH price.
     */
    function getHandleETHPrice(
        string calldata handle,
        CondDataTypes.FixFeeCondData memory fixFeeCondData
    ) external pure returns (uint256) {
        uint256 len = bytes(handle).length;
        uint256 ethPrice;
        if (len >= 7) {
            ethPrice = fixFeeCondData.price7ToMoreLetter;
        } else if (len == 6) {
            ethPrice = fixFeeCondData.price6Letter;
        } else if (len == 5) {
            ethPrice = fixFeeCondData.price5Letter;
        } else if (len == 4) {
            ethPrice = fixFeeCondData.price4Letter;
        } else if (len == 3) {
            ethPrice = fixFeeCondData.price3Letter;
        } else if (len == 2) {
            ethPrice = fixFeeCondData.price2Letter;
        } else {
            ethPrice = fixFeeCondData.price1Letter;
        }
        return ethPrice;
    }
}
