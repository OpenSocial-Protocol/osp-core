// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import 'forge-std/Script.sol';
import {DeployHelper} from './libraries/DeployHelper.sol';
import {FollowSBT} from '../contracts/core/FollowSBT.sol';
import {JoinNFT} from '../contracts/core/JoinNFT.sol';

contract NFTImplDeployScript is Script, DeployHelper {
    using stdJson for string;

    function run() public {
        vm.startBroadcast();
        address osp = readAddress('routerProxy');
        address followSBTImpl = address(new FollowSBT(osp));
        saveContractAddress('followSBTImpl', followSBTImpl);
        address joinNFTImpl = address(new JoinNFT(osp));
        saveContractAddress('joinNFTImpl', joinNFTImpl);
        vm.stopBroadcast();
    }
}
