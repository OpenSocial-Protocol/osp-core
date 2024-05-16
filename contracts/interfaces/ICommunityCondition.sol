// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

/**
 * @title ICommunityCondition
 * @author Opensocial Protocol
 *
 * @dev This is the standard interface for all Osp-compatible Conditions.
 * Conditions are used to check if a community can be created.
 */
interface ICommunityCondition {
    /**
     * @dev Checks if a community can be created.
     * @param to community creator.
     * @param data condition data for checking.
     */
    function processCreateCommunity(
        address to,
        string calldata handle,
        bytes calldata data
    ) external payable;
}
