// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

/**
 * @title IJoinCondition
 * @author Osp Protocol
 *
 * @dev This is the standard interface for all Osp-compatible JoinConditions.
 */
interface IJoinCondition {
    /**
     * @dev Initializes a join Condition for a given OSP community. This can only be called by the osp contract.
     *
     * @param communityId The token ID of the community to initialize this join condition for.
     * @param data initialization data.
     */
    function initializeCommunityJoinCondition(uint256 communityId, bytes calldata data) external;

    /**
     * @dev Processes a given join, this can only be called from the OSP contract.
     *
     * @param joiner The joiner address.
     * @param community The token ID of the community being joined.
     * @param data data for processing.
     */
    function processJoin(address joiner, uint256 community, bytes calldata data) external payable;

    function processTransferJoinNFT(
        uint256 communityId,
        uint256 joinNFTId,
        address from,
        address to
    ) external;
}
