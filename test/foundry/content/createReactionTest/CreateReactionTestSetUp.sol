// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import '../ContentTestSetUp.sol';

abstract contract CreateReactionTestSetUp is ContentTestSetUp {
    uint256 CONTENT_1_ID;

    function setUp() public virtual override {
        super.setUp();
        vm.startPrank(user1);
        CONTENT_1_ID = ospClient.createActivity(
            OspDataTypes.CreateActivityData(
                USER_1_PROFILE_ID,
                COMMUNITY_1_ID,
                MOCK_URL,
                EMPTY_BYTES,
                EMPTY_BYTES,
                EMPTY_BYTES
            )
        );
        vm.stopPrank();
    }
}
