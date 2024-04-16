// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {IGovernanceLogic} from '../core/logics/interfaces/IGovernanceLogic.sol';
import {Proxy} from '@openzeppelin/contracts/proxy/Proxy.sol';
import {Address} from '@openzeppelin/contracts/utils/Address.sol';

contract JoinNFTProxy is Proxy {
    using Address for address;
    address immutable OSP;

    constructor(bytes memory data) {
        OSP = msg.sender;
        IGovernanceLogic(msg.sender).getJoinNFTImpl().functionDelegateCall(data);
    }

    function _implementation() internal view override returns (address) {
        return IGovernanceLogic(OSP).getJoinNFTImpl();
    }
}
