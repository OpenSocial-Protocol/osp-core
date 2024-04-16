// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import '../interfaces/IFollowSBT.sol';
import '../interfaces/IFollowCondition.sol';
import './logics/interfaces/OspClient.sol';
import '../libraries/OspErrors.sol';
import '../libraries/OspEvents.sol';
import './base/OspSBTBase.sol';

/**
 * @title FollowSBT
 * @author OpenSocial Protocol
 * @dev This contract is the NFT that is minted upon following a given profile. It is cloned upon first follow for a
 * given profile.
 */
contract FollowSBT is OspSBTBase, IFollowSBT {
    address public immutable OSP;

    uint256 internal _profileId;
    uint256 internal _tokenIdCounter;

    // We create the FollowSBT with the pre-computed OSP address before deploying the osp.
    constructor(address osp) {
        if (osp == address(0)) revert OspErrors.InitParamsInvalid();
        OSP = osp;
    }

    /// @inheritdoc IFollowSBT
    function initialize(
        uint256 profileId,
        string calldata name,
        string calldata symbol
    ) external override {
        if (msg.sender != OSP) revert OspErrors.NotOSP();
        _profileId = profileId;
        super._initialize(name, symbol);
        emit OspEvents.FollowSBTInitialized(profileId, block.timestamp);
    }

    /// @inheritdoc IFollowSBT
    function mint(address to) external override returns (uint256) {
        if (msg.sender != OSP) revert OspErrors.NotOSP();
        unchecked {
            uint256 tokenId = ++_tokenIdCounter;
            _mint(to, tokenId);
            return tokenId;
        }
    }

    /**
     * @dev This returns the follow NFT URI fetched from the osp.
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return OspClient(OSP).getFollowSBTURI(_profileId, tokenId);
    }

    /**
     * @dev Upon transfers, we move the appropriate delegations, and emit the transfer event in the osp.
     */
    function _afterTokenTransfer(address from, address to, uint256 tokenId) internal override {
        super._afterTokenTransfer(from, to, tokenId);
        OspClient(OSP).emitFollowSBTTransferEvent(_profileId, tokenId, from, to);
    }
}
