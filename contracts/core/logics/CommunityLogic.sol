// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import './OspLogicBase.sol';
import './interfaces/ICommunityLogic.sol';
import '../../libraries/OspDataTypes.sol';
import '../../libraries/OspErrors.sol';
import '../../libraries/Constants.sol';
import '../../interfaces/ICommunityCondition.sol';
import '../../interfaces/ICommunityNFT.sol';
import '../../interfaces/IJoinNFT.sol';
import '../../interfaces/IJoinCondition.sol';
import '../../interfaces/IERC6551Registry.sol';
import '../../upgradeability/JoinNFTProxy.sol';
import '@openzeppelin/contracts/utils/Strings.sol';
import '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import '@openzeppelin/contracts/utils/structs/EnumerableSet.sol';
import '../base/ERC6551Account.sol';

/**
 * @title CommunityLogic
 * @author OpenSocial Protocol
 * @dev CommunityLogic is a contract to interact with the community.
 */
contract CommunityLogic is OspLogicBase, ICommunityLogic {
    using Strings for uint256;
    using EnumerableSet for EnumerableSet.Bytes32Set;

    /*///////////////////////////////////////////////////////////////
                      Public functions
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc ICommunityLogic
    function createCommunity(
        OspDataTypes.CreateCommunityData calldata vars
    ) external payable override whenNotPaused returns (uint256) {
        return _createCommunity(vars);
    }

    /// @inheritdoc ICommunityLogic
    function emitCommunityNFTTransferEvent(
        uint256 communityId,
        address from,
        address to
    ) external override {
        if (_getGovernanceStorage()._communityNFT != msg.sender) {
            revert OspErrors.NotCommunityNFT();
        }
        emit OspEvents.CommunityNFTTransferred(communityId, from, to, block.timestamp);
    }

    /// @inheritdoc ICommunityLogic
    function setJoinCondition(
        uint256 communityId,
        bytes calldata joinConditionInitCode
    ) external override whenNotPaused {
        _validateCallerIsCommunityOwner(communityId);
        _setJoinCondition(communityId, joinConditionInitCode);
    }

    /// @inheritdoc ICommunityLogic
    function updateTags(
        uint256 communityId,
        string[] calldata tags
    ) external override whenNotPaused {
        _validateCallerIsCommunityOwner(communityId);
        emit OspEvents.CommunityTagsUpdated(communityId, tags, block.timestamp);
    }

    /*///////////////////////////////////////////////////////////////
                       Public read functions
    /////////////////////////////////////////////////////////////*/
    function getCommunityTokenURI(
        uint256 communityId
    ) external view override returns (string memory) {
        string memory baseURI = _getGovernanceStorage()._baseURI;
        return
            bytes(baseURI).length > 0
                ? string(abi.encodePacked(baseURI, 'community/', communityId.toString()))
                : communityId.toString();
    }

    /// @inheritdoc ICommunityLogic
    function getCommunity(
        uint256 communityId
    ) external view override returns (OspDataTypes.CommunityStruct memory) {
        CommunityStorage storage communityStorage = _getCommunityStorage();
        OspDataTypes.CommunityStruct memory communityData = communityStorage._communityById[
            communityId
        ];
        return communityData;
    }

    /// @inheritdoc ICommunityLogic
    function getJoinNFT(uint256 communityId) external view override returns (address) {
        CommunityStorage storage communityStorage = _getCommunityStorage();
        return communityStorage._communityById[communityId].joinNFT;
    }

    /// @inheritdoc ICommunityLogic
    function getJoinCondition(uint256 communityId) external view override returns (address) {
        CommunityStorage storage communityStorage = _getCommunityStorage();
        return communityStorage._communityById[communityId].joinCondition;
    }

    /// @inheritdoc ICommunityLogic
    function getCommunityIdByHandle(string calldata handle) public view override returns (uint256) {
        return _getCommunityStorage()._communityIdByHandleHash[keccak256(bytes(handle))];
    }

    /// @inheritdoc ICommunityLogic
    function getCommunityAccount(uint256 communityId) public view override returns (address) {
        return
            IERC6551Registry(Constants.ERC6551_REGISTRY).account(
                _getGovernanceStorage()._communityAccountProxy,
                Constants.COMMUNITY_TBA_SALT,
                block.chainid,
                _getGovernanceStorage()._communityNFT,
                communityId
            );
    }

    /// @inheritdoc ICommunityLogic
    function getCommunityAccount(string calldata handle) external view override returns (address) {
        return getCommunityAccount(getCommunityIdByHandle(handle));
    }

    /*///////////////////////////////////////////////////////////////
                        Internal functions
    //////////////////////////////////////////////////////////////*/

    function _setJoinCondition(uint256 communityId, bytes calldata joinConditionInitCode) internal {
        address joinCondition = _initJoinCondition(communityId, joinConditionInitCode);
        _getCommunityStorage()._communityById[communityId].joinCondition = joinCondition;
        emit OspEvents.JoinConditionSet(communityId, joinCondition, block.timestamp);
    }

    function _createCommunity(
        OspDataTypes.CreateCommunityData calldata vars
    ) internal returns (uint256 communityId) {
        if (vars.tags.length > Constants.MAX_TAGS_NUMBER) revert OspErrors.TooManyTags();
        bool isSuperCreator = _hashRole(Constants.SUPER_COMMUNITY_CREATOR, msg.sender);
        if (!isSuperCreator) {
            _validateHasProfile(msg.sender);
            _validateCommunityCondition(
                msg.sender,
                vars.handle,
                vars.communityConditionAndData,
                msg.value
            );
        }
        // mint community NFT
        communityId = ICommunityNFT(_communityNFT()).mint(msg.sender);
        // validate and register handle
        _registerHandle(vars.handle, isSuperCreator, communityId);
        // deploy Join NFT
        address joinNFT = _deployJoinNFT(communityId, vars.handle);
        // deploy community TBA
        _deployCommunityTBA(communityId);
        _getCommunityStorage()._communityById[communityId].joinNFT = joinNFT;
        IJoinNFT(joinNFT).mint(msg.sender);
        //init join condition
        address joinCondition;
        if (vars.joinConditionInitCode.length != 0) {
            joinCondition = _initJoinCondition(communityId, vars.joinConditionInitCode);
            _getCommunityStorage()._communityById[communityId].joinCondition = joinCondition;
        }
        emit OspEvents.CommunityCreated(
            communityId,
            msg.sender,
            vars.handle,
            vars.communityConditionAndData,
            joinCondition,
            joinNFT,
            vars.tags,
            vars.ctx,
            block.timestamp
        );
    }

    function _initJoinCondition(
        uint256 communityId,
        bytes calldata initCode
    ) private returns (address joinCondition) {
        joinCondition = address(bytes20(initCode[:20]));
        _checkJoinCondition(joinCondition);
        bytes memory initCallData = initCode[20:];
        IJoinCondition(joinCondition).initializeCommunityJoinCondition(communityId, initCallData);
    }

    /**
     * @dev Deploys the given community's Join NFT contract.
     * @param communityId The token ID of the profile which Collect NFT should be deployed.
     * @param handle The profile's associated handle.
     *
     * @return address The address of the deployed Collect NFT contract.
     */
    function _deployJoinNFT(uint256 communityId, string memory handle) internal returns (address) {
        string memory idStr = communityId.toString();
        string memory name = string(abi.encodePacked(idStr, Constants.JOIN_NFT_NAME_SUFFIX));
        string memory symbol = string(abi.encodePacked(idStr, Constants.JOIN_NFT_SYMBOL_SUFFIX));

        bytes memory functionData = abi.encodeWithSelector(
            IJoinNFT.initialize.selector,
            communityId,
            name,
            symbol
        );
        address joinNFT = address(new JoinNFTProxy(functionData));
        emit OspEvents.JoinNFTDeployed(communityId, joinNFT, block.timestamp);
        return joinNFT;
    }

    function _deployCommunityTBA(uint256 communityId) internal returns (address) {
        if (_getGovernanceStorage()._erc6551AccountImpl == address(0)) {
            revert OspErrors.ERC6551AccountImplNotDeployed();
        }
        address tbaAccount = IERC6551Registry(Constants.ERC6551_REGISTRY).createAccount(
            _getGovernanceStorage()._communityAccountProxy,
            Constants.COMMUNITY_TBA_SALT,
            block.chainid,
            _communityNFT(),
            communityId
        );
        ERC6551Account(tbaAccount).initialize(communityId);
        return tbaAccount;
    }

    function _validateCommunityCondition(
        address creator,
        string calldata handle,
        bytes calldata communityConditionAndData,
        uint256 value
    ) internal {
        address communityCondition = address(bytes20(communityConditionAndData[:20]));
        _checkCommunityCondition(communityCondition);
        bytes memory callData = communityConditionAndData[20:];
        ICommunityCondition(communityCondition).processCreateCommunity{value: value}(
            creator,
            handle,
            callData
        );
    }

    function _validateHandle(
        string calldata handle,
        bool isSuperCreator,
        CommunityStorage storage communityStorage
    ) internal view returns (bytes32 hash) {
        bytes memory byteHandle = bytes(handle);
        bytes32 handleHash = keccak256(bytes(handle));
        if (byteHandle.length == 0 || byteHandle.length > Constants.MAX_COMMUNITY_NAME_LENGTH)
            revert OspErrors.HandleLengthInvalid();
        GovernanceStorage storage governanceStorage = _getGovernanceStorage();
        if (governanceStorage._reserveCommunityHandleHash[handleHash] && !isSuperCreator)
            revert OspErrors.HandleTaken();
        if (communityStorage._communityIdByHandleHash[handleHash] != 0)
            revert OspErrors.HandleTaken();
        uint256 byteHandleLength = byteHandle.length;
        for (uint256 i; i < byteHandleLength; ) {
            if (
                (byteHandle[i] < '0' ||
                    byteHandle[i] > 'z' ||
                    (byteHandle[i] > '9' && byteHandle[i] < 'A') ||
                    (byteHandle[i] > 'Z' && byteHandle[i] < 'a')) && byteHandle[i] != '_'
            ) revert OspErrors.HandleContainsInvalidCharacters();
            unchecked {
                ++i;
            }
        }
        return keccak256(byteHandle);
    }

    function _registerHandle(
        string calldata handle,
        bool isSuperCreator,
        uint256 communityId
    ) internal {
        CommunityStorage storage communityStorage = _getCommunityStorage();
        bytes32 handleHash = _validateHandle(handle, isSuperCreator, communityStorage);
        communityStorage._communityIdByHandleHash[handleHash] = communityId;
        communityStorage._communityById[communityId].handle = handle;
    }

    function _validateCallerIsCommunityOwner(uint256 communityId) internal view {
        if (msg.sender != IERC721(_communityNFT()).ownerOf(communityId))
            revert OspErrors.NotCommunityOwner();
    }

    function _communityNFT() internal view returns (address) {
        return _getGovernanceStorage()._communityNFT;
    }
}
