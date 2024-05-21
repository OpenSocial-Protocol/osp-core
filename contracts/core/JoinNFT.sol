// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {IJoinNFT} from '../interfaces/IJoinNFT.sol';
import {OspErrors} from '../libraries/OspErrors.sol';
import {OspEvents} from '../libraries/OspEvents.sol';
import {Constants} from '../libraries/Constants.sol';
import {OspDataTypes} from '../libraries/OspDataTypes.sol';
import {OspNFTBase, ERC721Upgradeable} from './base/OspNFTBase.sol';
import {OspClient} from './logics/interfaces/OspClient.sol';

import {IERC721} from '@openzeppelin/contracts/token/ERC721/IERC721.sol';

/**
 * @title JoinNFT
 * @author OpenSocial Protocol
 * @dev This is the NFT contract that is minted upon joining a community. It is cloned upon first community is created.
 */
contract JoinNFT is OspNFTBase, IJoinNFT {
    address public immutable OSP;

    uint256 internal _communityId;
    uint256 internal _tokenIdCounter;
    mapping(address => bool) internal _blockList;
    mapping(address => uint256) internal _role;
    mapping(address => uint256) internal _level;

    // We create the CollectNFT with the pre-computed OSP address before deploying the osp proxy in order
    // to initialize the osp proxy at construction.
    constructor(address osp) {
        if (osp == address(0)) revert OspErrors.InitParamsInvalid();
        OSP = osp;
    }

    /// @inheritdoc IJoinNFT
    function initialize(
        uint256 communityId,
        string calldata name,
        string calldata symbol
    ) external override {
        if (msg.sender != OSP) revert OspErrors.NotOSP();
        _communityId = communityId;
        super._initialize(name, symbol);
        emit OspEvents.JoinNFTInitialized(communityId, block.timestamp);
    }

    /// @inheritdoc IJoinNFT
    function mint(address to) external override returns (uint256) {
        if (msg.sender != OSP) revert OspErrors.NotOSP();
        unchecked {
            uint256 tokenId = ++_tokenIdCounter;
            _mint(to, tokenId);
            return tokenId;
        }
    }

    /// @inheritdoc IJoinNFT
    function setAdmin(address account, bool enable) public override returns (bool) {
        if (_isCommunityOwner(_msgSender())) {
            return
                enable
                    ? _grantRole(Constants.COMMUNITY_ADMIN_ACCESS, account)
                    : _revokeRole(Constants.COMMUNITY_ADMIN_ACCESS, account);
        }
        revert OspErrors.NotCommunityOwner();
    }

    /// @inheritdoc IJoinNFT
    function setMods(address account, bool enable) public override returns (bool) {
        if (
            hasOneRole(Constants.COMMUNITY_ADMIN_ACCESS, _msgSender()) ||
            _isCommunityOwner(_msgSender())
        ) {
            return
                enable
                    ? _grantRole(Constants.COMMUNITY_MODS_ACCESS, account)
                    : _revokeRole(Constants.COMMUNITY_MODS_ACCESS, account);
        }
        revert OspErrors.JoinNFTUnauthorizedAccount();
    }

    /// @inheritdoc IJoinNFT
    function setMemberLevel(address account, uint256 level) public override returns (bool) {
        if (
            hasOneRole(
                Constants.COMMUNITY_ADMIN_ACCESS | Constants.COMMUNITY_MODS_ACCESS,
                _msgSender()
            ) || _isCommunityOwner(_msgSender())
        ) {
            if(_level[account] != level){
                _level[account] = level;
                OspClient(OSP).emitJoinNFTAccountLevelChangedEvent(_communityId, account, level);
            }
        }
        revert OspErrors.JoinNFTUnauthorizedAccount();
    }

    /// @inheritdoc IJoinNFT
    function setBlockList(address account, bool enable) public override returns (bool) {
        if (
            hasOneRole(
                Constants.COMMUNITY_ADMIN_ACCESS | Constants.COMMUNITY_MODS_ACCESS,
                _msgSender()
            ) || _isCommunityOwner(_msgSender())
        ) {
            if (_blockList[account] != enable) {
                _blockList[account] = enable;
                OspClient(OSP).emitJoinNFTAccountBlockedEvent(_communityId, account, enable);
                return true;
            }
            return false;
        }
        revert OspErrors.JoinNFTUnauthorizedAccount();
    }

    /// @inheritdoc IJoinNFT
    function getSourceCommunityPointer() external view override returns (uint256) {
        return _communityId;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return OspClient(OSP).getJoinNFTURI(_communityId, tokenId);
    }

    function balanceOf(
        address addr
    ) public view override(IERC721, ERC721Upgradeable) returns (uint256) {
        return _blockList[addr] ? 0 : super.balanceOf(addr);
    }

    function ownerOf(
        uint256 tokenId
    ) public view override(IERC721, ERC721Upgradeable) returns (address) {
        address owner = super.ownerOf(tokenId);
        if (_blockList[owner]) {
            revert OspErrors.JoinNFTBlocked();
        }
        return owner;
    }

    /// @inheritdoc IJoinNFT
    function hasOneRole(uint256 roles, address account) public view override returns (bool) {
        return _role[account] & roles != 0;
    }

    /// @inheritdoc IJoinNFT
    function hasAllRole(uint256 roles, address account) public view override returns (bool) {
        return _role[account] & roles == roles;
    }

    /// @inheritdoc IJoinNFT
    function memberLevel(address account) external view override returns (uint256) {
        return _level[account];
    }

    /// @inheritdoc IJoinNFT
    function isBlockList(address account) external view override returns (bool) {
        return _blockList[account];
    }

    /**
     * @dev Upon transfers, we emit the transfer event in the osp.
     */
    function _afterTokenTransfer(address from, address to, uint256 tokenId) internal override {
        if (_blockList[from] || _blockList[to]) {
            revert OspErrors.JoinNFTBlocked();
        }
        super._afterTokenTransfer(from, to, tokenId);
        if (balanceOf(to) > 1) revert OspErrors.JoinNFTDuplicated();
        OspClient(OSP).emitJoinNFTTransferEvent(_communityId, tokenId, from, to);
    }

    function _isCommunityOwner(address account) internal returns (bool) {
        return IERC721(OspClient(OSP).getCommunityNFT()).ownerOf(_communityId) == account;
    }

    /**
     * @dev Grant a role to an account.
     */
    function _grantRole(uint256 role, address account) internal returns (bool) {
        uint256 oldRole = _role[account];
        if (role != 0 && oldRole & role == 0) {
            _role[account] = oldRole | role;
            OspClient(OSP).emitJoinNFTRoleChangedEvent(
                _communityId,
                account,
                ~oldRole & role,
                true
            );
            return true;
        }
        return false;
    }

    /**
     * @dev Revoke a role from an account.
     */
    function _revokeRole(uint256 role, address account) internal returns (bool) {
        uint256 oldRole = _role[account];
        if (role == 0 || oldRole & role == 0) {
            return false;
        }
        _role[account] = oldRole & ~role;
        OspClient(OSP).emitJoinNFTRoleChangedEvent(_communityId, account, oldRole & role, false);
        return true;
    }
}
