// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import './JoinNFTTestSetUp.sol';

contract JoinNFTRoleTest is JoinNFTTestSetUp {
    function testGrantAdminRole_Owner() public {
        assertFalse(joinNFT.hasOneRole(Constants.COMMUNITY_ADMIN_ACCESS, member));
        assertFalse(joinNFT.hasAllRole(Constants.COMMUNITY_ADMIN_ACCESS, member));
        assertFalse(
            ospClient.hasOneCommunityRole(
                TEST_COMMUNITY_ID,
                Constants.COMMUNITY_ADMIN_ACCESS,
                member
            )
        );
        assertFalse(
            ospClient.hasAllCommunityRole(
                TEST_COMMUNITY_ID,
                Constants.COMMUNITY_ADMIN_ACCESS,
                member
            )
        );
        vm.expectEmit(address(ospClient));
        emit OspEvents.JoinNFTRoleChanged(
            TEST_COMMUNITY_ID,
            owner,
            member,
            Constants.COMMUNITY_ADMIN_ACCESS,
            true,
            block.timestamp
        );
        vm.prank(owner);
        assert(joinNFT.setAdmin(member, true));
        assert(joinNFT.hasOneRole(Constants.COMMUNITY_ADMIN_ACCESS, member));
        assert(joinNFT.hasAllRole(Constants.COMMUNITY_ADMIN_ACCESS, member));
        assert(
            ospClient.hasOneCommunityRole(
                TEST_COMMUNITY_ID,
                Constants.COMMUNITY_ADMIN_ACCESS,
                member
            )
        );
        assert(
            ospClient.hasAllCommunityRole(
                TEST_COMMUNITY_ID,
                Constants.COMMUNITY_ADMIN_ACCESS,
                member
            )
        );
    }

    function testRevertGrantAdminRole_NotOwner() public {
        vm.expectRevert(OspErrors.NotCommunityOwner.selector);
        vm.prank(admin);
        joinNFT.setAdmin(member, true);
        vm.expectRevert(OspErrors.NotCommunityOwner.selector);
        vm.prank(mod);
        joinNFT.setAdmin(member, true);
        vm.expectRevert(OspErrors.NotCommunityOwner.selector);
        vm.prank(member);
        joinNFT.setAdmin(member, true);
    }

    function testGrantModRole_Owner() public {
        _grantModRole(owner);
    }

    function testGrantModRole_Admin() public {
        _grantModRole(admin);
    }

    function _grantModRole(address sender) internal {
        assertFalse(joinNFT.hasOneRole(Constants.COMMUNITY_MODERATOR_ACCESS, member));
        assertFalse(joinNFT.hasAllRole(Constants.COMMUNITY_MODERATOR_ACCESS, member));
        assertFalse(
            ospClient.hasOneCommunityRole(
                TEST_COMMUNITY_ID,
                Constants.COMMUNITY_MODERATOR_ACCESS,
                member
            )
        );
        assertFalse(
            ospClient.hasAllCommunityRole(
                TEST_COMMUNITY_ID,
                Constants.COMMUNITY_MODERATOR_ACCESS,
                member
            )
        );
        vm.expectEmit(address(ospClient));
        emit OspEvents.JoinNFTRoleChanged(
            TEST_COMMUNITY_ID,
            sender,
            member,
            Constants.COMMUNITY_MODERATOR_ACCESS,
            true,
            block.timestamp
        );
        vm.prank(sender);
        assert(joinNFT.setModerator(member, true));
        assert(joinNFT.hasOneRole(Constants.COMMUNITY_MODERATOR_ACCESS, member));
        assert(joinNFT.hasAllRole(Constants.COMMUNITY_MODERATOR_ACCESS, member));
        assert(
            ospClient.hasOneCommunityRole(
                TEST_COMMUNITY_ID,
                Constants.COMMUNITY_MODERATOR_ACCESS,
                member
            )
        );
        assert(
            ospClient.hasAllCommunityRole(
                TEST_COMMUNITY_ID,
                Constants.COMMUNITY_MODERATOR_ACCESS,
                member
            )
        );
    }

    function testRevertGrantModRole_NotOwnerOrAdmin() public {
        vm.expectRevert(OspErrors.JoinNFTUnauthorizedAccount.selector);
        vm.prank(mod);
        joinNFT.setModerator(member, true);
        vm.expectRevert(OspErrors.JoinNFTUnauthorizedAccount.selector);
        vm.prank(member);
        joinNFT.setModerator(member, true);
    }

    function testSetMemberLevel_Owner() public {
        _setMemberLevel(owner);
    }

    function testSetMemberLevel_Admin() public {
        _setMemberLevel(admin);
    }

    function testSetMemberLevel_Mod() public {
        _setMemberLevel(mod);
    }

    function _setMemberLevel(address sender) internal {
        uint256 newLevel = 24234234;
        assertEq(joinNFT.getMemberLevel(member), 0);
        assertEq(ospClient.getCommunityMemberLevel(TEST_COMMUNITY_ID, member), 0);
        vm.expectEmit(address(ospClient));
        emit OspEvents.JoinNFTAccountLevelChanged(
            TEST_COMMUNITY_ID,
            sender,
            member,
            newLevel,
            block.timestamp
        );
        vm.prank(sender);
        assert(joinNFT.setMemberLevel(member, newLevel));
        assertEq(joinNFT.getMemberLevel(member), newLevel);
        assertEq(ospClient.getCommunityMemberLevel(TEST_COMMUNITY_ID, member), newLevel);
    }

    function testRevertSetMemberLevel_NotOwnerOrAdminOrMod() public {
        vm.expectRevert(OspErrors.JoinNFTUnauthorizedAccount.selector);
        vm.prank(member);
        joinNFT.setMemberLevel(member, 10);
    }

    function testBlockAccount_Owner() public {
        _setMemberLevel(owner);
    }

    function testBlockAccount_Admin() public {
        _setMemberLevel(admin);
    }

    function testBlockAccount_Mod() public {
        _setMemberLevel(mod);
    }

    function _blockAccount(address sender) internal {
        assertFalse(joinNFT.isBlock(member));
        assertFalse(ospClient.isCommunityBlock(TEST_COMMUNITY_ID, member));
        vm.expectEmit(address(ospClient));
        emit OspEvents.JoinNFTAccountBlocked(
            TEST_COMMUNITY_ID,
            sender,
            member,
            true,
            block.timestamp
        );
        vm.prank(sender);
        joinNFT.setBlockList(member, true);
        assert(joinNFT.isBlock(member));
        assert(ospClient.isCommunityBlock(TEST_COMMUNITY_ID, member));
    }

    function testBlockAccount_NotOwnerOrAdminOrMod() public {
        vm.expectRevert(OspErrors.JoinNFTUnauthorizedAccount.selector);
        vm.prank(member);
        joinNFT.setBlockList(member, true);
    }
}
