// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import '../core/logics/interfaces/OspClient.sol';
import '../core/base/OspContext.sol';

import {ERC1967Utils} from '@openzeppelin/contracts/proxy/ERC1967/ERC1967Utils.sol';
import {ERC1967Proxy} from '@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol';

contract OspUniversalProxy is OspContext, ERC1967Proxy {
    constructor(
        address osp,
        address implementation,
        bytes memory data
    ) OspContext(osp) ERC1967Proxy(implementation, data) {}

    function updateToAndCall(address newImplementation, bytes memory data) external onlyGov {
        ERC1967Utils.upgradeToAndCall(newImplementation, data);
    }
}
