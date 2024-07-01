// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {IJoinNFT} from '../interfaces/IJoinNFT.sol';
import {OspErrors} from '../libraries/OspErrors.sol';
import {OspEvents} from '../libraries/OspEvents.sol';
import {Constants} from '../libraries/Constants.sol';
import {OspDataTypes} from '../libraries/OspDataTypes.sol';
import {Payment} from '../libraries/Payment.sol';
import {OspNFTBase, ERC721Upgradeable} from './base/OspNFTBase.sol';
import {OspClient} from './logics/interfaces/OspClient.sol';

import {IERC721} from '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import {IERC2981} from '@openzeppelin/contracts/interfaces/IERC2981.sol';
import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';

/**
 * @title JoinNFT
 * @author OpenSocial Protocol
 * @dev This is the NFT contract that is minted upon joining a community. It is cloned upon first community is created.
 */
contract JoinNFT is OspNFTBase, IJoinNFT, IERC2981 {
    using Payment for address;

    address public immutable OSP;

    uint256 internal _communityId;
    uint256 internal _tokenIdCounter;
    mapping(address => bool) internal _blockList;
    mapping(address => uint256) internal _role;
    mapping(uint256 => uint256) internal _level;

    modifier notBlock(address account) {
        if (_blockList[account]) revert OspErrors.JoinNFTBlocked();
        _;
    }

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
    function setAdmin(address account) public override notBlock(account) returns (bool) {
        return _setRole(Constants.COMMUNITY_ADMIN_ACCESS, account);
    }

    /// @inheritdoc IJoinNFT
    function setModerator(address account) public override notBlock(account) returns (bool) {
        return _setRole(Constants.COMMUNITY_MODERATOR_ACCESS, account);
    }

    /// @inheritdoc IJoinNFT
    function removeRole(address account) public override returns (bool) {
        return _setRole(Constants.COMMUNITY_NULL_ACCESS, account);
    }

    /// @inheritdoc IJoinNFT
    function setMemberLevel(uint256 tokenId, uint256 level) public override returns (bool) {
        _requireOwned(tokenId);
        if (hasRole(Constants.COMMUNITY_MODERATOR_ACCESS, _msgSender())) {
            if (_level[tokenId] != level) {
                _level[tokenId] = level;
                OspClient(OSP).emitJoinNFTAccountLevelChangedEvent(
                    _communityId,
                    _msgSender(),
                    tokenId,
                    ownerOf(tokenId),
                    level
                );
                return true;
            }
            return false;
        }
        revert OspErrors.JoinNFTUnauthorizedAccount();
    }

    /// @inheritdoc IJoinNFT
    function setBlockList(address account, bool enable) public override returns (bool) {
        if (hasRole(Constants.COMMUNITY_MODERATOR_ACCESS, _msgSender())) {
            if (_blockList[account] != enable) {
                _blockList[account] = enable;
                OspClient(OSP).emitJoinNFTAccountBlockedEvent(
                    _communityId,
                    _msgSender(),
                    account,
                    enable
                );
                return true;
            }
            return false;
        }
        revert OspErrors.JoinNFTUnauthorizedAccount();
    }

    function withdraw(address token) external {
        OspClient ospClient = OspClient(OSP);
        (uint128 __, uint128 ospTreasureFraction) = ospClient.joinNFTRoyaltyInfo();
        address treasureAddress = ospClient.getTreasureAddress();
        address communityAccount = ospClient.getCommunityAccount(_communityId);

        uint256 value;
        if (address(0) == token) {
            value = address(this).balance;
            uint256 serviceFee = (value * ospTreasureFraction) / Constants.ROYALTY_DENOMINATOR;
            Payment.payNative(treasureAddress, serviceFee);
            Payment.payNative(communityAccount, value - serviceFee);
        } else {
            value = IERC20(token).balanceOf(address(this));
            uint256 serviceFee = (value * ospTreasureFraction) / Constants.ROYALTY_DENOMINATOR;
            token.payERC20(treasureAddress, serviceFee);
            token.payERC20(communityAccount, value - serviceFee);
        }
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
    ) public view override(IERC721, ERC721Upgradeable) notBlock(addr) returns (uint256) {
        return super.balanceOf(addr);
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
    function hasRole(uint256 roles, address account) public view override returns (bool) {
        return _role[account] >= roles || _isCommunityOwner(account);
    }

    /// @inheritdoc IJoinNFT
    function getRole(address account) public view override returns (uint256) {
        return _role[account];
    }

    /// @inheritdoc IJoinNFT
    function getMemberLevel(address account) external view override returns (uint256) {
        return _level[tokenOfOwnerByIndex(account, 0)];
    }

    /// @inheritdoc IJoinNFT
    function getMemberLevel(uint256 tokenId) external view override returns (uint256) {
        return _level[tokenId];
    }

    /// @inheritdoc IJoinNFT
    function isBlock(address account) external view override returns (bool) {
        return _blockList[account];
    }

    /// @inheritdoc IERC2981
    function royaltyInfo(
        uint256 tokenId,
        uint256 salePrice
    ) external view returns (address receiver, uint256 royaltyAmount) {
        (uint128 royaltyFraction, uint128 __) = OspClient(OSP).joinNFTRoyaltyInfo();
        return (address(this), (salePrice * royaltyFraction) / Constants.ROYALTY_DENOMINATOR);
    }

    /**
     * @dev Upon transfers, we emit the transfer event in the osp.
     */
    function _afterTokenTransfer(address from, address to, uint256 tokenId) internal override {
        if (_blockList[from] || _blockList[to]) {
            revert OspErrors.JoinNFTBlocked();
        }
        super._afterTokenTransfer(from, to, tokenId);
        if (to != address(0) && balanceOf(to) > 1) revert OspErrors.JoinNFTDuplicated();
        if (from != address(0)) {
            _setRole(Constants.COMMUNITY_NULL_ACCESS, from);
        }
        if (to == address(0)) {
            _level[tokenId] = 0;
        }
        OspClient(OSP).emitJoinNFTTransferEvent(_communityId, tokenId, from, to);
    }

    function _isCommunityOwner(address account) internal view returns (bool) {
        return IERC721(OspClient(OSP).getCommunityNFT()).ownerOf(_communityId) == account;
    }

    /**
     * @dev Grant a role to an account.
     */
    function _setRole(uint256 role, address account) internal returns (bool) {
        address sender = _msgSender();
        uint256 oldRole = _role[account];

        if (balanceOf(account) == 0) {
            if (role != Constants.COMMUNITY_NULL_ACCESS) revert OspErrors.NotJoinCommunity();
        } else {
            uint256 senderRole = _role[sender];
            if (!_isCommunityOwner(sender) && (senderRole <= oldRole || role >= senderRole)) {
                revert OspErrors.JoinNFTUnauthorizedAccount();
            }
        }

        if (oldRole != role) {
            _role[account] = role;
            OspClient(OSP).emitJoinNFTRoleChangedEvent(_communityId, sender, account, role);
            return true;
        }
        return false;
    }
}
