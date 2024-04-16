// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import './CreateCommunityTestSetUp.sol';
import '../mocks/MockCommunityCond.sol';

contract CreateCommunityTest_Event is CreateCommunityTestSetUp {
    function _createCommunity() public forUser1 {
        ospClient.createCommunity(
            OspDataTypes.CreateCommunityData({
                handle: COMMUNITY_1_HANDLE,
                communityConditionAndData: abi.encodePacked(mockCommunityCond, CORRECT_BYTES),
                joinConditionInitCode: EMPTY_BYTES,
                tags: EMPTY_STRINGS,
                ctx: EMPTY_BYTES
            })
        );
    }

    function testCreateCommunity_CommunityCreated_Event() public {
        address expectJoinNFTAddress = computeCreateAddress(
            address(ospClient),
            vm.getNonce(address(ospClient))
        );
        vm.expectEmit(address(ospClient));
        emit OspEvents.CommunityCreated(
            TEST_COMMUNITY_ID,
            user1,
            COMMUNITY_1_HANDLE,
            abi.encodePacked(mockCommunityCond, CORRECT_BYTES),
            ZERO_ADDRESS,
            expectJoinNFTAddress,
            EMPTY_STRINGS,
            EMPTY_BYTES,
            block.timestamp
        );
        _createCommunity();
    }

    function testCreateCommunity_JoinNFTTransferred_Event() public {
        vm.expectEmit(address(ospClient));
        emit OspEvents.JoinNFTTransferred(
            TEST_COMMUNITY_ID,
            1,
            ZERO_ADDRESS,
            user1,
            block.timestamp
        );
        _createCommunity();
    }

    function testCreateCommunity_JoinNFTDeployed_Event() public {
        address expectJoinNFTAddress = computeCreateAddress(
            address(ospClient),
            vm.getNonce(address(ospClient))
        );
        vm.expectEmit(address(ospClient));
        emit OspEvents.JoinNFTDeployed(TEST_COMMUNITY_ID, expectJoinNFTAddress, block.timestamp);
        _createCommunity();
    }

    function testCreateCommunity_CommunityNFTTransferred_Event() public {
        vm.expectEmit(address(ospClient));
        emit OspEvents.CommunityNFTTransferred(
            TEST_COMMUNITY_ID,
            ZERO_ADDRESS,
            user1,
            block.timestamp
        );
        _createCommunity();
    }
}
