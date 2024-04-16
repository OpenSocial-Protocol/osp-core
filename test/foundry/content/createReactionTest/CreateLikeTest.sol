// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import './CreateReactionTestSetUp.sol';
import '../../../../contracts/core/reactions/LikeReaction.sol';
import '../../MetaTxNegatives.sol';

contract CreateLikeTest is CreateReactionTestSetUp {
    address likeReaction;

    function setUp() public virtual override {
        super.setUp();
        vm.startPrank(deployer);
        likeReaction = address(new LikeReaction(address(ospClient)));
        ospClient.whitelistApp(likeReaction, true);
        vm.stopPrank();
    }

    function testCreateLike() public {
        vm.expectEmit(address(ospClient));
        bytes memory likeData = abi.encode(true);
        emit OspEvents.OpenReactionCreated(
            USER_1_PROFILE_ID,
            USER_1_PROFILE_ID,
            CONTENT_1_ID,
            COMMUNITY_1_ID,
            likeReaction,
            abi.encode(true),
            EMPTY_BYTES,
            block.timestamp
        );
        _createOpenReaction(
            OspDataTypes.CreateOpenReactionData(
                USER_1_PROFILE_ID,
                COMMUNITY_1_ID,
                USER_1_PROFILE_ID,
                CONTENT_1_ID,
                0,
                abi.encodePacked(likeReaction, likeData),
                EMPTY_BYTES,
                EMPTY_BYTES
            )
        );
    }

    function _createOpenReaction(
        OspDataTypes.CreateOpenReactionData memory data
    ) internal virtual forUser1 {
        ospClient.createOpenReaction(data);
    }
}

contract CreateLikeCreateCommentMetaTxTest is CreateLikeTest, MetaTxNegatives {
    uint256 user1Nonce;

    function setUp() public override(CreateLikeTest, MetaTxNegatives) {
        CreateLikeTest.setUp();
        MetaTxNegatives.setUp();
        user1Nonce = ospClient.nonces(user1);
    }

    function _executeMetaTx(
        uint256 signerPk,
        uint256 nonce,
        uint256 deadline
    ) internal virtual override {
        OspDataTypes.CreateOpenReactionData memory data = OspDataTypes.CreateOpenReactionData(
            USER_1_PROFILE_ID,
            COMMUNITY_1_ID,
            USER_1_PROFILE_ID,
            CONTENT_1_ID,
            0,
            abi.encodePacked(likeReaction, abi.encode(true)),
            EMPTY_BYTES,
            EMPTY_BYTES
        );
        ospClient.createOpenReactionWithSig(
            data,
            _getSigStruct(
                signerPk,
                _getCreateOpenReactionTypedDataHash(data, deadline, nonce),
                deadline
            )
        );
    }

    function _getDefaultMetaTxSignerPk() internal virtual override returns (uint256) {
        return user1PK;
    }

    function _createOpenReaction(
        OspDataTypes.CreateOpenReactionData memory data
    ) internal override {
        ospClient.createOpenReactionWithSig(
            data,
            _getSigStruct(
                user1PK,
                _getCreateOpenReactionTypedDataHash(data, type(uint256).max, user1Nonce),
                type(uint256).max
            )
        );
    }
}
