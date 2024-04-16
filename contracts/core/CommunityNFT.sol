// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import './logics/interfaces/ICommunityLogic.sol';
import '../interfaces/ICommunityNFT.sol';
import '../libraries/OspErrors.sol';
import './base/OspNFTBase.sol';
import './base/IERC4906.sol';

/**
 * @title CommunityNFT
 * @author OpenSocial Protocol
 * @dev This NFT contract is minted upon community is created.
 */
contract CommunityNFT is OspNFTBase, ICommunityNFT, IERC4906 {
    address public immutable OSP;
    uint256 internal _tokenIdCounter;

    constructor(address osp) {
        if (osp == address(0)) revert OspErrors.InitParamsInvalid();
        OSP = osp;
    }

    function initialize(string calldata name, string calldata symbol) external {
        super._initialize(name, symbol);
    }

    function mint(address to) external override returns (uint256) {
        if (msg.sender != OSP) revert OspErrors.NotOSP();
        unchecked {
            uint256 tokenId = ++_tokenIdCounter;
            _mint(to, tokenId);
            return tokenId;
        }
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return ICommunityLogic(OSP).getCommunityTokenURI(tokenId);
    }

    /**
     * @dev Upon transfers, we emit the transfer event in the osp.
     */
    function _afterTokenTransfer(address from, address to, uint256 tokenId) internal override {
        ICommunityLogic(OSP).emitCommunityNFTTransferEvent(tokenId, from, to);
        super._afterTokenTransfer(from, to, tokenId);
    }

    function updateMetadata() external override {
        emit BatchMetadataUpdate(1, type(uint256).max);
    }
}
