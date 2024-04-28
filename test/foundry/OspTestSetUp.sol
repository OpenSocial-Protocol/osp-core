// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import './OspTestConstant.sol';
import 'forge-std/console.sol';
import {ProfileLogic, OspDataTypes, OspErrors, OspEvents} from '../../contracts/core/logics/ProfileLogic.sol';
import {CommunityLogic} from '../../contracts/core/logics/CommunityLogic.sol';
import {IRouter} from '../../contracts/upgradeability/IRouter.sol';
import {OspRouterImmutable} from '../../contracts/upgradeability/OspRouterImmutable.sol';
import {RelationLogic} from '../../contracts/core/logics/RelationLogic.sol';
import {ContentLogic} from '../../contracts/core/logics/ContentLogic.sol';
import {GovernanceLogic} from '../../contracts/core/logics/GovernanceLogic.sol';
import {OspClient} from '../../contracts/core/logics/interfaces/OspClient.sol';
import {FollowSBT} from '../../contracts/core/FollowSBT.sol';
import {JoinNFT} from '../../contracts/core/JoinNFT.sol';
import {CommunityNFT} from '../../contracts/core/CommunityNFT.sol';
import {OspUniversalProxy} from '../../contracts/upgradeability/OspUniversalProxy.sol';
import '@openzeppelin/contracts/utils/Address.sol';
import '../../contracts/libraries/Constants.sol';

abstract contract OspTestSetUp is OspTestConstant {
    ProfileLogic profileLogic;

    CommunityLogic communityLogic;

    RelationLogic relationLogic;

    ContentLogic contentLogic;

    GovernanceLogic governanceLogic;

    IRouter ospRouter;

    OspClient ospClient;

    CommunityNFT communityNFT;

    function setUp() public virtual {
        vm.startPrank(deployer);

        profileLogic = new ProfileLogic();
        communityLogic = new CommunityLogic();
        relationLogic = new RelationLogic();
        contentLogic = new ContentLogic();
        governanceLogic = new GovernanceLogic();

        ospRouter = new OspRouterImmutable(deployer);
        ospClient = OspClient(address(ospRouter));

        initRouter();

        FollowSBT followSbtImpl = new FollowSBT(address(ospClient));
        JoinNFT joinNftImpl = new JoinNFT(address(ospClient));
        communityNFT = CommunityNFT(
            address(
                new OspUniversalProxy(
                    address(ospRouter),
                    address(new CommunityNFT(address(ospClient))),
                    abi.encodeWithSelector(
                        CommunityNFT.initialize.selector,
                        'OpenSocial Protocol Community',
                        'OSPC'
                    )
                )
            )
        );
        ospClient.initialize(
            OSP_NAME,
            OSP_SYMBOL,
            address(followSbtImpl),
            address(joinNftImpl),
            address(communityNFT)
        );
        ospClient.grantRole(Constants.GOVERNANCE, deployer);
        ospClient.grantRole(Constants.APP_ADMIN, deployer);
        ospClient.grantRole(Constants.OPERATION, deployer);
        ospClient.grantRole(Constants.STATE_ADMIN, deployer);
        //deploy registry
        Address.functionCall(
            0x4e59b44847b379578588920cA78FbF26c0B4956C,
            hex'0000000000000000000000000000000000000000fd8eb4e1dca713016c518e31608060405234801561001057600080fd5b5061023b806100206000396000f3fe608060405234801561001057600080fd5b50600436106100365760003560e01c8063246a00211461003b5780638a54c52f1461006a575b600080fd5b61004e6100493660046101b7565b61007d565b6040516001600160a01b03909116815260200160405180910390f35b61004e6100783660046101b7565b6100e1565b600060806024608c376e5af43d82803e903d91602b57fd5bf3606c5285605d52733d60ad80600a3d3981f3363d3d373d3d3d363d7360495260ff60005360b76055206035523060601b60015284601552605560002060601b60601c60005260206000f35b600060806024608c376e5af43d82803e903d91602b57fd5bf3606c5285605d52733d60ad80600a3d3981f3363d3d373d3d3d363d7360495260ff60005360b76055206035523060601b600152846015526055600020803b61018b578560b760556000f580610157576320188a596000526004601cfd5b80606c52508284887f79f19b3655ee38b1ce526556b7731a20c8f218fbda4a3990b6cc4172fdf887226060606ca46020606cf35b8060601b60601c60005260206000f35b80356001600160a01b03811681146101b257600080fd5b919050565b600080600080600060a086880312156101cf57600080fd5b6101d88661019b565b945060208601359350604086013592506101f46060870161019b565b94979396509194608001359291505056fea2646970667358221220ea2fe53af507453c64dd7c1db05549fa47a298dfb825d6d11e1689856135f16764736f6c63430008110033'
        );
        ospClient.setState(OspDataTypes.ProtocolState.Unpaused);
        ospClient.setBaseURI(BASE_URL);
        vm.stopPrank();
    }

    /**
     * @dev The method is automatically generated at compile time
     */
    function initRouter() private {
        //addRouter
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'4096ab3c',
                functionSignature: 'createCommunity((string,bytes,bytes,string[],bytes))',
                routerAddress: address(communityLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'0e78341a',
                functionSignature: 'emitCommunityNFTTransferEvent(uint256,address,address)',
                routerAddress: address(communityLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'370603f8',
                functionSignature: 'getCommunity(uint256)',
                routerAddress: address(communityLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'65c2ee57',
                functionSignature: 'getCommunityAccount(uint256)',
                routerAddress: address(communityLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'6ceb8240',
                functionSignature: 'getCommunityAccount(string)',
                routerAddress: address(communityLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'ea70e18b',
                functionSignature: 'getCommunityIdByHandle(string)',
                routerAddress: address(communityLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'e2743060',
                functionSignature: 'getCommunityTokenURI(uint256)',
                routerAddress: address(communityLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'915a0ec5',
                functionSignature: 'getJoinCondition(uint256)',
                routerAddress: address(communityLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'724c7131',
                functionSignature: 'getJoinNFT(uint256)',
                routerAddress: address(communityLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'46baaa2a',
                functionSignature: 'setJoinCondition(uint256,bytes)',
                routerAddress: address(communityLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'7e16bdcf',
                functionSignature: 'createActivity((uint256,uint256,string,bytes,bytes,bytes))',
                routerAddress: address(contentLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'72ef53e3',
                functionSignature: 'createActivityWithSig((uint256,uint256,string,bytes,bytes,bytes),(address,bytes,uint256))',
                routerAddress: address(contentLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'd9250562',
                functionSignature: 'createComment((uint256,uint256,string,uint256,uint256,bytes,bytes,bytes))',
                routerAddress: address(contentLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'2418f2a9',
                functionSignature: 'createCommentWithSig((uint256,uint256,string,uint256,uint256,bytes,bytes,bytes),(address,bytes,uint256))',
                routerAddress: address(contentLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'3cdf6e49',
                functionSignature: 'createMegaphone((uint256,uint256,uint256,string[],uint256,uint256,address,uint256,bytes))',
                routerAddress: address(contentLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'aa943da5',
                functionSignature: 'createOpenReaction((uint256,uint256,uint256,uint256,uint256,bytes,bytes,bytes))',
                routerAddress: address(contentLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'b2a5d5b8',
                functionSignature: 'createOpenReactionWithSig((uint256,uint256,uint256,uint256,uint256,bytes,bytes,bytes),(address,bytes,uint256))',
                routerAddress: address(contentLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'898bd205',
                functionSignature: 'getCommunityIdByContent(uint256,uint256)',
                routerAddress: address(contentLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'31730a1d',
                functionSignature: 'getContent(uint256,uint256)',
                routerAddress: address(contentLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'1f54a327',
                functionSignature: 'getContentCount(uint256)',
                routerAddress: address(contentLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'84b0196e',
                functionSignature: 'eip712Domain()',
                routerAddress: address(governanceLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'714c5398',
                functionSignature: 'getBaseURI()',
                routerAddress: address(governanceLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'17cb1d3f',
                functionSignature: 'getCommunityNFT()',
                routerAddress: address(governanceLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'14a3a5df',
                functionSignature: 'getERC6551AccountImpl()',
                routerAddress: address(governanceLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'a52f057e',
                functionSignature: 'getFollowSBTImpl()',
                routerAddress: address(governanceLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'4a7e20f7',
                functionSignature: 'getJoinNFTImpl()',
                routerAddress: address(governanceLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'248a9ca3',
                functionSignature: 'getRoleAdmin(bytes32)',
                routerAddress: address(governanceLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'1865c57d',
                functionSignature: 'getState()',
                routerAddress: address(governanceLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'8705c8d2',
                functionSignature: 'getTreasureAddress()',
                routerAddress: address(governanceLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'2f2ff15d',
                functionSignature: 'grantRole(bytes32,address)',
                routerAddress: address(governanceLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'91d14854',
                functionSignature: 'hasRole(bytes32,address)',
                routerAddress: address(governanceLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'db0ed6a0',
                functionSignature: 'initialize(string,string,address,address,address)',
                routerAddress: address(governanceLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'52d98229',
                functionSignature: 'isAppWhitelisted(address)',
                routerAddress: address(governanceLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'663e7b5c',
                functionSignature: 'isReserveCommunityHandle(string)',
                routerAddress: address(governanceLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'b8ebaba2',
                functionSignature: 'isSuperCommunityCreatorWhitelisted(address)',
                routerAddress: address(governanceLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'b5af090f',
                functionSignature: 'isTokenWhitelisted(address)',
                routerAddress: address(governanceLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'36568abe',
                functionSignature: 'renounceRole(bytes32,address)',
                routerAddress: address(governanceLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'97945675',
                functionSignature: 'reserveCommunityHandle(string,bool)',
                routerAddress: address(governanceLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'd547741f',
                functionSignature: 'revokeRole(bytes32,address)',
                routerAddress: address(governanceLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'55f804b3',
                functionSignature: 'setBaseURI(string)',
                routerAddress: address(governanceLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'6f23c641',
                functionSignature: 'setERC6551AccountImpl(address)',
                routerAddress: address(governanceLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'56de96db',
                functionSignature: 'setState(uint8)',
                routerAddress: address(governanceLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'c36b9332',
                functionSignature: 'setTreasureAddress(address)',
                routerAddress: address(governanceLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'a5128317',
                functionSignature: 'updateMetadata()',
                routerAddress: address(governanceLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'5b61491f',
                functionSignature: 'whitelistApp(address,bool)',
                routerAddress: address(governanceLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'225b3752',
                functionSignature: 'whitelistSuperCommunityCreator(address,bool)',
                routerAddress: address(governanceLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'0ffb1d8b',
                functionSignature: 'whitelistToken(address,bool)',
                routerAddress: address(governanceLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'095ea7b3',
                functionSignature: 'approve(address,uint256)',
                routerAddress: address(profileLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'70a08231',
                functionSignature: 'balanceOf(address)',
                routerAddress: address(profileLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'42966c68',
                functionSignature: 'burn(uint256)',
                routerAddress: address(profileLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'8ec552dc',
                functionSignature: 'createProfile((string,bytes,uint256,bytes))',
                routerAddress: address(profileLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'081812fc',
                functionSignature: 'getApproved(uint256)',
                routerAddress: address(profileLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'2dc643d9',
                functionSignature: 'getFollowCondition(uint256)',
                routerAddress: address(profileLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'e3204d05',
                functionSignature: 'getFollowSBT(uint256)',
                routerAddress: address(profileLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'ec81d194',
                functionSignature: 'getHandle(uint256)',
                routerAddress: address(profileLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'f08f4f64',
                functionSignature: 'getProfile(uint256)',
                routerAddress: address(profileLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'4af1dc7a',
                functionSignature: 'getProfileIdByAddress(address)',
                routerAddress: address(profileLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'20fa728a',
                functionSignature: 'getProfileIdByHandle(string)',
                routerAddress: address(profileLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'e985e9c5',
                functionSignature: 'isApprovedForAll(address,address)',
                routerAddress: address(profileLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'06fdde03',
                functionSignature: 'name()',
                routerAddress: address(profileLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'7ecebe00',
                functionSignature: 'nonces(address)',
                routerAddress: address(profileLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'6352211e',
                functionSignature: 'ownerOf(uint256)',
                routerAddress: address(profileLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'42842e0e',
                functionSignature: 'safeTransferFrom(address,address,uint256)',
                routerAddress: address(profileLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'b88d4fde',
                functionSignature: 'safeTransferFrom(address,address,uint256,bytes)',
                routerAddress: address(profileLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'a22cb465',
                functionSignature: 'setApprovalForAll(address,bool)',
                routerAddress: address(profileLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'c05b3847',
                functionSignature: 'setFollowCondition(uint256,bytes)',
                routerAddress: address(profileLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'01ffc9a7',
                functionSignature: 'supportsInterface(bytes4)',
                routerAddress: address(profileLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'95d89b41',
                functionSignature: 'symbol()',
                routerAddress: address(profileLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'4f6ccce7',
                functionSignature: 'tokenByIndex(uint256)',
                routerAddress: address(profileLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'2f745c59',
                functionSignature: 'tokenOfOwnerByIndex(address,uint256)',
                routerAddress: address(profileLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'c87b56dd',
                functionSignature: 'tokenURI(uint256)',
                routerAddress: address(profileLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'18160ddd',
                functionSignature: 'totalSupply()',
                routerAddress: address(profileLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'23b872dd',
                functionSignature: 'transferFrom(address,address,uint256)',
                routerAddress: address(profileLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'b09c724c',
                functionSignature: 'batchFollow((uint256[],bytes[],uint256[],bytes))',
                routerAddress: address(relationLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'5a0f52f8',
                functionSignature: 'batchJoin((uint256[],bytes[],uint256[],bytes))',
                routerAddress: address(relationLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'42bb5d34',
                functionSignature: 'emitFollowSBTTransferEvent(uint256,uint256,address,address)',
                routerAddress: address(relationLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'310ac44b',
                functionSignature: 'emitJoinNFTTransferEvent(uint256,uint256,address,address)',
                routerAddress: address(relationLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'fec93e49',
                functionSignature: 'follow((uint256,bytes,bytes))',
                routerAddress: address(relationLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'54579157',
                functionSignature: 'getFollowSBTURI(uint256,uint256)',
                routerAddress: address(relationLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'bf72f81b',
                functionSignature: 'getJoinNFTURI(uint256,uint256)',
                routerAddress: address(relationLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'1130c42b',
                functionSignature: 'isFollow(uint256,address)',
                routerAddress: address(relationLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'082c49af',
                functionSignature: 'isJoin(uint256,address)',
                routerAddress: address(relationLogic)
            })
        );
        ospRouter.addRouter(
            IRouter.Router({
                functionSelector: hex'196e5c5b',
                functionSignature: 'join((uint256,bytes,bytes))',
                routerAddress: address(relationLogic)
            })
        );
        //addRouter
    }
}
