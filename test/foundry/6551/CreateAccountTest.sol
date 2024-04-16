// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {console2, Test} from 'forge-std/Test.sol';
import '@openzeppelin/contracts/utils/Address.sol';
import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '../../../contracts/interfaces/IERC6551Registry.sol';
import '../../../contracts/libraries/Constants.sol';
import '../../../contracts/libraries/OspEvents.sol';
import '../mocks/MockNFT.sol';

contract CreateAccountTest is Test {
    IERC6551Registry registry;
    MockNFT token;
    address constant IMPL = address(0x0000000000000000000000000000000000000001);

    function setUp() public {
        bytes memory res = Address.functionCall(
            0x4e59b44847b379578588920cA78FbF26c0B4956C,
            hex'0000000000000000000000000000000000000000fd8eb4e1dca713016c518e31608060405234801561001057600080fd5b5061023b806100206000396000f3fe608060405234801561001057600080fd5b50600436106100365760003560e01c8063246a00211461003b5780638a54c52f1461006a575b600080fd5b61004e6100493660046101b7565b61007d565b6040516001600160a01b03909116815260200160405180910390f35b61004e6100783660046101b7565b6100e1565b600060806024608c376e5af43d82803e903d91602b57fd5bf3606c5285605d52733d60ad80600a3d3981f3363d3d373d3d3d363d7360495260ff60005360b76055206035523060601b60015284601552605560002060601b60601c60005260206000f35b600060806024608c376e5af43d82803e903d91602b57fd5bf3606c5285605d52733d60ad80600a3d3981f3363d3d373d3d3d363d7360495260ff60005360b76055206035523060601b600152846015526055600020803b61018b578560b760556000f580610157576320188a596000526004601cfd5b80606c52508284887f79f19b3655ee38b1ce526556b7731a20c8f218fbda4a3990b6cc4172fdf887226060606ca46020606cf35b8060601b60601c60005260206000f35b80356001600160a01b03811681146101b257600080fd5b919050565b600080600080600060a086880312156101cf57600080fd5b6101d88661019b565b945060208601359350604086013592506101f46060870161019b565b94979396509194608001359291505056fea2646970667358221220ea2fe53af507453c64dd7c1db05549fa47a298dfb825d6d11e1689856135f16764736f6c63430008110033'
        );
        address addr;
        assembly {
            addr := mload(add(res, 20))
        }
        registry = IERC6551Registry(addr);
        token = new MockNFT('MockNFT', 'SLOT');
        token.mintTo(address(this));
    }

    function test_CreateAccount() public {
        assertTrue(token.ownerOf(1) == address(this));
        address account = registry.createAccount(
            IMPL,
            Constants.COMMUNITY_TBA_SALT,
            block.chainid,
            address(token),
            1
        );
        assertTrue(account != address(0));
    }

    function test_GetAccount() public {
        address account = registry.account(
            IMPL,
            Constants.COMMUNITY_TBA_SALT,
            block.chainid,
            address(token),
            1
        );
        assertTrue(account != address(0));
        assertTrue(account == 0x3d9155104D57739E919fECC79f424352695f4c80);
    }
}
