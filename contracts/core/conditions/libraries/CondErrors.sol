// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

library CondErrors {
    error NotWhitelisted();
    error ConditionDataMismatch();
    error InitParamsInvalid();

    error HandleLengthNotEnough();

    error SlotNFTNotWhitelisted();
    error NotSlotNFTOwner();
    error SlotNFTAlreadyUsed();

    error NotCreateTime();
    error NotPresaleTime();
    error InvalidTicket();
    error InsufficientPayment();
    error SignatureInvalid();

    error JoinNFTTransferInvalid();
    error JoinInvalid();
}
