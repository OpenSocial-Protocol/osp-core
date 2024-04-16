// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import './CreateReactionTestSetUp.sol';
import '../../MetaTxNegatives.sol';

contract CreateCommentTest is CreateReactionTestSetUp {
    address commentReaction;

    function testCreateComment_Event() public {
        vm.expectEmit(address(ospClient));
        emit OspEvents.CommentCreated(
            USER_1_PROFILE_ID,
            2,
            COMMUNITY_1_ID,
            MOCK_URL,
            USER_1_PROFILE_ID,
            CONTENT_1_ID,
            ZERO_ADDRESS,
            EMPTY_BYTES,
            block.timestamp
        );
        uint256 contentId = _createComment(
            OspDataTypes.CreateCommentData(
                USER_1_PROFILE_ID,
                COMMUNITY_1_ID,
                MOCK_URL,
                USER_1_PROFILE_ID,
                CONTENT_1_ID,
                EMPTY_BYTES,
                EMPTY_BYTES,
                EMPTY_BYTES
            )
        );
        assertEq(contentId, 2, 'contentId not eq 2');
        OspDataTypes.ContentStruct memory content = ospClient.getContent(
            USER_1_PROFILE_ID,
            contentId
        );
        assertEq(content.referencedProfileId, USER_1_PROFILE_ID, 'referencedProfileId not eq');
        assertEq(content.referencedContentId, CONTENT_1_ID, 'referencedContentId not eq');
        assertEq(content.contentURI, MOCK_URL, 'contentURI not eq');
        assertEq(content.extension, ZERO_ADDRESS, 'extension not eq');
    }

    function _createComment(
        OspDataTypes.CreateCommentData memory data
    ) internal virtual forUser1 returns (uint256) {
        return ospClient.createComment(data);
    }
}

contract CreateCommentMetaTxTest is CreateCommentTest, MetaTxNegatives {
    uint256 user1Nonce;

    function setUp() public override(CreateReactionTestSetUp, MetaTxNegatives) {
        CreateReactionTestSetUp.setUp();
        MetaTxNegatives.setUp();
        user1Nonce = ospClient.nonces(user1);
    }

    function _executeMetaTx(
        uint256 signerPk,
        uint256 nonce,
        uint256 deadline
    ) internal virtual override {
        OspDataTypes.CreateCommentData memory data = OspDataTypes.CreateCommentData(
            USER_1_PROFILE_ID,
            COMMUNITY_1_ID,
            MOCK_URL,
            USER_1_PROFILE_ID,
            CONTENT_1_ID,
            EMPTY_BYTES,
            EMPTY_BYTES,
            EMPTY_BYTES
        );
        ospClient.createCommentWithSig(
            data,
            _getSigStruct(signerPk, _getCreateCommentTypedDataHash(data, deadline, nonce), deadline)
        );
    }

    function _getDefaultMetaTxSignerPk() internal virtual override returns (uint256) {
        return user1PK;
    }

    function _createComment(
        OspDataTypes.CreateCommentData memory data
    ) internal override returns (uint256) {
        return
            ospClient.createCommentWithSig(
                data,
                _getSigStruct(
                    user1PK,
                    _getCreateCommentTypedDataHash(data, type(uint256).max, user1Nonce),
                    type(uint256).max
                )
            );
    }
}
