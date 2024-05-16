// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import './OspLogicBase.sol';
import './interfaces/IGovernanceLogic.sol';
import '../../libraries/OspDataTypes.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
import '@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol';
import '../../interfaces/IERC6551Registry.sol';
import '../../libraries/Constants.sol';
import '../../upgradeability/CommunityAccountProxy.sol';

/**
 * @title GovernanceLogic
 * @author OpenSocial Protocol
 * @dev GovernanceLogic is the contract that manages the governance of the protocol.
 */
contract GovernanceLogic is IGovernanceLogic, OspLogicBase, AccessControlUpgradeable {
    /*///////////////////////////////////////////////////////////////
                        Public functions
    //////////////////////////////////////////////////////////////*/
    /// @inheritdoc IGovernanceLogic
    function initialize(
        string calldata name,
        string calldata symbol,
        address followSBTImpl,
        address joinNFTImpl,
        address communityNFT
    ) external override initializer {
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
        GovernanceStorage storage governanceStorage = _getGovernanceStorage();
        governanceStorage._name = name;
        governanceStorage._symbol = symbol;
        governanceStorage._followSBTImpl = followSBTImpl;
        governanceStorage._joinNFTImpl = joinNFTImpl;
        governanceStorage._communityNFT = communityNFT;
        address communityAccountProxy = address(new CommunityAccountProxy());
        governanceStorage._communityAccountProxy = communityAccountProxy;
        _setState(OspDataTypes.ProtocolState.Paused);
        emit OspEvents.OSPInitialized(
            name,
            symbol,
            followSBTImpl,
            joinNFTImpl,
            communityNFT,
            communityAccountProxy,
            block.timestamp
        );
    }

    /// @inheritdoc IGovernanceLogic
    function setState(
        OspDataTypes.ProtocolState newState
    ) external onlyRole(Constants.STATE_ADMIN) {
        _setState(newState);
    }

    /// @inheritdoc IGovernanceLogic
    function whitelistApp(address app, bool whitelist) external onlyRole(Constants.APP_ADMIN) {
        _getGovernanceStorage()._appWhitelisted[app] = whitelist;
        emit OspEvents.AppWhitelisted(app, whitelist, block.timestamp);
    }

    // @inheritdoc IGovernanceLogic
    function whitelistToken(
        address token,
        bool whitelist
    ) external override onlyRole(Constants.OPERATION) {
        _getGovernanceStorage()._tokenWhitelisted[token] = whitelist;
        emit OspEvents.TokenWhitelisted(token, whitelist, block.timestamp);
    }

    /// @inheritdoc IGovernanceLogic
    function reserveCommunityHandle(
        string calldata handle,
        bool isReserve
    ) external override onlyRole(Constants.SUPER_COMMUNITY_CREATOR) {
        _getGovernanceStorage()._reserveCommunityHandleHash[keccak256(bytes(handle))] = isReserve;
        emit OspEvents.CommunityHandleReserve(
            keccak256(bytes(handle)),
            isReserve,
            handle,
            block.timestamp
        );
    }

    /// @inheritdoc IGovernanceLogic
    function setBaseURI(string calldata baseURI) external override onlyRole(Constants.GOVERNANCE) {
        _getGovernanceStorage()._baseURI = baseURI;
        emit OspEvents.BaseURISet(baseURI, block.timestamp);
    }

    /// @inheritdoc IGovernanceLogic
    function setERC6551AccountImpl(
        address accountImpl
    ) external override onlyRole(Constants.GOVERNANCE) {
        _getGovernanceStorage()._erc6551AccountImpl = accountImpl;
        emit OspEvents.ERC6551AccountImplSet(accountImpl, block.timestamp);
    }

    /// @inheritdoc IGovernanceLogic
    function updateMetadata() external override onlyRole(Constants.GOVERNANCE) {
        emit BatchMetadataUpdate(1, type(uint256).max);
    }

    function setTreasureAddress(address treasure) external override onlyRole(Constants.GOVERNANCE) {
        if (treasure == address(0)) revert OspErrors.InvalidTreasure();
        _getGovernanceStorage()._treasure = treasure;
    }

    /*///////////////////////////////////////////////////////////////
                        Public read functions
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IGovernanceLogic
    function isAppWhitelisted(address app) external view override returns (bool) {
        return _getGovernanceStorage()._appWhitelisted[app];
    }

    // @inheritdoc IGovernanceLogic
    function isTokenWhitelisted(address token) external view override returns (bool) {
        return _getGovernanceStorage()._tokenWhitelisted[token];
    }

    /// @inheritdoc IGovernanceLogic
    function isReserveCommunityHandle(
        string calldata handle
    ) external view override returns (bool) {
        return _getGovernanceStorage()._reserveCommunityHandleHash[keccak256(bytes(handle))];
    }

    /// @inheritdoc IGovernanceLogic
    function getFollowSBTImpl() external view override returns (address) {
        return _getGovernanceStorage()._followSBTImpl;
    }

    /// @inheritdoc IGovernanceLogic
    function getJoinNFTImpl() external view override returns (address) {
        return _getGovernanceStorage()._joinNFTImpl;
    }

    /// @inheritdoc IGovernanceLogic
    function getCommunityNFT() external view override returns (address) {
        return _getGovernanceStorage()._communityNFT;
    }

    /// @inheritdoc IGovernanceLogic
    function getERC6551AccountImpl() external view override returns (address) {
        return _getGovernanceStorage()._erc6551AccountImpl;
    }

    /// @inheritdoc IGovernanceLogic
    function getState() external view override returns (OspDataTypes.ProtocolState) {
        return _getState();
    }

    /// @inheritdoc IGovernanceLogic
    function getBaseURI() external view override returns (string memory) {
        return _getGovernanceStorage()._baseURI;
    }

    /// @inheritdoc IERC5267
    function eip712Domain()
        external
        view
        override
        returns (
            bytes1 fields,
            string memory name,
            string memory version,
            uint256 chainId,
            address verifyingContract,
            bytes32 salt,
            uint256[] memory extensions
        )
    {
        return (
            hex'0f', // 01111
            _getGovernanceStorage()._name,
            '1',
            block.chainid,
            address(this),
            bytes32(0),
            new uint256[](0)
        );
    }

    function getTreasureAddress() external view returns (address) {
        return _getGovernanceStorage()._treasure;
    }
}
