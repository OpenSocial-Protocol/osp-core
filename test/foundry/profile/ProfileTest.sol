// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import '../OspTestSetUp.sol';
import '../mocks/MockFollowCond.sol';

contract ProfileTest is OspTestSetUp {
    string constant USER_1_HANDLE = 'user1_handle';
    address mockFollowCond;

    function setUp() public override {
        super.setUp();
        mockFollowCond = address(new MockFollowCond(address(ospClient)));
    }

    modifier whitelistFollowCondition() {
        vm.startPrank(deployer);
        ospClient.whitelistApp(mockFollowCond, true);
        vm.stopPrank();
        _;
    }

    function testCreateProfile() public forUser1 {
        vm.expectEmit(address(ospClient));
        emit OspEvents.ProfileCreated(
            1,
            user1,
            USER_1_HANDLE,
            ZERO_ADDRESS,
            0,
            EMPTY_BYTES,
            block.timestamp
        );
        uint256 profileId = ospClient.createProfile(
            OspDataTypes.CreateProfileData(USER_1_HANDLE, EMPTY_BYTES, 0, EMPTY_BYTES)
        );
        assertEq(profileId, 1, 'profileId not 1');
        assertEq(ospClient.ownerOf(1), user1, 'owner not eq');

        OspDataTypes.ProfileStruct memory profile = ospClient.getProfile(1);
        assertEq(profile.owner, user1, 'owner not eq');
        assertEq(profile.contentCount, 0, 'content count not zero');
        assertEq(profile.followCondition, ZERO_ADDRESS, 'follow cond not zero address');
        assertEq(profile.mintTimestamp, block.timestamp, 'mint time not eq');
        assertEq(profile.handle, USER_1_HANDLE, 'handle not eq');
        assertEq(profile.followSBT, ZERO_ADDRESS, 'follow sbt not zero address');
    }

    function testCreateProfile_WithFollowCond() public whitelistFollowCondition forUser1 {
        vm.expectEmit(address(ospClient));
        emit OspEvents.ProfileCreated(
            1,
            user1,
            USER_1_HANDLE,
            mockFollowCond,
            0,
            EMPTY_BYTES,
            block.timestamp
        );
        uint256 profileId = ospClient.createProfile(
            OspDataTypes.CreateProfileData(
                USER_1_HANDLE,
                abi.encodePacked(mockFollowCond, CORRECT_BYTES),
                0,
                EMPTY_BYTES
            )
        );
        assertEq(profileId, 1, 'profileId not 1');
        assertEq(ospClient.ownerOf(1), user1, 'owner not eq');

        OspDataTypes.ProfileStruct memory profile = ospClient.getProfile(1);
        assertEq(profile.owner, user1, 'owner not eq');
        assertEq(profile.contentCount, 0, 'content count not zero');
        assertEq(profile.followCondition, mockFollowCond, 'follow cond not mockFollowCond address');
        assertEq(profile.mintTimestamp, block.timestamp, 'mint time not eq');
        assertEq(profile.handle, USER_1_HANDLE, 'handle not eq');
        assertEq(profile.followSBT, ZERO_ADDRESS, 'follow sbt not zero address');
    }

    function testCreateProfile_WithFollowCond_NotWhiteList() public forUser1 {
        vm.expectRevert(OspErrors.AppNotWhitelisted.selector);
        ospClient.createProfile(
            OspDataTypes.CreateProfileData(
                USER_1_HANDLE,
                abi.encodePacked(mockFollowCond, CORRECT_BYTES),
                0,
                EMPTY_BYTES
            )
        );
    }

    function testCreateProfile_WithFollowCond_WrongInitData()
        public
        whitelistFollowCondition
        forUser1
    {
        vm.expectRevert('MockFollowModule: initializeFollowCondition invalid');
        ospClient.createProfile(
            OspDataTypes.CreateProfileData(
                USER_1_HANDLE,
                abi.encodePacked(mockFollowCond, WRONG_BYTES),
                0,
                EMPTY_BYTES
            )
        );
    }
}
