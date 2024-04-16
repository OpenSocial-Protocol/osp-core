// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import '../interfaces/IJoinNFT.sol';
import '../libraries/OspErrors.sol';
import '../libraries/OspEvents.sol';
import '../libraries/OspDataTypes.sol';
import './base/OspNFTBase.sol';
import './logics/interfaces/IRelationLogic.sol';

/**
 * @title JoinNFT
 * @author OpenSocial Protocol
 * @dev This is the NFT contract that is minted upon joining a community. It is cloned upon first community is created.
 */
contract JoinNFT is OspNFTBase, IJoinNFT {
    address public immutable OSP;

    uint256 internal _communityId;
    uint256 internal _tokenIdCounter;

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
    function getSourceCommunityPointer() external view override returns (uint256) {
        return _communityId;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return IRelationLogic(OSP).getJoinNFTURI(_communityId, tokenId);
    }

    /**
     * @dev Upon transfers, we emit the transfer event in the osp.
     */
    function _afterTokenTransfer(address from, address to, uint256 tokenId) internal override {
        super._afterTokenTransfer(from, to, tokenId);
        if (balanceOf(to) > 1) revert OspErrors.JoinNFTDuplicated();
        IRelationLogic(OSP).emitJoinNFTTransferEvent(_communityId, tokenId, from, to);
    }
}
