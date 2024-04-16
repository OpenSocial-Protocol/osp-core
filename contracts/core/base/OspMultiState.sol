// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import '../../libraries/OspEvents.sol';
import '../../libraries/OspDataTypes.sol';
import '../../libraries/OspErrors.sol';

/**
 * @title OspMultiState
 *
 * @dev This is an abstract contract that implements internal state setting and validation.
 *
 * whenNotPaused: Either publishingPaused or Unpaused.
 * whenPublishingEnabled: When Unpaused only.
 */
abstract contract OspMultiState {
    struct ProtocolStateStorage {
        OspDataTypes.ProtocolState state;
    }
    bytes32 internal constant STATE_STORAGE_POSITION = keccak256('osp.state.storage');

    modifier whenNotPaused() {
        _validateNotPaused();
        _;
    }

    modifier whenPublishingEnabled() {
        _validatePublishingEnabled();
        _;
    }

    function protocolStateStorage()
        internal
        pure
        returns (ProtocolStateStorage storage protocolState)
    {
        bytes32 position = STATE_STORAGE_POSITION;
        assembly {
            protocolState.slot := position
        }
    }

    /**
     * @dev Returns the current protocol state.
     *
     * @return ProtocolState The Protocol state, an enum, where:
     *      0: Unpaused
     *      1: PublishingPaused
     *      2: Paused
     */
    function _getState() internal view returns (OspDataTypes.ProtocolState) {
        return protocolStateStorage().state;
    }

    function _setState(OspDataTypes.ProtocolState newState) internal {
        OspDataTypes.ProtocolState prevState = protocolStateStorage().state;
        protocolStateStorage().state = newState;
        emit OspEvents.StateSet(msg.sender, prevState, newState, block.timestamp);
    }

    function _validatePublishingEnabled() internal view {
        if (protocolStateStorage().state != OspDataTypes.ProtocolState.Unpaused) {
            revert OspErrors.PublishingPaused();
        }
    }

    function _validateNotPaused() internal view {
        if (protocolStateStorage().state == OspDataTypes.ProtocolState.Paused)
            revert OspErrors.Paused();
    }
}
