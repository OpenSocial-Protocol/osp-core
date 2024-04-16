// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import 'forge-std/Script.sol';
import {DeployHelper} from './libraries/DeployHelper.sol';
import {ERC20FeeJoinCond} from '../contracts/core/conditions/join/ERC20FeeJoinCond.sol';
import {HoldTokenJoinCond} from '../contracts/core/conditions/join/HoldTokenJoinCond.sol';
import {NativeFeeJoinCond} from '../contracts/core/conditions/join/NativeFeeJoinCond.sol';
import {SlotNFTCommunityCond} from '../contracts/core/conditions/community/SlotNFTCommunityCond.sol';
import {WhitelistAddressCommunityCond} from '../contracts/core/conditions/community/WhitelistAddressCommunityCond.sol';
import {OnlyMemberReferenceCond} from '../contracts/core/conditions/reference/OnlyMemberReferenceCond.sol';

contract CondDeployScript is Script, DeployHelper {
    using stdJson for string;

    function run() public {
        vm.startBroadcast();
        address osp = readAddress('routerProxy');
        address erc20FeeJoinCond = address(
            create2Deploy(
                abi.encodePacked(type(ERC20FeeJoinCond).creationCode, abi.encode(osp)),
                OSP_SALT
            )
        );
        saveContractAddress('erc20FeeJoinCond', erc20FeeJoinCond);
        address holdTokenJoinCond = address(
            create2Deploy(
                abi.encodePacked(type(HoldTokenJoinCond).creationCode, abi.encode(osp)),
                OSP_SALT
            )
        );
        saveContractAddress('holdTokenJoinCond', holdTokenJoinCond);
        address nativeFeeJoinCond = address(
            create2Deploy(
                abi.encodePacked(type(NativeFeeJoinCond).creationCode, abi.encode(osp)),
                OSP_SALT
            )
        );
        saveContractAddress('nativeFeeJoinCond', nativeFeeJoinCond);
        address slotNFTCommunityCond = address(
            create2Deploy(
                abi.encodePacked(type(SlotNFTCommunityCond).creationCode, abi.encode(osp)),
                OSP_SALT
            )
        );
        saveContractAddress('slotNFTCommunityCond', slotNFTCommunityCond);
        address whitelistAddressCommunityCond = address(
            create2Deploy(
                abi.encodePacked(type(WhitelistAddressCommunityCond).creationCode, abi.encode(osp)),
                OSP_SALT
            )
        );
        saveContractAddress('whitelistAddressCommunityCond', whitelistAddressCommunityCond);
        address onlyMemberReferenceCond = address(
            create2Deploy(
                abi.encodePacked(type(OnlyMemberReferenceCond).creationCode, abi.encode(osp)),
                OSP_SALT
            )
        );
        saveContractAddress('onlyMemberReferenceCond', onlyMemberReferenceCond);
        vm.stopBroadcast();
    }
}
