// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import 'forge-std/Script.sol';
import {OspRouterImmutable} from '../contracts/upgradeability/OspRouterImmutable.sol';
import {DeployHelper} from './libraries/DeployHelper.sol';
import {IGovernanceLogic} from '../contracts/core/logics/interfaces/IGovernanceLogic.sol';
import {Constants} from '../contracts/libraries/Constants.sol';
import {IAccessControl} from '@openzeppelin/contracts/access/AccessControl.sol';

contract InitializeScript is Script, DeployHelper {
    function run() public {
        vm.startBroadcast();
        address payable osp = readAddress('routerProxy');
        bytes[] memory initCallData = new bytes[](11);
        initCallData[0] = abi.encodeWithSelector(
            IGovernanceLogic.initialize.selector,
            'OpenSocial Protocol Profiles',
            'OSPT',
            readAddress('followSBTImpl'),
            readAddress('joinNFTImpl'),
            readAddress('communityNFT')
        );
        //grand role
        initCallData[1] = abi.encodeWithSelector(
            IAccessControl.grantRole.selector,
            Constants.GOVERNANCE,
            msg.sender
        );
        initCallData[2] = abi.encodeWithSelector(
            IAccessControl.grantRole.selector,
            Constants.APP_ADMIN,
            msg.sender
        );
        initCallData[3] = abi.encodeWithSelector(
            IAccessControl.grantRole.selector,
            Constants.GOVERNANCE,
            msg.sender
        );
        initCallData[4] = abi.encodeWithSelector(
            IAccessControl.grantRole.selector,
            Constants.OPERATION,
            msg.sender
        );
        initCallData[5] = abi.encodeWithSelector(
            IGovernanceLogic.whitelistApp.selector,
            readAddress('erc20FeeJoinCond'),
            true
        );
        initCallData[6] = abi.encodeWithSelector(
            IGovernanceLogic.whitelistApp.selector,
            readAddress('holdTokenJoinCond'),
            true
        );
        initCallData[7] = abi.encodeWithSelector(
            IGovernanceLogic.whitelistApp.selector,
            readAddress('nativeFeeJoinCond'),
            true
        );

        initCallData[8] = abi.encodeWithSelector(
            IGovernanceLogic.whitelistApp.selector,
            readAddress('slotNFTCommunityCond'),
            true
        );
        initCallData[9] = abi.encodeWithSelector(
            IGovernanceLogic.whitelistApp.selector,
            readAddress('onlyMemberReferenceCond'),
            true
        );
        initCallData[10] = abi.encodeWithSelector(
            IGovernanceLogic.whitelistApp.selector,
            readAddress('likeReaction'),
            true
        );
        OspRouterImmutable(osp).multicall(initCallData);
        vm.stopBroadcast();
    }
}
