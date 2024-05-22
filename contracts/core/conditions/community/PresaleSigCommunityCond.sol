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
    using ECDSA for bytes32;
    using MessageHashUtils for bytes32;

    uint256 public presaleStartTime;
    address immutable fixFeeCommunityCond;
    address signer;
    mapping(uint256 => bool) private _used;

    constructor(
        address osp,
        uint256 _presaleStartTime,
        address _fixFeeCommunityCond,
        address _signer
    ) CommunityCondBase(osp) {
        _setPresaleTime(_presaleStartTime);
        fixFeeCommunityCond = _fixFeeCommunityCond;
        signer = _signer;
    }

    /**
     * @dev process create community, pay the specified amount of ETH to create the community on presale time.
     */
    function _processCreateCommunity(
        address to,
        string calldata handle,
        bytes calldata data
    ) internal override {
        CondDataTypes.FixFeeCondData memory fixFeeCondData = _getFixFeeCondData();
        if (
            block.timestamp < presaleStartTime || block.timestamp > fixFeeCondData.createStartTime
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
        uint256 price = CondHelpers.getHandleETHPrice(handle, fixFeeCondData);
        if (price == 0 || fixFeeCondData.treasure == address(0)) {
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
        Payment.payNative(fixFeeCondData.treasure, price);
    }

    /**
     * @dev Set the presale start time, must be less than the official sale time
     */
    function setPresaleTime(uint256 _presaleStartTime) external onlyOperation {
        _setPresaleTime(_presaleStartTime);
    }

    /**
     * @dev Set the signer address
     */
    function setSigner(address _signer) external onlyOperation {
        signer = _signer;
    }


    /**
    * @dev Get the fix fee condition data from fixFeeCommunityCond contract.
     */
    function _getFixFeeCondData() internal view returns (CondDataTypes.FixFeeCondData memory) {
        (bool success, bytes memory returnData) = fixFeeCommunityCond.staticcall(
            abi.encodeWithSignature('stableFeeCondData()')
        );
        require(success, 'call fixFeeCommunityCond failed');
        return abi.decode(returnData, (CondDataTypes.FixFeeCondData));
    }

    function _setPresaleTime(uint256 _presaleStartTime)  {
        CondDataTypes.FixFeeCondData memory fixFeeCondData = _getFixFeeCondData();
        require(_presaleStartTime < fixFeeCondData.createStartTime, 'Invalid time');
        presaleStartTime = _presaleStartTime;
    }
}
