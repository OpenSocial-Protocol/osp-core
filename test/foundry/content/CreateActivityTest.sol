// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import './ContentTestSetUp.sol';
import '../MetaTxNegatives.sol';

contract CreateActivityTest is ContentTestSetUp {
    function testCreateActivity_NoExtension() public {
        vm.expectEmit(address(ospClient));
        emit OspEvents.ActivityCreated(
            USER_1_PROFILE_ID,
            1,
            COMMUNITY_1_ID,
            MOCK_URL,
            ZERO_ADDRESS,
            ZERO_ADDRESS,
            EMPTY_BYTES,
            block.timestamp
        );
        uint256 contentId = _createActivity(
            OspDataTypes.CreateActivityData(
                USER_1_PROFILE_ID,
                COMMUNITY_1_ID,
                MOCK_URL,
                EMPTY_BYTES,
                EMPTY_BYTES,
                EMPTY_BYTES
            )
        );
        assertEq(contentId, 1, 'contentId not 1');
        OspDataTypes.ContentStruct memory content = ospClient.getContent(USER_1_PROFILE_ID, 1);
        assertEq(content.communityId, COMMUNITY_1_ID, 'community id not eq');
        assertEq(content.referencedProfileId, 0, 'referencedProfileId not eq');
        assertEq(content.referencedContentId, 0, 'referencedContentId not eq');
        assertEq(content.contentURI, MOCK_URL, 'contentURI not eq');
        assertEq(content.extension, ZERO_ADDRESS, 'extension not eq');
        console.log('contentId :', contentId);
    }

    function testCreateActivity_WithExtension() public {
        vm.expectEmit(address(ospClient));
        emit OspEvents.ActivityCreated(
            USER_1_PROFILE_ID,
            1,
            COMMUNITY_1_ID,
            MOCK_URL,
            mockActivityExtension,
            ZERO_ADDRESS,
            EMPTY_BYTES,
            block.timestamp
        );
        uint256 contentId = _createActivity(
            OspDataTypes.CreateActivityData(
                USER_1_PROFILE_ID,
                COMMUNITY_1_ID,
                MOCK_URL,
                abi.encodePacked(mockActivityExtension, CORRECT_BYTES),
                EMPTY_BYTES,
                EMPTY_BYTES
            )
        );
        assertEq(contentId, 1, 'contentId not 1');
        OspDataTypes.ContentStruct memory content = ospClient.getContent(USER_1_PROFILE_ID, 1);
        assertEq(content.communityId, COMMUNITY_1_ID, 'community id not eq');
        assertEq(content.referencedProfileId, 0, 'referencedProfileId not eq');
        assertEq(content.referencedContentId, 0, 'referencedContentId not eq');
        assertEq(content.contentURI, MOCK_URL, 'contentURI not eq');
        assertEq(content.extension, mockActivityExtension, 'extension not eq');
        console.log('contentId :', contentId);
    }

    function testCreateActivity_WithExtension_IfWrongExtensionData() public {
        vm.expectRevert('MockActivityExtension: initializeActivityExtension invalid');
        _createActivity(
            OspDataTypes.CreateActivityData(
                USER_1_PROFILE_ID,
                COMMUNITY_1_ID,
                MOCK_URL,
                abi.encodePacked(mockActivityExtension, WRONG_BYTES),
                EMPTY_BYTES,
                EMPTY_BYTES
            )
        );
    }

    function _createActivity(
        OspDataTypes.CreateActivityData memory data
    ) internal virtual forUser1 returns (uint256) {
        return ospClient.createActivity(data);
    }
}

contract CreateActivityMetaTxTest is CreateActivityTest, MetaTxNegatives {
    uint256 user1Nonce;

    function setUp() public override(ContentTestSetUp, MetaTxNegatives) {
        ContentTestSetUp.setUp();
        MetaTxNegatives.setUp();
        user1Nonce = ospClient.nonces(user1);
    }

    function _executeMetaTx(
        uint256 signerPk,
        uint256 nonce,
        uint256 deadline
    ) internal virtual override {
        OspDataTypes.CreateActivityData memory data = OspDataTypes.CreateActivityData(
            USER_1_PROFILE_ID,
            COMMUNITY_1_ID,
            MOCK_URL,
            EMPTY_BYTES,
            EMPTY_BYTES,
            EMPTY_BYTES
        );
        ospClient.createActivityWithSig(
            data,
            _getSigStruct(
                signerPk,
                _getCreateActivityTypedDataHash(data, deadline, nonce),
                deadline
            )
        );
    }

    function _getDefaultMetaTxSignerPk() internal virtual override returns (uint256) {
        return user1PK;
    }

    function _createActivity(
        OspDataTypes.CreateActivityData memory data
    ) internal override returns (uint256) {
        return
            ospClient.createActivityWithSig(
                data,
                _getSigStruct(
                    user1PK,
                    _getCreateActivityTypedDataHash(data, type(uint256).max, user1Nonce),
                    type(uint256).max
                )
            );
    }
}
