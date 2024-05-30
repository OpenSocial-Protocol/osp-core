// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {OspTestSetUp, console} from '../../OspTestSetUp.sol';
import {OspDataTypes} from '../../../../contracts/libraries/OspDataTypes.sol';
import {OspEvents} from '../../../../contracts/libraries/OspEvents.sol';
import '../../mocks/MockFollowCond.sol';
import {IERC721Metadata} from 'forge-std/interfaces/IERC721.sol';
import '@openzeppelin/contracts/utils/Strings.sol';

contract FollowTest is OspTestSetUp {
    using Strings for uint256;

    string constant USER_1_HANDLE = 'user1_handle';
    address mockFollowCond;
    uint256 user1_profile_id;
    uint256 user2_profile_id;

    function setUp() public override {
        super.setUp();
        mockFollowCond = address(new MockFollowCond(address(ospClient)));
        vm.prank(deployer);
        ospClient.whitelistApp(mockFollowCond, true);

        vm.prank(user1);
        user1_profile_id = ospClient.createProfile(
            OspDataTypes.CreateProfileData(
                USER_1_HANDLE,
                abi.encodePacked(mockFollowCond, CORRECT_BYTES),
                0,
                EMPTY_BYTES
            )
        );

        vm.prank(user2);
        user2_profile_id = ospClient.createProfile(
            OspDataTypes.CreateProfileData(
                'user2_handle',
                abi.encodePacked(mockFollowCond, CORRECT_BYTES),
                0,
                EMPTY_BYTES
            )
        );
    }

    function testFollow() public forUser2 {
        vm.expectEmit(address(ospClient));
        emit OspEvents.Followed(
            user2,
            user2_profile_id,
            user1_profile_id,
            CORRECT_BYTES,
            1,
            EMPTY_BYTES,
            block.timestamp
        );
        uint256 tokenId = ospClient.follow(
            OspDataTypes.FollowData(user1_profile_id, CORRECT_BYTES, EMPTY_BYTES)
        );
        address followSBT = ospClient.getFollowSBT(user1_profile_id);

        IERC721Metadata sbt = IERC721Metadata(followSBT);
        assertEq(sbt.balanceOf(user2), 1);
        assertEq(sbt.ownerOf(tokenId), user2);
        assertEq(
            sbt.tokenURI(tokenId),
            string(
                abi.encodePacked(
                    BASE_URL,
                    user1_profile_id.toString(),
                    '/follow/',
                    tokenId.toString()
                )
            )
        );
    }

    function testFollow_WrongConditionData() public forUser2 {
        vm.expectRevert('MockFollowModule: processFollow invalid');
        ospClient.follow(OspDataTypes.FollowData(user1_profile_id, WRONG_BYTES, EMPTY_BYTES));
    }

    function testBatchFollow() public {
        address user3 = makeAddr('user3');
        vm.startPrank(user3);
        uint256 profile3_id = ospClient.createProfile(
            OspDataTypes.CreateProfileData(
                'user3_handle',
                abi.encodePacked(mockFollowCond, CORRECT_BYTES),
                0,
                EMPTY_BYTES
            )
        );

        uint256[] memory profileIds = new uint256[](2);
        profileIds[0] = user1_profile_id;
        profileIds[1] = user2_profile_id;

        bytes[] memory conditionDatas = new bytes[](2);
        conditionDatas[0] = CORRECT_BYTES;
        conditionDatas[1] = CORRECT_BYTES;

        uint256[] memory values = new uint256[](2);

        vm.expectEmit(address(ospClient));

        uint256[] memory expectTokenIds = new uint256[](2);
        expectTokenIds[0] = 1;
        expectTokenIds[1] = 1;

        emit OspEvents.BatchFollowed(
            user3,
            profile3_id,
            profileIds,
            conditionDatas,
            expectTokenIds,
            EMPTY_BYTES,
            block.timestamp
        );

        uint256[] memory tokenIds = ospClient.batchFollow(
            OspDataTypes.BatchFollowData(profileIds, conditionDatas, values, EMPTY_BYTES)
        );

        address followSBT1 = ospClient.getFollowSBT(user1_profile_id);
        address followSBT2 = ospClient.getFollowSBT(user2_profile_id);

        IERC721Metadata sbt1 = IERC721Metadata(followSBT1);
        IERC721Metadata sbt2 = IERC721Metadata(followSBT2);

        assertEq(sbt1.balanceOf(user3), 1);
        assertEq(sbt2.balanceOf(user3), 1);

        assertEq(sbt1.ownerOf(tokenIds[0]), user3);
        assertEq(sbt2.ownerOf(tokenIds[1]), user3);

        assertEq(
            sbt1.tokenURI(tokenIds[0]),
            string(
                abi.encodePacked(
                    BASE_URL,
                    profileIds[0].toString(),
                    '/follow/',
                    tokenIds[0].toString()
                )
            )
        );
        assertEq(
            sbt2.tokenURI(tokenIds[1]),
            string(
                abi.encodePacked(
                    BASE_URL,
                    profileIds[1].toString(),
                    '/follow/',
                    tokenIds[1].toString()
                )
            )
        );
    }
}
