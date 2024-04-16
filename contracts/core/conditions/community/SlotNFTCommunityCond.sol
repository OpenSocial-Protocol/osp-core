// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {OspErrors} from '../../../libraries/OspErrors.sol';
import {IERC721} from '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import {CommunityCondBase} from '../../base/CommunityCondBase.sol';

/**
 * @title SlotNFTCommunityCond
 * @author OpenSocial Protocol
 *
 * @dev This contract specifies that holding slotNFT can create communities.
 * Each slotNFT can only be used once.
 */
contract SlotNFTCommunityCond is CommunityCondBase {
    event SlotNFTWhitelisted(address indexed slot, bool whitelist, uint256 timestamp);

    constructor(address osp) CommunityCondBase(osp) {}

    mapping(address => mapping(uint256 => bool)) _slotNFTUsed;
    mapping(address => bool) _slotNFTWhitelisted;

    /**
     * @dev process create community,if the slotNFT is used, revert.
     */
    function _processCreateCommunity(address to, bytes calldata data) internal override nonPayable {
        (address slotNTF, uint256 tokenId) = abi.decode(data, (address, uint256));
        _validateSlotNFT(to, slotNTF, tokenId);
        _slotNFTUsed[slotNTF][tokenId] = true;
    }

    /**
     *  @dev Whitelist a slotNFT,only openSocial governance can call this function.
     */
    function whitelistCommunitySlot(address slot, bool whitelist) external onlyOperation {
        _slotNFTWhitelisted[slot] = whitelist;
        emit SlotNFTWhitelisted(slot, whitelist, block.timestamp);
    }

    /**
     * @dev Check if a slotNFT is whitelisted.
     */
    function isCommunitySlotWhitelisted(address slot) external view returns (bool) {
        return _slotNFTWhitelisted[slot];
    }

    /**
     * @dev Check if a slotNFT is usable.
     * @param slot NFT contract address.
     * @param addr Creator address.
     * @param tokenId NFT token id.
     */
    function isSlotNFTUsable(
        address slot,
        address addr,
        uint256 tokenId
    ) external view returns (bool) {
        return
            _slotNFTWhitelisted[slot] &&
            !_slotNFTUsed[slot][tokenId] &&
            IERC721(slot).ownerOf(tokenId) == addr;
    }

    function _validateSlotNFT(address addr, address slotNFTAddress, uint256 tokenId) internal view {
        if (!_slotNFTWhitelisted[slotNFTAddress]) {
            revert OspErrors.SlotNFTNotWhitelisted();
        }
        if (IERC721(slotNFTAddress).ownerOf(tokenId) != addr) {
            revert OspErrors.NotSlotNFTOwner();
        }
        if (_slotNFTUsed[slotNFTAddress][tokenId]) {
            revert OspErrors.SlotNFTAlreadyUsed();
        }
    }
}
