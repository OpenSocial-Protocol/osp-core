// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import 'forge-std/Script.sol';
import {DeployHelper} from './libraries/DeployHelper.sol';

contract RouterAddScript is Script, DeployHelper {
    function run() public {
        vm.startBroadcast();
        address osp = readAddress('routerProxy');
        string[] memory inputs = new string[](3);
        inputs[0] = 'sh';
        inputs[1] = 'multicalldata.sh';
        inputs[2] = env;
        (bool success, ) = osp.call(vm.ffi(inputs));
        require(success, 'multi call failed');
        vm.stopBroadcast();
    }
}
