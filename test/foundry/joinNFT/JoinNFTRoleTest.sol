// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import './JoinNFTTestSetUp.sol';

contract JoinNFTRoleTest is JoinNFTTestSetUp {
    // admin test
    function test_GrantAdminRole_Owner() public {
        assertFalse(joinNFT.hasRole(Constants.COMMUNITY_ADMIN_ACCESS, member));
        assertFalse(
            ospClient.hasCommunityRole(TEST_COMMUNITY_ID, Constants.COMMUNITY_ADMIN_ACCESS, member)
        );
        vm.expectEmit(address(ospClient));
        emit OspEvents.JoinNFTRoleChanged(
            TEST_COMMUNITY_ID,
            owner,
            member,
            Constants.COMMUNITY_ADMIN_ACCESS,
            block.timestamp
        );
        vm.prank(owner);
        assert(joinNFT.setAdmin(member));
        assert(joinNFT.hasRole(Constants.COMMUNITY_ADMIN_ACCESS, member));
        assert(
            ospClient.hasCommunityRole(TEST_COMMUNITY_ID, Constants.COMMUNITY_ADMIN_ACCESS, member)
        );
    }

    function testRevert_GrantAdminRole_NotOwner() public {
        vm.expectRevert(OspErrors.JoinNFTUnauthorizedAccount.selector);
        vm.prank(admin);
        joinNFT.setAdmin(member);
        vm.expectRevert(OspErrors.JoinNFTUnauthorizedAccount.selector);
        vm.prank(mod);
        joinNFT.setAdmin(member);
        vm.expectRevert(OspErrors.JoinNFTUnauthorizedAccount.selector);
        vm.prank(member);
        joinNFT.setAdmin(member);
    }

    function test_RevokeAdminRole_Owner() public {
        assert(joinNFT.hasRole(Constants.COMMUNITY_ADMIN_ACCESS, admin));
        assert(
            ospClient.hasCommunityRole(TEST_COMMUNITY_ID, Constants.COMMUNITY_ADMIN_ACCESS, admin)
        );
        vm.expectEmit(address(ospClient));
        emit OspEvents.JoinNFTRoleChanged(
            TEST_COMMUNITY_ID,
            owner,
            admin,
            Constants.COMMUNITY_NULL_ACCESS,
            block.timestamp
        );
        vm.prank(owner);
        assert(joinNFT.removeRole(admin));
        assertFalse(joinNFT.hasRole(Constants.COMMUNITY_ADMIN_ACCESS, admin));
        assertFalse(
            ospClient.hasCommunityRole(TEST_COMMUNITY_ID, Constants.COMMUNITY_ADMIN_ACCESS, admin)
        );
    }

    function testRevert_RevokeAdminRole_NotOwner() public {
        vm.expectRevert(OspErrors.JoinNFTUnauthorizedAccount.selector);
        vm.prank(admin);
        joinNFT.removeRole(admin);
        vm.expectRevert(OspErrors.JoinNFTUnauthorizedAccount.selector);
        vm.prank(mod);
        joinNFT.removeRole(admin);
        vm.expectRevert(OspErrors.JoinNFTUnauthorizedAccount.selector);
        vm.prank(member);
        joinNFT.removeRole(admin);
    }

    // mod test
    function test_GrantModRole_Owner() public {
        _grantModRole(owner);
    }

    function test_GrantModRole_Admin() public {
        _grantModRole(admin);
    }

    function _grantModRole(address sender) internal {
        assertFalse(joinNFT.hasRole(Constants.COMMUNITY_MODERATOR_ACCESS, member));
        assertFalse(
            ospClient.hasCommunityRole(
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
            block.timestamp
        );
        vm.prank(sender);
        assert(joinNFT.setModerator(member));
        assert(joinNFT.hasRole(Constants.COMMUNITY_MODERATOR_ACCESS, member));
        assert(
            ospClient.hasCommunityRole(
                TEST_COMMUNITY_ID,
                Constants.COMMUNITY_MODERATOR_ACCESS,
                member
            )
        );
    }

    function testRevert_GrantModRole_NotOwnerOrAdmin() public {
        vm.expectRevert(OspErrors.JoinNFTUnauthorizedAccount.selector);
        vm.prank(mod);
        joinNFT.setModerator(member);
        vm.expectRevert(OspErrors.JoinNFTUnauthorizedAccount.selector);
        vm.prank(member);
        joinNFT.setModerator(member);
    }

    function test_RevokeModRole_Owner() public {
        _revokeModRole(owner);
    }

    function test_RevokeModRole_Admin() public {
        _revokeModRole(admin);
    }

    function _revokeModRole(address sender) internal {
        assert(joinNFT.hasRole(Constants.COMMUNITY_MODERATOR_ACCESS, mod));
        assert(
            ospClient.hasCommunityRole(TEST_COMMUNITY_ID, Constants.COMMUNITY_MODERATOR_ACCESS, mod)
        );
        vm.expectEmit(address(ospClient));
        emit OspEvents.JoinNFTRoleChanged(
            TEST_COMMUNITY_ID,
            sender,
            mod,
            Constants.COMMUNITY_NULL_ACCESS,
            block.timestamp
        );
        vm.prank(sender);
        assert(joinNFT.removeRole(mod));
        assertFalse(joinNFT.hasRole(Constants.COMMUNITY_MODERATOR_ACCESS, mod));
        assertFalse(
            ospClient.hasCommunityRole(TEST_COMMUNITY_ID, Constants.COMMUNITY_MODERATOR_ACCESS, mod)
        );
    }

    function testRevert_RevokeModRole_NotOwnerOrAdmin() public {
        vm.expectRevert(OspErrors.JoinNFTUnauthorizedAccount.selector);
        vm.prank(mod);
        joinNFT.removeRole(mod);
        vm.expectRevert(OspErrors.JoinNFTUnauthorizedAccount.selector);
        vm.prank(member);
        joinNFT.removeRole(mod);
    }

    // member level test
    function test_SetMemberLevel_Owner() public {
        _setMemberLevel(owner);
    }

    function test_SetMemberLevel_Admin() public {
        _setMemberLevel(admin);
    }

    function test_SetMemberLevel_Mod() public {
        _setMemberLevel(mod);
    }

    function _setMemberLevel(address sender) internal {
        uint256 newLevel = 24234234;
        assertEq(joinNFT.getMemberLevel(member), 0);
        assertEq(ospClient.getCommunityMemberLevel(TEST_COMMUNITY_ID, member), 0);
        vm.expectEmit(address(ospClient));
        emit OspEvents.JoinNFTAccountLevelChanged(
            TEST_COMMUNITY_ID,
            memberJoinNFTTokenId,
            sender,
            member,
            address(joinNFT),
            newLevel,
            block.timestamp
        );
        vm.prank(sender);
        assert(joinNFT.setMemberLevel(memberJoinNFTTokenId, newLevel));
        assertEq(joinNFT.getMemberLevel(member), newLevel);
        assertEq(ospClient.getCommunityMemberLevel(TEST_COMMUNITY_ID, member), newLevel);
    }

    function testRevert_SetMemberLevel_NotOwnerOrAdminOrMod() public {
        vm.expectRevert(OspErrors.JoinNFTUnauthorizedAccount.selector);
        vm.prank(member);
        joinNFT.setMemberLevel(memberJoinNFTTokenId, 10);
    }

    // block list test
    function test_BlockAccount_Owner() public {
        _blockAccount(owner);
    }

    function test_BlockAccount_Admin() public {
        _blockAccount(admin);
    }

    function test_BlockAccount_Mod() public {
        _blockAccount(mod);
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
        assert(joinNFT.setBlockList(member, true));
        assert(joinNFT.isBlock(member));
        assert(ospClient.isCommunityBlock(TEST_COMMUNITY_ID, member));
    }

    function test_UnblockAccount_Owner() public {
        _unblockAccount(owner);
    }

    function test_UnblockAccount_Admin() public {
        _unblockAccount(admin);
    }

    function test_UnblockAccount_Mod() public {
        _unblockAccount(mod);
    }

    function _unblockAccount(address sender) internal {
        vm.prank(sender);
        joinNFT.setBlockList(member, true);

        assert(joinNFT.isBlock(member));
        assert(ospClient.isCommunityBlock(TEST_COMMUNITY_ID, member));
        vm.expectEmit(address(ospClient));
        emit OspEvents.JoinNFTAccountBlocked(
            TEST_COMMUNITY_ID,
            sender,
            member,
            false,
            block.timestamp
        );
        vm.prank(sender);
        assert(joinNFT.setBlockList(member, false));
        assertFalse(joinNFT.isBlock(member));
        assertFalse(ospClient.isCommunityBlock(TEST_COMMUNITY_ID, member));
    }

    function testRevert_unblockAccount_NotOwnerOrAdminOrMod() public {
        vm.prank(owner);
        joinNFT.setBlockList(member, true);
        vm.expectRevert(OspErrors.JoinNFTUnauthorizedAccount.selector);
        vm.prank(member);
        joinNFT.setBlockList(member, false);
    }

    function testRevert_JoinNFTTransfer_FromAddressBlocked() public {
        address to = address(0x123);
        uint256 tokenId = joinNFT.tokenOfOwnerByIndex(member, 0);
        vm.prank(owner);
        joinNFT.setBlockList(member, true);
        vm.expectRevert(OspErrors.JoinNFTBlocked.selector);
        vm.prank(member);
        joinNFT.transferFrom(member, to, tokenId);
    }

    function testRevert_JoinNFTTransfer_ToAddressBlocked() public {
        address to = address(0x123);
        uint256 tokenId = joinNFT.tokenOfOwnerByIndex(member, 0);
        vm.prank(owner);
        joinNFT.setBlockList(to, true);
        vm.expectRevert(OspErrors.JoinNFTBlocked.selector);
        vm.prank(member);
        joinNFT.transferFrom(member, to, tokenId);
    }

    function testRevert_BalanceOf_AddressBlocked() public {
        assert(ospClient.isJoin(TEST_COMMUNITY_ID, member));
        assertEq(joinNFT.balanceOf(member), 1);
        vm.prank(owner);
        joinNFT.setBlockList(member, true);
        vm.expectRevert(OspErrors.JoinNFTBlocked.selector);
        joinNFT.balanceOf(member);
        assertFalse(ospClient.isJoin(TEST_COMMUNITY_ID, member));
    }

    //transfer
    function test_JoinNFTTransfer() public {
        address to = address(0x123);
        uint256 tokenId = joinNFT.tokenOfOwnerByIndex(member, 0);
        vm.expectEmit(address(ospClient));
        emit OspEvents.JoinNFTTransferred(TEST_COMMUNITY_ID, tokenId, member, to, block.timestamp);
        vm.prank(member);
        joinNFT.transferFrom(member, to, tokenId);
        assert(joinNFT.ownerOf(tokenId) == to);
        assert(ospClient.isJoin(TEST_COMMUNITY_ID, to));
        assertFalse(ospClient.isJoin(TEST_COMMUNITY_ID, member));
        assertEq(joinNFT.tokenOfOwnerByIndex(to, 0), tokenId);
    }

    function testRevert_JoinNFTTransfer_ToAddressHasNFT() public {
        address to = mod;
        uint256 tokenId = joinNFT.tokenOfOwnerByIndex(member, 0);
        vm.expectRevert(OspErrors.JoinNFTDuplicated.selector);
        vm.prank(member);
        joinNFT.transferFrom(member, to, tokenId);
    }

    function test_JoinNFTTransfer_RevokeRole() public {
        address to = address(0x123);
        uint256 tokenId = joinNFT.tokenOfOwnerByIndex(admin, 0);
        vm.expectEmit(address(ospClient));
        emit OspEvents.JoinNFTRoleChanged(
            TEST_COMMUNITY_ID,
            admin,
            admin,
            Constants.COMMUNITY_NULL_ACCESS,
            block.timestamp
        );
        vm.expectEmit(address(ospClient));
        emit OspEvents.JoinNFTTransferred(TEST_COMMUNITY_ID, tokenId, admin, to, block.timestamp);
        vm.prank(admin);
        joinNFT.transferFrom(admin, to, tokenId);
        assert(joinNFT.ownerOf(tokenId) == to);
        assert(ospClient.isJoin(TEST_COMMUNITY_ID, to));
        assertFalse(ospClient.isJoin(TEST_COMMUNITY_ID, admin));
        assertEq(joinNFT.tokenOfOwnerByIndex(to, 0), tokenId);
    }

    function test_burn() public {
        vm.prank(member);
        joinNFT.burn(memberJoinNFTTokenId);
        vm.prank(admin);
        joinNFT.burn(adminJoinNFTTokenId);
        vm.prank(mod);
        joinNFT.burn(modJoinNFTTokenId);
        vm.prank(owner);
        joinNFT.burn(1);

        assertTrue(joinNFT.hasRole(Constants.COMMUNITY_ADMIN_ACCESS, owner));
        assertTrue(joinNFT.hasRole(Constants.COMMUNITY_MODERATOR_ACCESS, owner));
        assertTrue(joinNFT.hasRole(Constants.COMMUNITY_NULL_ACCESS, owner));

        assertFalse(joinNFT.hasRole(Constants.COMMUNITY_ADMIN_ACCESS, admin));
        assertFalse(joinNFT.hasRole(Constants.COMMUNITY_MODERATOR_ACCESS, admin));
        assertTrue(joinNFT.hasRole(Constants.COMMUNITY_NULL_ACCESS, admin));

        assertFalse(joinNFT.hasRole(Constants.COMMUNITY_ADMIN_ACCESS, mod));
        assertFalse(joinNFT.hasRole(Constants.COMMUNITY_MODERATOR_ACCESS, mod));
        assertTrue(joinNFT.hasRole(Constants.COMMUNITY_NULL_ACCESS, mod));

        assertFalse(joinNFT.hasRole(Constants.COMMUNITY_ADMIN_ACCESS, member));
        assertFalse(joinNFT.hasRole(Constants.COMMUNITY_MODERATOR_ACCESS, member));
        assertTrue(joinNFT.hasRole(Constants.COMMUNITY_NULL_ACCESS, member));
    }

    function test_transfer() public {
        uint256 level = 12423;
        address newAccount = makeAddr('newAccount');

        vm.prank(owner);
        joinNFT.setMemberLevel(adminJoinNFTTokenId, level);

        assertEq(joinNFT.getMemberLevel(admin), level);
        assertEq(joinNFT.getMemberLevel(adminJoinNFTTokenId), level);

        vm.prank(admin);
        joinNFT.safeTransferFrom(admin, newAccount, adminJoinNFTTokenId);

        assertEq(joinNFT.getMemberLevel(newAccount), level);
        assertEq(joinNFT.getMemberLevel(adminJoinNFTTokenId), level);

        vm.expectRevert(
            abi.encodeWithSignature('ERC721OutOfBoundsIndex(address,uint256)', admin, 0)
        );
        joinNFT.getMemberLevel(admin);

        assertFalse(joinNFT.hasRole(Constants.COMMUNITY_ADMIN_ACCESS, admin));
    }
}
