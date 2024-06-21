// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import './interfaces/IProfileLogic.sol';
import './OspLogicBase.sol';
import '../../libraries/Constants.sol';
import '../../interfaces/IFollowCondition.sol';
import '@openzeppelin/contracts/utils/Strings.sol';

/**
 * @title ProfileLogic
 * @author OpenSocial Protocol
 * @dev This contract is the logic contract for interacting with profiles.
 */
contract ProfileLogic is IProfileLogic, OspLogicBase {
    using Strings for uint256;

    /*///////////////////////////////////////////////////////////////
                        Public functions
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IProfileLogic
    function createProfile(
        OspDataTypes.CreateProfileData calldata vars
    ) external override whenNotPaused returns (uint256) {
        return _createProfile(vars);
    }

    /// @inheritdoc IProfileLogic
    function setFollowCondition(
        uint256 profileId,
        bytes calldata followConditionInitCode
    ) external override whenNotPaused {
        _validateIsProfileOwner(msg.sender, profileId);
        _setFollowCondition(profileId, followConditionInitCode);
    }

    /**
     * @dev opensocial not support.
     */
    function burn(uint256 /*profileId*/) external view override whenNotPaused {
        revert OspErrors.SBTTransferNotAllowed();
    }

    /**
     * @dev opensocial not support.
     */
    function safeTransferFrom(
        address /*from*/,
        address /*to*/,
        uint256 /*tokenId*/,
        bytes calldata /*data*/
    ) external pure override {
        revert OspErrors.SBTTransferNotAllowed();
    }

    /**
     * @dev opensocial not support.
     */
    function safeTransferFrom(
        address /*from*/,
        address /*to*/,
        uint256 /*tokenId*/
    ) external pure override {
        revert OspErrors.SBTTransferNotAllowed();
    }

    /**
     * @dev opensocial not support.
     */
    function transferFrom(
        address /*from*/,
        address /*to*/,
        uint256 /*tokenId*/
    ) external pure override {
        revert OspErrors.SBTTransferNotAllowed();
    }

    /**
     * @dev opensocial not support.
     */
    function approve(address /*to*/, uint256 /*tokenId*/) external pure override {
        revert OspErrors.SBTTransferNotAllowed();
    }

    /**
     * @dev opensocial not support.
     */
    function setApprovalForAll(address /*operator*/, bool /*_approved*/) external pure override {
        revert OspErrors.SBTTransferNotAllowed();
    }

    /*///////////////////////////////////////////////////////////////
                        Public Read functions
    //////////////////////////////////////////////////////////////*/
    /// @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId) external pure override returns (bool) {
        return
            interfaceId == type(IERC721Enumerable).interfaceId ||
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            interfaceId == type(IERC165).interfaceId;
    }

    /// @inheritdoc IERC721
    function ownerOf(uint256 tokenId) public view override returns (address) {
        require(
            _getProfileStorage()._profileById[tokenId].owner != address(0),
            'ERC721: owner query for nonexistent token'
        );
        return _getProfileStorage()._profileById[tokenId].owner;
    }

    /// @inheritdoc IERC721Metadata
    function name() external view override returns (string memory) {
        return _getGovernanceStorage()._name;
    }

    /// @inheritdoc IERC721Metadata
    function symbol() external view override returns (string memory) {
        return _getGovernanceStorage()._symbol;
    }

    // @inheritdoc IERC721Metadata
    function tokenURI(uint256 tokenId) external view override returns (string memory) {
        string memory baseURI = _getGovernanceStorage()._baseURI;
        return
            bytes(baseURI).length > 0
                ? string(abi.encodePacked(baseURI, 'profile/', tokenId.toString()))
                : tokenId.toString();
    }

    /// @inheritdoc IERC721
    function balanceOf(address owner) public view override returns (uint256) {
        return _getProfileStorage()._profileIdByAddress[owner] != 0 ? 1 : 0;
    }

    /// @inheritdoc IERC721Enumerable
    function totalSupply() external view override returns (uint256) {
        return _getProfileStorage()._allTokens.length;
    }

    /// @inheritdoc IProfileLogic
    function nonces(address singer) external view override returns (uint256) {
        return _getProfileStorage()._sigNonces[singer];
    }

    /// @inheritdoc IProfileLogic
    function getFollowSBT(uint256 profileId) external view override returns (address) {
        return _getProfileStorage()._profileById[profileId].followSBT;
    }

    /// @inheritdoc IProfileLogic
    function getFollowCondition(uint256 profileId) external view override returns (address) {
        return _getProfileStorage()._profileById[profileId].followCondition;
    }

    /// @inheritdoc IProfileLogic
    function getHandle(uint256 profileId) external view override returns (string memory) {
        return _getProfileStorage()._profileById[profileId].handle;
    }

    /// @inheritdoc IProfileLogic
    function getProfileIdByHandle(string calldata handle) external view override returns (uint256) {
        return _getProfileStorage()._profileIdByHandleHash[keccak256(bytes(handle))];
    }

    /// @inheritdoc IProfileLogic
    function getProfileIdByAddress(address addr) external view override returns (uint256) {
        return _getProfileStorage()._profileIdByAddress[addr];
    }

    /// @inheritdoc IProfileLogic
    function getProfile(
        uint256 profileId
    ) external view override returns (OspDataTypes.ProfileStruct memory) {
        return _getProfileStorage()._profileById[profileId];
    }

    /// @inheritdoc IERC721Enumerable
    function tokenOfOwnerByIndex(
        address owner,
        uint256 index
    ) external view override returns (uint256) {
        require(index == 0 || balanceOf(owner) == 0, 'ERC721Enumerable: owner index out of bounds');
        return _getProfileStorage()._profileIdByAddress[owner];
    }

    /// @inheritdoc IERC721Enumerable
    function tokenByIndex(uint256 index) external view override returns (uint256) {
        return _getProfileStorage()._allTokens[index];
    }

    /**
     * @dev opensocial not support.
     */
    function getApproved(
        uint256 /*tokenId*/
    ) external pure override returns (address /*operator*/) {
        revert OspErrors.SBTTransferNotAllowed();
    }

    /**
     * @dev opensocial not support.
     */
    function isApprovedForAll(
        address /*owner*/,
        address /*operator*/
    ) external pure override returns (bool) {
        revert OspErrors.SBTTransferNotAllowed();
    }

    /*///////////////////////////////////////////////////////////////
                        Internal functions
    //////////////////////////////////////////////////////////////*/

    function _mint(address to) internal returns (uint256) {
        ProfileStorage storage profileStorage = _getProfileStorage();
        if (profileStorage._profileIdByAddress[to] != 0) revert OspErrors.SBTTokenAlreadyExists();
        uint256 tokenId = ++profileStorage._profileCounter;
        _addTokenToAllTokensEnumeration(tokenId);
        profileStorage._profileById[tokenId].owner = to;
        profileStorage._profileById[tokenId].mintTimestamp = uint96(block.timestamp);
        profileStorage._profileIdByAddress[to] = tokenId;
        emit Transfer(address(0), to, tokenId);
        return tokenId;
    }

    function _validateHandle(string calldata handle) internal pure returns (bytes32 hash) {
        bytes memory byteHandle = bytes(handle);
        if (
            byteHandle.length < Constants.MIN_HANDLE_LENGTH ||
            byteHandle.length > Constants.MAX_HANDLE_LENGTH
        ) revert OspErrors.HandleLengthInvalid();

        uint256 byteHandleLength = byteHandle.length;
        for (uint256 i; i < byteHandleLength; ) {
            if (
                (byteHandle[i] < '0' ||
                    byteHandle[i] > 'z' ||
                    (byteHandle[i] > '9' && byteHandle[i] < 'a')) && byteHandle[i] != '_'
            ) revert OspErrors.HandleContainsInvalidCharacters();
            unchecked {
                ++i;
            }
        }
        return keccak256(byteHandle);
    }

    function _createProfile(
        OspDataTypes.CreateProfileData calldata vars
    ) internal returns (uint256) {
        bytes32 handleHash = _validateHandle(vars.handle);
        mapping(bytes32 => uint256) storage _profileIdByHandleHash = _getProfileStorage()
            ._profileIdByHandleHash;
        if (_profileIdByHandleHash[handleHash] != 0) revert OspErrors.HandleTaken();
        uint256 profileId = _mint(msg.sender);
        OspDataTypes.ProfileStruct storage profileStruct = _getProfileStorage()._profileById[
            profileId
        ];
        profileStruct.handle = vars.handle;
        _profileIdByHandleHash[handleHash] = profileId;
        address followCondition;
        if (vars.followConditionInitCode.length != 0) {
            followCondition = _initFollowCondition(profileId, vars.followConditionInitCode);
            profileStruct.followCondition = followCondition;
        }
        if (vars.inviter != 0) {
            address inviterAddress = _getProfileStorage()._profileById[vars.inviter].owner;
            if (inviterAddress == address(0) || inviterAddress == msg.sender) {
                revert OspErrors.ProfileDoesNotExist();
            }
            profileStruct.inviter = vars.inviter;
        }
        emit OspEvents.ProfileCreated(
            profileId,
            msg.sender,
            vars.handle,
            followCondition,
            vars.inviter,
            vars.ctx,
            block.timestamp
        );
        return profileId;
    }

    function _setFollowCondition(
        uint256 profileId,
        bytes calldata followConditionInitCode
    ) internal {
        address followCondition = _initFollowCondition(profileId, followConditionInitCode);
        _getProfileStorage()._profileById[profileId].followCondition = followCondition;
        emit OspEvents.FollowConditionSet(profileId, followCondition, block.timestamp);
    }

    /**
     * @dev Private function to add a token to this extension's token tracking data structures.
     * @param tokenId uint256 ID of the token to be added to the tokens list
     */
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        ProfileStorage storage profileStorage = _getProfileStorage();
        profileStorage._allTokensIndex[tokenId] = profileStorage._allTokens.length;
        profileStorage._allTokens.push(tokenId);
    }

    function _initFollowCondition(
        uint256 profileId,
        bytes calldata initCode
    ) private returns (address followCondition) {
        followCondition = address(bytes20(initCode[:20]));
        _checkFollowCondition(followCondition);
        bytes memory initCallData = initCode[20:];
        IFollowCondition(followCondition).initializeFollowCondition(profileId, initCallData);
    }
}
