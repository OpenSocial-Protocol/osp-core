// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {CommunityCondBase} from '../../base/CommunityCondBase.sol';
import {Payment} from '../../../libraries/Payment.sol';
import {ECDSA} from '@openzeppelin/contracts/utils/cryptography/ECDSA.sol';
import {CondErrors} from '../libraries/CondErrors.sol';
import {CondDataTypes} from '../libraries/CondDataTypes.sol';
import {CondHelpers} from '../libraries/CondHelpers.sol';
import {MessageHashUtils} from '@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol';

/**
 * @title PresaleSigCommunityCond
 * @author OpenSocial Protocol
 *
 * @dev This contract specifies that pay the specified amount of ETH to create the community on presale time.
 * The amount of ETH paid is related to the handle length of the community.
 * The community creation must be signed by the specified signer.
 * If the official sale time is reached, the contract will automatically expire.
 */
contract PresaleSigCommunityCond is CommunityCondBase {
    event PresaleTimeSet(uint256 indexed presaleStartTime, uint256 timestamp);
    event SignerSet(address indexed signer, uint256 timestamp);
    event PresaleSigPaid(
        address to,
        uint256 indexed uid,
        uint256 price,
        string handle,
        uint256 timestamp
    );

    using ECDSA for bytes32;
    using MessageHashUtils for bytes32;

    uint256 public presaleStartTime;
    address immutable fixedFeeCommunityCond;
    address signer;
    mapping(uint256 => bool) private _used;

    constructor(
        address osp,
        address _fixedFeeCommunityCond,
        address _signer,
        uint256 _presaleStartTime
    ) CommunityCondBase(osp) {
        fixedFeeCommunityCond = _fixedFeeCommunityCond;
        signer = _signer;
        emit SignerSet(signer, block.timestamp);
        _setPresaleTime(_presaleStartTime);
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
        if (
            block.timestamp < presaleStartTime || block.timestamp > fixedFeeCondData.createStartTime
        ) {
            revert CondErrors.NotPresaleTime();
        }
        (uint256 uid, address target, bytes memory signature) = abi.decode(
            data,
            (uint256, address, bytes)
        );
        if (_used[uid]) {
            revert CondErrors.DuplicateSigUsed();
        }
        _used[uid] = true;
        bytes32 hash = keccak256(abi.encodePacked(uid, target));
        if (hash.toEthSignedMessageHash().recover(signature) != signer || target != to) {
            revert CondErrors.SignatureInvalid();
        }
        uint256 price = CondHelpers.getHandleETHPrice(handle, fixedFeeCondData);
        if (price == 0 || fixedFeeCondData.treasure == address(0)) {
            revert CondErrors.NotPresaleTime();
        }
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
        Payment.payNative(fixedFeeCondData.treasure, price);
        emit PresaleSigPaid(to, uid, price, handle, block.timestamp);
    }

    /**
     * @dev Set the presale start time, must be less than the official sale time
     */
    function setPresaleTime(uint256 _presaleStartTime) external onlyOperation {
        _setPresaleTime(_presaleStartTime);
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

    function passUsed(uint256 uid) external view returns (bool) {
        return _used[uid];
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

    function _setPresaleTime(uint256 _presaleStartTime) internal {
        CondDataTypes.FixedFeeCondData memory fixFeeCondData = _getFixedFeeCondData();
        require(_presaleStartTime < fixFeeCondData.createStartTime, 'Invalid time');
        presaleStartTime = _presaleStartTime;
    }
}
