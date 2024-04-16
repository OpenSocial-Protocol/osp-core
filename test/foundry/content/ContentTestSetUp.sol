// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import '../OspTestSetUp.sol';
import '../mocks/MockCommunityCond.sol';
import '../mocks/MockActivityExtension.sol';

abstract contract ContentTestSetUp is OspTestSetUp {
    uint256 USER_1_PROFILE_ID;
    uint256 COMMUNITY_1_ID;
    address mockActivityExtension;

    function setUp() public virtual override {
        super.setUp();
        vm.startPrank(deployer);
        ICommunityCondition mockCondition = new MockCommunityCond(address(ospClient));
        mockActivityExtension = address(new MockActivityExtension(address(ospClient)));
        ospClient.whitelistApp(address(mockCondition), true);
        ospClient.whitelistApp(mockActivityExtension, true);
        vm.stopPrank();

        vm.startPrank(user1);
        USER_1_PROFILE_ID = ospClient.createProfile(
            OspDataTypes.CreateProfileData('user1_handle', EMPTY_BYTES, 0, EMPTY_BYTES)
        );
        COMMUNITY_1_ID = ospClient.createCommunity(
            OspDataTypes.CreateCommunityData({
                handle: 'community1_handle',
                communityConditionAndData: abi.encodePacked(address(mockCondition), CORRECT_BYTES),
                joinConditionInitCode: EMPTY_BYTES,
                tags: EMPTY_STRINGS,
                ctx: EMPTY_BYTES
            })
        );
        vm.stopPrank();
    }
}
