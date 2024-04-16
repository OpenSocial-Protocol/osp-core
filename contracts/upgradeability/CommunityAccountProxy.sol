// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {IGovernanceLogic} from '../core/logics/interfaces/IGovernanceLogic.sol';
import {Proxy} from '@openzeppelin/contracts/proxy/Proxy.sol';

contract CommunityAccountProxy is Proxy {
    address immutable OSP;

    constructor() {
        OSP = msg.sender;
    }

    function _implementation() internal view override returns (address) {
        return IGovernanceLogic(OSP).getERC6551AccountImpl();
    }
}
