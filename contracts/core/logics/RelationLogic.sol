// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import '../../libraries/Constants.sol';
import '../../interfaces/IFollowCondition.sol';
import '../../interfaces/IFollowSBT.sol';
import '../../upgradeability/FollowSBTProxy.sol';
import '../../interfaces/IJoinCondition.sol';
import '../../interfaces/IJoinNFT.sol';
import './OspLogicBase.sol';
import './interfaces/IRelationLogic.sol';
import '@openzeppelin/contracts/utils/Strings.sol';
import '@openzeppelin/contracts/token/ERC721/IERC721.sol';

/**
 * @title RelationLogic
 * @author OpenSocial Protocol
 * @dev RelationLogic is logic contract that manages the relations of the protocol.
 * Relation includes the relationship between users and the relationship between users and the community
 */
contract RelationLogic is IRelationLogic, OspLogicBase {
    using Strings for uint256;

    /*///////////////////////////////////////////////////////////////
                        Public functions
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IRelationLogic
    function follow(
        OspDataTypes.FollowData calldata vars
    ) external payable override whenNotPaused returns (uint256) {
        return _follow(vars.profileId, vars.data, vars.ctx);
    }

    /// @inheritdoc IRelationLogic
    function batchFollow(
        OspDataTypes.BatchFollowData calldata vars
    ) external payable override whenNotPaused returns (uint256[] memory) {
        return _batchFollow(vars.profileIds, vars.datas, vars.values, vars.ctx);
    }

    /// @inheritdoc IRelationLogic
    function join(
        OspDataTypes.JoinData calldata vars
    ) external payable override whenNotPaused returns (uint256) {
        return _join(vars.communityId, vars.data, vars.ctx);
    }

    /// @inheritdoc IRelationLogic
    function batchJoin(
        OspDataTypes.BatchJoinData calldata vars
    ) external payable override whenNotPaused returns (uint256[] memory) {
        return _batchJoin(vars.communityIds, vars.datas, vars.values, vars.ctx);
    }

    /// @inheritdoc IRelationLogic
    function getFollowSBTURI(
        uint256 profileId,
        uint256 tokenId
    ) external view override returns (string memory) {
        string memory baseURI = _getGovernanceStorage()._baseURI;
        return
            bytes(baseURI).length > 0
                ? string(
                    abi.encodePacked(baseURI, profileId.toString(), '/follow/', tokenId.toString())
                )
                : tokenId.toString();
    }

    /// @inheritdoc IRelationLogic
    function getJoinNFTURI(
        uint256 communityId,
        uint256 tokenId
    ) external view override returns (string memory) {
        string memory baseURI = _getGovernanceStorage()._baseURI;
        return
            bytes(baseURI).length > 0
                ? string(
                    abi.encodePacked(baseURI, communityId.toString(), '/join/', tokenId.toString())
                )
                : tokenId.toString();
    }

    /// @inheritdoc IRelationLogic
    function isFollow(uint256 profileId, address addr) external view override returns (bool) {
        address followSBT = _getProfileStorage()._profileById[profileId].followSBT;
        return followSBT == address(0) ? false : IERC721(followSBT).balanceOf(addr) > 0;
    }

    /// @inheritdoc IRelationLogic
    function isJoin(uint256 communityId, address addr) external view override returns (bool) {
        address joinNFT = _getCommunityStorage()._communityById[communityId].joinNFT;
        return IERC721(joinNFT).balanceOf(addr) > 0;
    }

    /// @inheritdoc IRelationLogic
    function emitFollowSBTTransferEvent(
        uint256 profileId,
        uint256 followSBTId,
        address from,
        address to
    ) external override {
        if (_getProfileStorage()._profileById[profileId].followSBT != msg.sender) {
            revert OspErrors.NotJoinNFT();
        }
        emit OspEvents.FollowSBTTransferred(profileId, followSBTId, from, to, block.timestamp);
    }

    /// @inheritdoc IRelationLogic
    function emitJoinNFTTransferEvent(
        uint256 communityId,
        uint256 joinNFTId,
        address from,
        address to
    ) external override {
        if (_getCommunityStorage()._communityById[communityId].joinNFT != msg.sender) {
            revert OspErrors.NotFollowSBT();
        }
        address joinCondition = _getCommunityStorage()._communityById[communityId].joinCondition;
        if (joinCondition != address(0)) {
            IJoinCondition(joinCondition).processTransferJoinNFT(communityId, joinNFTId, from, to);
        }
        emit OspEvents.JoinNFTTransferred(communityId, joinNFTId, from, to, block.timestamp);
    }

    /*///////////////////////////////////////////////////////////////
                        Internal functions
    //////////////////////////////////////////////////////////////*/

    function _follow(
        uint256 targetProfileId,
        bytes calldata followConditionData,
        bytes calldata ctx
    ) internal returns (uint256 tokenId) {
        uint256 profileId = _validateHasProfile(msg.sender);
        tokenId = _executeFollow(targetProfileId, followConditionData, msg.value);
        emit OspEvents.Followed(
            msg.sender,
            profileId,
            targetProfileId,
            followConditionData,
            ctx,
            block.timestamp
        );
    }

    /**
     * @dev Follows the given profiles, executing the necessary logic and condition calls before minting the follow
     * NFT(s) to the follower.
     *
     * @param targetProfileIds The array of profile token IDs to follow.
     * @param followConditionDatas The array of follow condition data parameters to pass to each profile's follow condition.
     *
     * @return uint256[] An array of integers representing the minted follow NFTs token IDs.
     */
    function _batchFollow(
        uint256[] calldata targetProfileIds,
        bytes[] calldata followConditionDatas,
        uint256[] calldata values,
        bytes calldata ctx
    ) internal returns (uint256[] memory) {
        uint256 profileId = _validateHasProfile(msg.sender);
        uint256 length = targetProfileIds.length;
        if (length != followConditionDatas.length || length != values.length)
            revert OspErrors.ArrayMismatch();
        uint256[] memory tokenIds = new uint256[](length);
        uint256 batchValue;
        for (uint256 i; i < length; ) {
            batchValue += values[i];
            tokenIds[i] = _executeFollow(targetProfileIds[i], followConditionDatas[i], values[i]);
            unchecked {
                ++i;
            }
        }
        if (batchValue > msg.value) {
            revert OspErrors.InvalidValue();
        }
        emit OspEvents.BatchFollowed(
            msg.sender,
            profileId,
            targetProfileIds,
            followConditionDatas,
            ctx,
            block.timestamp
        );
        return tokenIds;
    }

    function _executeFollow(
        uint256 profileId,
        bytes calldata followConditionData,
        uint256 value
    ) internal returns (uint256 tokenId) {
        address owner = _getProfileStorage()._profileById[profileId].owner;
        if (owner == address(0)) revert OspErrors.TokenDoesNotExist();
        if (owner == msg.sender) revert OspErrors.InvalidProfileId();
        address followCondition = _getProfileStorage()._profileById[profileId].followCondition;
        address followSBT = _getProfileStorage()._profileById[profileId].followSBT;

        if (followSBT == address(0)) {
            followSBT = _deployFollowSBT(profileId);
            _getProfileStorage()._profileById[profileId].followSBT = followSBT;
        }

        tokenId = IFollowSBT(followSBT).mint(msg.sender);

        if (followCondition != address(0)) {
            IFollowCondition(followCondition).processFollow{value: value}(
                msg.sender,
                profileId,
                followConditionData
            );
        }
    }

    /**
     * @dev Deploys the given profile's Follow SBT contract.
     *
     * @param profileId The token ID of the profile which Follow SBT should be deployed.
     *
     * @return address The address of the deployed Follow SBT contract.
     */
    function _deployFollowSBT(uint256 profileId) internal returns (address) {
        string memory idStr = Strings.toString(profileId);
        string memory name = string(abi.encodePacked(idStr, Constants.FOLLOW_NFT_NAME_SUFFIX));
        string memory symbol = string(abi.encodePacked(idStr, Constants.FOLLOW_NFT_SYMBOL_SUFFIX));

        bytes memory functionData = abi.encodeWithSelector(
            IFollowSBT.initialize.selector,
            profileId,
            name,
            symbol
        );
        address followSBT = address(new FollowSBTProxy(functionData));
        emit OspEvents.FollowSBTDeployed(profileId, followSBT, block.timestamp);
        return followSBT;
    }

    /**
     * @dev Joins the given community, executing the necessary logic and condition calls before minting the join
     * NFT to the follower.
     *
     * @param communityId The token ID of the community to join.
     * @param joinConditionData The join condition data parameters to pass to the community's join condition.
     *
     * @return tokenId An integer representing the minted join NFTs token ID.
     */
    function _join(
        uint256 communityId,
        bytes calldata joinConditionData,
        bytes calldata ctx
    ) internal returns (uint256 tokenId) {
        uint256 profileId = _validateHasProfile(msg.sender);
        tokenId = _executeJoin(communityId, joinConditionData, msg.value);
        emit OspEvents.Joined(
            msg.sender,
            profileId,
            communityId,
            joinConditionData,
            ctx,
            block.timestamp
        );
    }

    /**
     * @dev Joins the given communities, executing the necessary logic and condition calls before minting the join
     * NFT(s) to the follower.
     *
     * @param communityIds The array of community token IDs to join.
     * @param joinConditionDatas The array of join condition data parameters to pass to each community's join condition.
     * @param values The array of values to send to each community's join condition.
     *
     * @return uint256[] An array of integers representing the minted join NFTs token IDs.
     */
    function _batchJoin(
        uint256[] calldata communityIds,
        bytes[] calldata joinConditionDatas,
        uint256[] calldata values,
        bytes calldata ctx
    ) internal returns (uint256[] memory) {
        uint256 profileId = _validateHasProfile(msg.sender);
        uint256 length = communityIds.length;
        if (length != joinConditionDatas.length || length != values.length)
            revert OspErrors.ArrayMismatch();
        uint256[] memory tokenIds = new uint256[](length);
        uint256 batchValue;
        for (uint256 i; i < length; ) {
            batchValue += values[i];
            tokenIds[i] = _executeJoin(communityIds[i], joinConditionDatas[i], values[i]);
            unchecked {
                ++i;
            }
        }
        if (batchValue > msg.value) {
            revert OspErrors.InvalidValue();
        }
        emit OspEvents.BatchJoined(
            msg.sender,
            profileId,
            communityIds,
            joinConditionDatas,
            ctx,
            block.timestamp
        );
        return tokenIds;
    }

    /**
     * @dev Executes the join logic for a given community, minting the join NFT to the follower and processing the
     * community's join condition logic (if any).
     *
     * @param communityId The token ID of the community to join.
     * @param joinConditionData The join condition data parameters to pass to the community's join condition.
     * @param value The value to send to the community's join condition.
     *
     * @return tokenId An integer representing the minted join NFTs token ID.
     */
    function _executeJoin(
        uint256 communityId,
        bytes calldata joinConditionData,
        uint256 value
    ) internal returns (uint256 tokenId) {
        OspDataTypes.CommunityStruct memory community = _getCommunityStorage()._communityById[
            communityId
        ];
        if (community.joinNFT == address(0)) revert OspErrors.InvalidCommunityId();
        tokenId = IJoinNFT(community.joinNFT).mint(msg.sender);
        if (community.joinCondition != address(0)) {
            IJoinCondition(community.joinCondition).processJoin{value: value}(
                msg.sender,
                communityId,
                joinConditionData
            );
        }
    }
}
