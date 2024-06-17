// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import './logics/interfaces/OspClient.sol';
import '../interfaces/ICommunityNFT.sol';
import '../libraries/OspErrors.sol';
import './base/OspNFTBase.sol';
import './base/IERC4906.sol';
import '@thirdweb-dev/contracts/extension/upgradeable/ContractMetadata.sol';
import '@openzeppelin/contracts-upgradeable/token/common/ERC2981Upgradeable.sol';

/**
 * @title CommunityNFT
 * @author OpenSocial Protocol
 * @dev This NFT contract is minted upon community is created.
 */
contract CommunityNFT is OspNFTBase, ContractMetadata, ICommunityNFT, IERC4906, ERC2981Upgradeable {
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

    function setTokenRoyalty(address receiver, uint96 feeNumerator) external {
        if (!OspClient(OSP).hasRole(Constants.GOVERNANCE, _msgSender())) {
            revert OspErrors.NotGovernance();
        }
        _setDefaultRoyalty(receiver, feeNumerator);
    }

    function updateMetadata() external override {
        emit BatchMetadataUpdate(1, type(uint256).max);
    }

    function burn(uint256 tokenId) public override {
        _update(address(this), tokenId, _msgSender());
    }

    function _canSetContractURI() internal view override returns (bool) {
        return OspClient(OSP).hasRole(Constants.GOVERNANCE, _msgSender());
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(OspNFTBase, ERC2981Upgradeable) returns (bool) {
        return
            ERC2981Upgradeable.supportsInterface(interfaceId) ||
            OspNFTBase.supportsInterface(interfaceId);
    }
}
