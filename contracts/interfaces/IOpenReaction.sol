// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

interface IOpenReaction {
    function processReaction(
        uint256 profileId,
        uint256 referencedProfileId,
        uint256 referencedContentId,
        bytes calldata data
    ) external payable;
}
