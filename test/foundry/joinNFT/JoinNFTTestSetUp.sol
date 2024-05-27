// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import '../community/CreateCommunityTestSetUp.sol';

contract JoinNFTTestSetUp is CreateCommunityTestSetUp {
    address owner;
    address admin;
    uint256 adminProfileId;
    address mod;
    uint256 modProfileId;
    address member;
    uint256 memberProfileId;

    JoinNFT joinNFT;

    function setUp() public virtual override {
        super.setUp();
        owner = user1;
        vm.startPrank(user1);
        address expectJoinNFTAddress = computeCreateAddress(
            address(ospClient),
            vm.getNonce(address(ospClient))
        );
        ospClient.createCommunity(
            OspDataTypes.CreateCommunityData({
                handle: COMMUNITY_1_HANDLE,
                communityConditionAndData: abi.encodePacked(mockCommunityCond, CORRECT_BYTES),
                joinConditionInitCode: EMPTY_BYTES,
                tags: EMPTY_STRINGS,
                ctx: EMPTY_BYTES
            })
        );
        vm.stopPrank();
        joinNFT = JoinNFT(ospClient.getJoinNFT(TEST_COMMUNITY_ID));
        assertEq(address(joinNFT), expectJoinNFTAddress, 'joinNFT not eq');
        OspDataTypes.CommunityStruct memory community = ospClient.getCommunity(TEST_COMMUNITY_ID);
        assertEq(community.joinNFT, expectJoinNFTAddress, 'community joinNFT not eq');
        assertEq(community.handle, COMMUNITY_1_HANDLE, 'handle not eq');
        assertEq(community.joinCondition, ZERO_ADDRESS, 'join condition not eq');
        assertEq(communityNFT.ownerOf(TEST_COMMUNITY_ID), user1, 'owner not eq');

        admin = makeAddr('admin');
        vm.startPrank(admin);
        adminProfileId = ospClient.createProfile(
            OspDataTypes.CreateProfileData('handle_admin', EMPTY_BYTES, 0, EMPTY_BYTES)
        );
        ospClient.join(
            OspDataTypes.JoinData({
                communityId: TEST_COMMUNITY_ID,
                data: EMPTY_BYTES,
                ctx: EMPTY_BYTES
            })
        );
        vm.stopPrank();
        mod = makeAddr('mod');
        vm.startPrank(mod);
        modProfileId = ospClient.createProfile(
            OspDataTypes.CreateProfileData('handle_mod', EMPTY_BYTES, 0, EMPTY_BYTES)
        );
        ospClient.join(
            OspDataTypes.JoinData({
                communityId: TEST_COMMUNITY_ID,
                data: EMPTY_BYTES,
                ctx: EMPTY_BYTES
            })
        );
        vm.stopPrank();
        member = makeAddr('member');
        vm.startPrank(member);
        memberProfileId = ospClient.createProfile(
            OspDataTypes.CreateProfileData('handle_member', EMPTY_BYTES, 0, EMPTY_BYTES)
        );
        ospClient.join(
            OspDataTypes.JoinData({
                communityId: TEST_COMMUNITY_ID,
                data: EMPTY_BYTES,
                ctx: EMPTY_BYTES
            })
        );
        vm.stopPrank();

        vm.startPrank(owner);
        joinNFT.setAdmin(admin, true);
        joinNFT.setModerator(mod, true);
        vm.stopPrank();
    }
}
