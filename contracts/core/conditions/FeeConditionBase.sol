// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {OspContext} from '../../core/base/OspContext.sol';
import {CondErrors} from './libraries/CondErrors.sol';
import {IGovernanceLogic} from '../logics/interfaces/IGovernanceLogic.sol';

/**
 * @title FeeConditionBase
 * @author OpenSocial Protocol
 *
 * @dev This is an abstract contract to be inherited from by conditions that require basic fee functionality. It
 * contains getters for condition globals parameters as well as a validation function to check expected data.
 */
abstract contract FeeConditionBase is OspContext {
    function _validateDataIsExpected(
        bytes calldata data,
        address currency,
        uint256 amount
    ) internal pure {
        (address decodedCurrency, uint256 decodedAmount) = abi.decode(data, (address, uint256));
        if (decodedAmount != amount || decodedCurrency != currency)
            revert CondErrors.ConditionDataMismatch();
    }

    function _tokenWhitelisted(address token) internal view returns (bool) {
        return IGovernanceLogic(OSP).isTokenWhitelisted(token);
    }
}
