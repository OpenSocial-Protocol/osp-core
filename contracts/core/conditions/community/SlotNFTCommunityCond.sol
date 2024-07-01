// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {CondErrors} from '../libraries/CondErrors.sol';
import {IERC721} from '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import {CommunityCondBase} from '../../base/CommunityCondBase.sol';
import {CondDataTypes} from '../libraries/CondDataTypes.sol';

/**
 * @title SlotNFTCommunityCond
 * @author OpenSocial Protocol
 *
 * @dev This contract specifies that holding slotNFT can create communities.
 * Each slotNFT can only be used once.
 */
contract SlotNFTCommunityCond is CommunityCondBase {
    event SlotNFTCondDataSet(address indexed slot, uint256 minHandleLength, uint256 timestamp);
    event SlotNFTUsed(
        address indexed to,
        address indexed slot,
        uint256 indexed tokenId,
        string handle,
        uint256 timestamp
    );

    constructor(address osp) CommunityCondBase(osp) {}

    mapping(address => mapping(uint256 => bool)) _slotNFTUsed;

    mapping(address => CondDataTypes.SlotNFTCondData) _slotNFTCondData;

    /**
     * @dev process create community,if the slotNFT is used, revert.
     */
    function _processCreateCommunity(
        address to,
        string calldata handle,
        bytes calldata data
    ) internal override nonPayable {
        (address slot, uint256 tokenId) = abi.decode(data, (address, uint256));
        _validateSlotNFT(to, slot, tokenId);
        uint256 len = bytes(handle).length;
        if (len < _slotNFTCondData[slot].minHandleLength) {
            revert CondErrors.HandleLengthNotEnough();
        }
        _slotNFTUsed[slot][tokenId] = true;
        emit SlotNFTUsed(to, slot, tokenId, handle, block.timestamp);
    }

    /**
     * @dev Set slotNFT condition data.
     * @param slot NFT contract address.
     * @param whitelist Whether the slotNFT is whitelisted.
     * @param minHandleLength Minimum handle length to create a community.
     */
    function setSlotNFTCondData(
        address slot,
        bool whitelist,
        uint256 minHandleLength
    ) external onlyOperation {
        if (slot == address(0) || minHandleLength <= 0) {
            revert CondErrors.InitParamsInvalid();
        }
        _slotNFTCondData[slot] = CondDataTypes.SlotNFTCondData({
            whitelist: whitelist,
            minHandleLength: minHandleLength
        });
        emit SlotNFTCondDataSet(slot, minHandleLength, block.timestamp);
    }

    function getSlotNFTCondData(
        address slot
    ) external view returns (CondDataTypes.SlotNFTCondData memory) {
        return _slotNFTCondData[slot];
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
            _slotNFTCondData[slot].whitelist &&
            !_slotNFTUsed[slot][tokenId] &&
            IERC721(slot).ownerOf(tokenId) == addr;
    }

    function _validateSlotNFT(address addr, address slot, uint256 tokenId) internal view {
        if (!_slotNFTCondData[slot].whitelist) {
            revert CondErrors.SlotNFTNotWhitelisted();
        }
        if (IERC721(slot).ownerOf(tokenId) != addr) {
            revert CondErrors.NotSlotNFTOwner();
        }
        if (_slotNFTUsed[slot][tokenId]) {
            revert CondErrors.SlotNFTAlreadyUsed();
        }
    }
}
