// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import 'forge-std/Script.sol';
import {DeployHelper} from './libraries/DeployHelper.sol';
import {VoteReaction} from '../contracts/core/reactions/VoteReaction.sol';
import {LikeReaction} from '../contracts/core/reactions/LikeReaction.sol';

contract ReactionDeployScript is Script, DeployHelper {
    using stdJson for string;

    function run() public {
        vm.startBroadcast();
        address osp = readAddress('routerProxy');
        address likeReaction = address(
            create2Deploy(
                abi.encodePacked(type(LikeReaction).creationCode, abi.encode(osp)),
                OSP_SALT
            )
        );
        saveContractAddress('likeReaction', likeReaction);
        address voteReaction = address(
            create2Deploy(
                abi.encodePacked(type(VoteReaction).creationCode, abi.encode(osp)),
                OSP_SALT
            )
        );
        saveContractAddress('voteReaction', voteReaction);
        vm.stopBroadcast();
    }
}
