// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

/**
 * @title IFollowCondition
 * @author OpenSocial Protocol
 *
 * @dev This is the standard interface for all OSP-compatible FollowConditions.
 */
interface IFollowCondition {
    /**
     * @dev Initializes a follow Condition for a given OSP profile. This can only be called by the osp contract.
     *
     * @param profileId The token ID of the profile to initialize this follow condition for.
     * @param data initialization data.
     */
    function initializeFollowCondition(uint256 profileId, bytes calldata data) external;

    /**
     * @dev Processes a given follow, this can only be called from the OSP contract.
     *
     * @param follower The follower address.
     * @param profileId The token ID of the profile being followed.
     * @param data data for processing.
     */
    function processFollow(
        address follower,
        uint256 profileId,
        bytes calldata data
    ) external payable;
}
