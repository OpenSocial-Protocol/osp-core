// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import '../OspTestSetUp.sol';
import '../mocks/MockCommunityCond.sol';
import '../mocks/MockJoinCond.sol';
import 'contracts/libraries/Constants.sol';

contract CreateCommunityTestSetUp is OspTestSetUp {
    string constant COMMUNITY_1_HANDLE = 'community1_handle';
    address mockCommunityCond;
    address mockJoinCond;
    uint256 internal constant TEST_COMMUNITY_ID = 1;
    uint256 user1_profile_id;
    address immutable superCreator = makeAddr('superCreator');

    function setUp() public virtual override {
        super.setUp();
        vm.startPrank(deployer);
        mockCommunityCond = address(new MockCommunityCond(address(ospClient)));
        ospClient.whitelistApp(mockCommunityCond, true);
        ospClient.grantRole(Constants.SUPER_COMMUNITY_CREATOR, superCreator);
        vm.stopPrank();
        vm.startPrank(user1);
        user1_profile_id = ospClient.createProfile(
            OspDataTypes.CreateProfileData('handle_1', EMPTY_BYTES, 0, EMPTY_BYTES)
        );
        mockJoinCond = address(new MockJoinCond(address(ospClient)));
        vm.stopPrank();
    }
}
