// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {CommunityCondBase} from '../../base/CommunityCondBase.sol';
import {Payment} from '../../../libraries/Payment.sol';
import {ECDSA} from '@openzeppelin/contracts/utils/cryptography/ECDSA.sol';
import {CondErrors} from '../libraries/CondErrors.sol';
import {CondDataTypes} from '../libraries/CondDataTypes.sol';
import {CondHelpers} from '../libraries/CondHelpers.sol';
import {MessageHashUtils} from '@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol';
import {IERC721} from '@openzeppelin/contracts/token/ERC721/IERC721.sol';

/**
 * @title PresaleSigCommunityCond
 * @author OpenSocial Protocol
 *
 * @dev This contract specifies that pay the specified amount of ETH to create the community on presale time.
 * The amount of ETH paid is related to the handle length of the community.
 * The community creation must be signed by the specified signer.
 * The signer must sign the ticket and tokenId(ticket is ERC721), target addr must hold the token.
 * If the official sale time is reached, the contract will automatically expire.
 */
contract PresaleSigCommunityCond is CommunityCondBase {
    event PresaleTimeSet(uint256 indexed presaleStartTime, uint256 timestamp);
    event SignerSet(address indexed signer, uint256 timestamp);

    event PresaleSigPaid(
        address indexed to,
        address indexed ticket,
        uint256 indexed tokenId,
        uint256 price,
        string handle,
        uint256 timestamp
    );

    using ECDSA for bytes32;
    using MessageHashUtils for bytes32;

    uint256 public presaleStartTime;
    address immutable fixedFeeCommunityCond;
    address signer;
    mapping(address => mapping(uint256 => bool)) _ticketUsed;

    constructor(
        address osp,
        address _fixedFeeCommunityCond,
        address _signer,
        uint256 _presaleStartTime
    ) CommunityCondBase(osp) {
        fixedFeeCommunityCond = _fixedFeeCommunityCond;
        signer = _signer;
        emit SignerSet(signer, block.timestamp);
        _setPresaleStartTime(_presaleStartTime);
        emit PresaleTimeSet(presaleStartTime, block.timestamp);
    }

    /**
     * @dev process create community, pay the specified amount of ETH to create the community on presale time.
     */
    function _processCreateCommunity(
        address to,
        string calldata handle,
        bytes calldata data
    ) internal override {
        CondDataTypes.FixedFeeCondData memory fixedFeeCondData = _getFixedFeeCondData();
        if (!isPresaleTime()) {
            revert CondErrors.NotPresaleTime();
        }
        (address ticket, uint256 tokenId) = _validateTicketAndSig(to, data);
        uint256 price = CondHelpers.getHandleETHPrice(handle, fixedFeeCondData);
        _charge(price, to);
        emit PresaleSigPaid(to, ticket, tokenId, price, handle, block.timestamp);
    }

    /**
     * @dev Set the presale start time, must be less than the official sale time
     */
    function setPresaleStartTime(uint256 _presaleStartTime) external onlyOperation {
        _setPresaleStartTime(_presaleStartTime);
        emit PresaleTimeSet(presaleStartTime, block.timestamp);
    }

    /**
     * @dev Set the signer address
     */
    function setSigner(address _signer) external onlyOperation {
        signer = _signer;
        emit SignerSet(signer, block.timestamp);
    }

    /**
     * @dev Get the handle price based on the length of the handle.
     */
    function getHandlePrice(string calldata handle) external view returns (uint256) {
        CondDataTypes.FixedFeeCondData memory fixedFeeCondData = _getFixedFeeCondData();
        return CondHelpers.getHandleETHPrice(handle, fixedFeeCondData);
    }

    function isTicketUsable(
        address ticket,
        uint256 tokenId,
        address holder
    ) external view returns (bool) {
        return !_ticketUsed[ticket][tokenId] && IERC721(ticket).ownerOf(tokenId) == holder;
    }

    function isPresaleTime() public view returns (bool) {
        return
            block.timestamp >= presaleStartTime &&
            block.timestamp < _getFixedFeeCondData().createStartTime;
    }

    function getPresaleTime() public view returns (uint256 start, uint256 end) {
        start = presaleStartTime;
        end = _getFixedFeeCondData().createStartTime;
    }

    /**
     * @dev Get the fixed fee condition data from fixFeeCommunityCond contract.
     */
    function _getFixedFeeCondData() internal view returns (CondDataTypes.FixedFeeCondData memory) {
        (bool success, bytes memory returnData) = fixedFeeCommunityCond.staticcall(
            abi.encodeWithSignature('fixedFeeCondData()')
        );
        require(success, 'call fixFeeCommunityCond failed');
        return abi.decode(returnData, (CondDataTypes.FixedFeeCondData));
    }

    function _setPresaleStartTime(uint256 _presaleStartTime) internal {
        CondDataTypes.FixedFeeCondData memory fixFeeCondData = _getFixedFeeCondData();
        require(_presaleStartTime < fixFeeCondData.createStartTime, 'Invalid time');
        presaleStartTime = _presaleStartTime;
    }

    function _charge(uint256 price, address to) internal virtual {
        if (msg.value < price) {
            revert CondErrors.InsufficientPayment();
        }
        uint256 overpayment;
        unchecked {
            overpayment = msg.value - price;
        }
        if (overpayment > 0) {
            Payment.payNative(to, overpayment);
        }
        Payment.payNative(OSP.getTreasureAddress(), price);
    }

    function _validateTicketAndSig(
        address to,
        bytes calldata data
    ) internal returns (address, uint256) {
        (
            address ticket,
            uint256 tokenId,
            address holder,
            address target,
            uint256 chainid,
            bytes memory signature
        ) = abi.decode(data, (address, uint256, address, address, uint256, bytes));
        // the signer determine the relationship between holder and target
        if (
            (_ticketUsed[ticket][tokenId] || IERC721(ticket).ownerOf(tokenId) != holder) ||
            target != to ||
            chainid != block.chainid
        ) {
            revert CondErrors.InvalidTicket();
        }
        bytes32 hash = keccak256(abi.encodePacked(ticket, tokenId, holder, target, chainid));
        if (hash.toEthSignedMessageHash().recover(signature) != signer) {
            revert CondErrors.SignatureInvalid();
        }
        _ticketUsed[ticket][tokenId] = true;
        return (ticket, tokenId);
    }
}
