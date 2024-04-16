// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

interface IActivityExtension {
    function initializeActivityExtension(
        uint256 profileId,
        uint256 contentId,
        bytes calldata initData
    ) external payable;
}
