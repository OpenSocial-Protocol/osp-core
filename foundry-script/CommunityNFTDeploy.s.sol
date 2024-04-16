// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import 'forge-std/Script.sol';
import {DeployHelper} from './libraries/DeployHelper.sol';
import {CommunityNFT} from '../contracts/core/CommunityNFT.sol';
import {OspUniversalProxy} from '../contracts/upgradeability/OspUniversalProxy.sol';

contract CommunityNftDeployScript is Script, DeployHelper {
    using stdJson for string;

    function run() public {
        vm.startBroadcast();
        address osp = readAddress('routerProxy');
        address communityNFT = address(new CommunityNFT(osp));
        saveContractAddress('communityNFT', communityNFT);
        address communityNFTProxy = deployCommunityProxy(osp, communityNFT);
        saveContractAddress('communityNFTProxy', communityNFTProxy);
        vm.stopBroadcast();
    }

    function deployCommunityProxy(address router, address impl) internal returns (address) {
        address communityProxy = create2Deploy(
            abi.encodePacked(
                type(OspUniversalProxy).creationCode,
                abi.encode(
                    router,
                    impl,
                    abi.encodeWithSelector(
                        CommunityNFT.initialize.selector,
                        'OpenSocial Protocol Community',
                        'OSP'
                    )
                )
            ),
            OSP_SALT
        );
        return router;
    }
}
