// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import './JoinNFTTestSetUp.sol';

contract JoinNFTTest is JoinNFTTestSetUp {
    function test_burn() public {
        vm.prank(member);
        joinNFT.burn(memberJoinNFTTokenId);
        vm.prank(owner);
        joinNFT.burn(1);
    }

    function test_transfer() public {
        uint256 level = 12423;
        address newAccount = makeAddr('newAccount');

        vm.prank(owner);
        joinNFT.setMemberLevel(member, level);

        assertEq(joinNFT.getMemberLevel(member), level);
        assertEq(joinNFT.getMemberLevel(memberJoinNFTTokenId), level);

        vm.prank(member);
        joinNFT.safeTransferFrom(member, newAccount, memberJoinNFTTokenId);

        assertEq(joinNFT.getMemberLevel(newAccount), level);
        assertEq(joinNFT.getMemberLevel(memberJoinNFTTokenId), level);

        vm.expectRevert(
            abi.encodeWithSignature('ERC721OutOfBoundsIndex(address,uint256)', member, 0)
        );
        joinNFT.getMemberLevel(member);
    }
}
