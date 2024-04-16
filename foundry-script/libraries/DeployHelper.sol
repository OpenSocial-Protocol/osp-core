// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {OspRouterImmutable} from '../../contracts/upgradeability/OspRouterImmutable.sol';
import {console} from 'forge-std/console.sol';
import {OspUniversalProxy} from '../../contracts/upgradeability/OspUniversalProxy.sol';
import {CommunityNFT} from '../../contracts/core/CommunityNFT.sol';
import '@openzeppelin/contracts/utils/Address.sol';
import 'forge-std/Script.sol';

contract DeployHelper is Script {
    string json;
    using stdJson for string;
    string env;

    bytes32 OSP_SALT = vm.envOr('OSP_SALT', keccak256(abi.encodePacked('OSP')));

    function setUp() public virtual {
        setDeployParams();
    }

    function setDeployParams() internal {
        env = vm.envOr('ENVIRONMENT', string('dev'));
        string memory root = vm.projectRoot();
        string memory path = string(
            abi.encodePacked(root, abi.encodePacked('/addresses-', env, '.json'))
        );
        json = vm.readFile(path);
    }

    function saveContractAddress(string memory contractName, address deployedAddress) internal {
        console.log(
            'Saving %s (%s) into addresses under %s environment',
            contractName,
            deployedAddress,
            env
        );
        string[] memory inputs = new string[](5);
        inputs[0] = 'node';
        inputs[1] = 'foundry-script/utils/save-address.js';
        inputs[2] = env;
        inputs[3] = contractName;
        inputs[4] = vm.toString(deployedAddress);
        vm.ffi(inputs);
    }

    function readAddress(string memory contractName) internal view returns (address payable) {
        return
            payable(
                json.readAddress(
                    string(abi.encodePacked('.', string(abi.encodePacked('.', contractName))))
                )
            );
    }

    function create2Deploy(bytes memory code, bytes32 salt) internal returns (address) {
        bytes memory res = Address.functionCall(
            0x4e59b44847b379578588920cA78FbF26c0B4956C,
            abi.encodePacked(salt, code)
        );
        address addr;
        assembly {
            addr := mload(add(res, 20))
        }
        return addr;
    }
}
