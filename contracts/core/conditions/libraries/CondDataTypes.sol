// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

/**
 * @title CondDataTypes
 * @author OpenSocial Protocol
 *
 * @dev The CondDataTypes library contains data types used throughout the OpenSocial Protocol.
 */
library CondDataTypes {
    struct SlotNFTCondData {
        bool whitelist;
        uint256 minHandleLength;
    }

    struct FixFeeCondData {
        uint256 price1Letter;
        uint256 price2Letter;
        uint256 price3Letter;
        uint256 price4Letter;
        uint256 price5Letter;
        uint256 price6Letter;
        uint256 price7ToMoreLetter;
        uint256 createStartTime;
        address treasure;
    }
}
