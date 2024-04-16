// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import 'forge-std/Script.sol';
import {DeployHelper} from './libraries/DeployHelper.sol';
import {GovernanceLogic} from '../contracts/core/logics/GovernanceLogic.sol';
import {ProfileLogic} from '../contracts/core/logics/ProfileLogic.sol';
import {CommunityLogic} from '../contracts/core/logics/CommunityLogic.sol';
import {ContentLogic} from '../contracts/core/logics/ContentLogic.sol';
import {RelationLogic} from '../contracts/core/logics/RelationLogic.sol';

contract LogicsDeployScript is Script, DeployHelper {
    using stdJson for string;

    function run() public {
        vm.startBroadcast();
        address governanceLogic = address(new GovernanceLogic());
        saveContractAddress('governanceLogic', governanceLogic);
        address profileLogic = address(new ProfileLogic());
        saveContractAddress('profileLogic', profileLogic);
        address communityLogic = address(new CommunityLogic());
        saveContractAddress('communityLogic', communityLogic);
        address contentLogic = address(new ContentLogic());
        saveContractAddress('contentLogic', contentLogic);
        address relationLogic = address(new RelationLogic());
        saveContractAddress('relationLogic', relationLogic);
        vm.stopBroadcast();
    }
}
