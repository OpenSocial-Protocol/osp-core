// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import '@openzeppelin/contracts/utils/Context.sol';
import '../logics/interfaces/OspClient.sol';

abstract contract OspContext is Context {
    OspClient immutable OSP;

    constructor(address osp) {
        if (osp == address(0)) revert OspErrors.InitParamsInvalid();
        OSP = OspClient(osp);
    }

    modifier onlyOsp() {
        if (_msgSender() != address(OSP)) revert OspErrors.NotOSP();
        _;
    }

    modifier onlyGov() {
        if (!OSP.hasRole(Constants.GOVERNANCE, _msgSender())) revert OspErrors.NotGovernance();
        _;
    }

    modifier onlyOperation() {
        if (!OSP.hasRole(Constants.OPERATION, _msgSender())) revert OspErrors.NotOperation();
        _;
    }

    modifier onlyProfile() {
        if (OSP.getProfileIdByAddress(_msgSender()) == 0) revert OspErrors.NotHasProfile();
        _;
    }

    modifier nonPayable() {
        if (msg.value != 0) revert OspErrors.InvalidValue();
        _;
    }
}
