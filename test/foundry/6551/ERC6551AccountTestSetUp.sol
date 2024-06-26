// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import '../community/CreateCommunityTestSetUp.sol';

contract ERC6551AccountTestSetUp is CreateCommunityTestSetUp {
    address owner;
    MockContract mockContract = new MockContract();
    ERC6551Account erc6551Account;

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
        erc6551Account = ERC6551Account(payable(ospClient.getCommunityAccount(TEST_COMMUNITY_ID)));
        JoinNFT joinNFT = JoinNFT(ospClient.getJoinNFT(TEST_COMMUNITY_ID));
        assertEq(address(joinNFT), expectJoinNFTAddress, 'joinNFT not eq');
        OspDataTypes.CommunityStruct memory community = ospClient.getCommunity(TEST_COMMUNITY_ID);
        assertEq(community.joinNFT, expectJoinNFTAddress, 'community joinNFT not eq');
        assertEq(community.handle, COMMUNITY_1_HANDLE, 'handle not eq');
        assertEq(community.joinCondition, ZERO_ADDRESS, 'join condition not eq');
        assertEq(communityNFT.ownerOf(TEST_COMMUNITY_ID), user1, 'owner not eq');
    }
}

library MockContractEvent {
    event MockEvent(uint256 indexed value, uint256 data);
}

contract MockContract {
    function mockFunction(uint256 data) external payable {
        emit MockContractEvent.MockEvent(msg.value, data);
    }
}
