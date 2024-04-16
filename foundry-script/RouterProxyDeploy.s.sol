// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import 'forge-std/Script.sol';
import {OspRouterImmutable} from '../contracts/upgradeability/OspRouterImmutable.sol';
import {DeployHelper} from './libraries/DeployHelper.sol';

contract RouterProxyDeployScript is Script, DeployHelper {
    using stdJson for string;

    function setUp() public virtual override {
        env = vm.envOr('ENVIRONMENT', string('dev'));
    }

    function run() public {
        vm.startBroadcast();
        console.logAddress(msg.sender);
        address router = create2Deploy(
            abi.encodePacked(type(OspRouterImmutable).creationCode, abi.encode(msg.sender)),
            OSP_SALT
        );
        saveContractAddress('routerProxy', router);
        vm.stopBroadcast();
    }
}
