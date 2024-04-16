// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import 'forge-std/Script.sol';
import {DeployHelper} from './libraries/DeployHelper.sol';
import {GovernanceLogic} from '../contracts/core/logics/GovernanceLogic.sol';
import {SlotNFTCommunityCond} from '../contracts/core/conditions/community/SlotNFTCommunityCond.sol';

contract WhitelistTokenAddScript is Script, DeployHelper {
    function run() public {
        vm.startBroadcast();
        address payable osp = readAddress('routerProxy');
        address[] memory tokens = vm.envAddress('WHITELIST_TOKENS', ',');
        for (uint256 i = 0; i < tokens.length; i++) {
            console.log('Whitelisted token: %s', tokens[i]);
            GovernanceLogic(osp).whitelistToken(tokens[i], true);
        }
        vm.stopBroadcast();
    }
}

contract WhitelistSlotNFTAddScript is Script, DeployHelper {
    function run() public {
        vm.startBroadcast();
        address slotNFTCommunityCond = readAddress('slotNFTCommunityCond');
        address[] memory tokens = vm.envAddress('WHITELIST_SLOTS', ',');
        for (uint256 i = 0; i < tokens.length; i++) {
            console.log('Whitelisted slot NFT: %s', tokens[i]);
            SlotNFTCommunityCond(slotNFTCommunityCond).whitelistCommunitySlot(tokens[i], true);
        }
        vm.stopBroadcast();
    }
}
