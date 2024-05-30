// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {console} from '../../OspTestSetUp.sol';
import {OspDataTypes} from '../../../../contracts/libraries/OspDataTypes.sol';
import {OspEvents} from '../../../../contracts/libraries/OspEvents.sol';
import '../../mocks/MockFollowCond.sol';
import {IERC721Metadata} from 'forge-std/interfaces/IERC721.sol';
import '@openzeppelin/contracts/utils/Strings.sol';
import '../../community/CreateCommunityTestSetUp.sol';
import '../../mocks/MockJoinCond.sol';

contract JoinTest is CreateCommunityTestSetUp {
    using Strings for uint256;

    string constant COMMUNITY_2_HANDLE = 'community2_handle';
    address mockJoinCondition;
    uint256 communit1_id;
    uint256 communit2_id;
    uint256 user2_profile_id;

    function setUp() public override {
        super.setUp();
        vm.startPrank(deployer);
        mockJoinCondition = address(new MockJoinCond(address(ospClient)));
        ospClient.whitelistApp(mockJoinCondition, true);
        vm.stopPrank();
        vm.startPrank(user1);
        communit1_id = ospClient.createCommunity(
            OspDataTypes.CreateCommunityData(
                COMMUNITY_1_HANDLE,
                abi.encodePacked(mockCommunityCond, CORRECT_BYTES),
                abi.encodePacked(mockJoinCondition, CORRECT_BYTES),
                new string[](0),
                EMPTY_BYTES
            )
        );
        communit2_id = ospClient.createCommunity(
            OspDataTypes.CreateCommunityData(
                COMMUNITY_2_HANDLE,
                abi.encodePacked(mockCommunityCond, CORRECT_BYTES),
                abi.encodePacked(mockJoinCondition, CORRECT_BYTES),
                new string[](0),
                EMPTY_BYTES
            )
        );
        vm.stopPrank();

        vm.prank(user2);
        user2_profile_id = ospClient.createProfile(
            OspDataTypes.CreateProfileData('user2_handle', EMPTY_BYTES, 0, EMPTY_BYTES)
        );
    }

    function testJoin() public forUser2 {
        vm.expectEmit(address(ospClient));
        emit OspEvents.Joined(
            user2,
            user2_profile_id,
            communit1_id,
            CORRECT_BYTES,
            2,
            EMPTY_BYTES,
            block.timestamp
        );
        uint256 tokenId = ospClient.join(
            OspDataTypes.JoinData(communit1_id, CORRECT_BYTES, EMPTY_BYTES)
        );
        IERC721Metadata joinNFT = IERC721Metadata(ospClient.getJoinNFT(communit1_id));

        assertEq(joinNFT.ownerOf(tokenId), user2);
        assertEq(joinNFT.balanceOf(user2), 1);
        assertEq(
            joinNFT.tokenURI(tokenId),
            string(
                abi.encodePacked(BASE_URL, communit1_id.toString(), '/join/', tokenId.toString())
            )
        );
    }

    function testJoin_WrongConditionData() public forUser2 {
        vm.expectRevert('MockJoinCond: processJoin invalid');
        ospClient.join(OspDataTypes.JoinData(communit1_id, WRONG_BYTES, EMPTY_BYTES));
    }

    function testBatchJoin() public forUser2 {
        vm.expectEmit(address(ospClient));

        uint256[] memory communityIds = new uint256[](2);
        communityIds[0] = communit1_id;
        communityIds[1] = communit2_id;

        bytes[] memory conditions = new bytes[](2);
        conditions[0] = CORRECT_BYTES;
        conditions[1] = CORRECT_BYTES;

        uint256[] memory values = new uint256[](2);

        uint256[] memory expectTokenIds = new uint256[](2);
        expectTokenIds[0] = 2;
        expectTokenIds[1] = 2;

        emit OspEvents.BatchJoined(
            user2,
            user2_profile_id,
            communityIds,
            conditions,
            expectTokenIds,
            EMPTY_BYTES,
            block.timestamp
        );

        uint256[] memory tokenIds = ospClient.batchJoin(
            OspDataTypes.BatchJoinData(communityIds, conditions, values, EMPTY_BYTES)
        );

        IERC721Metadata joinNFT1 = IERC721Metadata(ospClient.getJoinNFT(communit1_id));
        IERC721Metadata joinNFT2 = IERC721Metadata(ospClient.getJoinNFT(communit2_id));

        assertEq(joinNFT1.ownerOf(tokenIds[0]), user2);
        assertEq(joinNFT2.ownerOf(tokenIds[1]), user2);
        assertEq(joinNFT1.balanceOf(user2), 1);
        assertEq(joinNFT2.balanceOf(user2), 1);
        assertEq(
            joinNFT1.tokenURI(tokenIds[0]),
            string(
                abi.encodePacked(
                    BASE_URL,
                    communit1_id.toString(),
                    '/join/',
                    tokenIds[0].toString()
                )
            )
        );
        assertEq(
            joinNFT2.tokenURI(tokenIds[1]),
            string(
                abi.encodePacked(
                    BASE_URL,
                    communit2_id.toString(),
                    '/join/',
                    tokenIds[1].toString()
                )
            )
        );
    }
}
