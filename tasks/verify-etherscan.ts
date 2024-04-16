// import '@nomiclabs/hardhat-ethers';
// import { task } from 'hardhat/config';
// import { DEPLOY_TASK_NAME } from '../config/tasks';
// import { isHardhatNetwork, verify } from './helpers/utils';

// task(DEPLOY_TASK_NAME.VERIFY_OSP, 'deploys the entire OpenSocial Protocol').setAction(
//   async ({}, hre) => {
//     const ethers = hre.ethers;
//     const accounts = await ethers.getSigners();
//     const deployer = accounts[0];
//     const [governanceAddress, treasuryAddress, proxyAdminAddress] = isHardhatNetwork(hre)
//       ? [accounts[1].address, accounts[2].address, deployer.address]
//       : [
//           process.env.GOVERNANCE_ADDRESS,
//           process.env.TREASURY_ADDRESS,
//           process.env.PROXY_ADMIN_ADDRESS,
//         ];
//     if (!(governanceAddress && treasuryAddress && proxyAdminAddress)) {
//       throw 'ERROR: Configure GOVERNANCE_ADDRESS, TREASURY_ADDRESS, and PROXY_ADMIN_ADDRESS in the.env file';
//     }
//     const address: {
//       [name: string]: string;
//     } = require(`../target/addresses-${hre.network.name}.json`);
//     console.log(address);
//     const routerAddress = address['router proxy'];
//     const moduleGlobalsAddress = address['module globals'];

//     //0x8Bb3f5E126005bC586c375930de2E4E4A8705Fb4
//     await verify(
//       '0x84101Cb956850bB156899228c976282454e6A3d8',
//       ['0x4a676B1dEDE3c48FFfd13105125A4d8eCC0E54F4'],
//       'contracts/core/JoinNFT.sol:JoinNFT'
//     );
//     // // moduleGlobals
//     // await verify(
//     //   moduleGlobalsAddress,
//     //   [
//     //     deployer.address,
//     //     treasuryAddress,
//     //     TREASURY_FEE_BPS
//     //   ],
//     //   '/contracts/core/modules/ModuleGlobals.sol:ModuleGlobals'
//     // );

//     // // all logics
//     // await verify(
//     //   address['governance logic'],
//     //   [],
//     //   '/contracts/core/logics/GovernanceLogic.sol:GovernanceLogic'
//     // )

//     // await verify(
//     //   address['profile logic'],
//     //   [],
//     //   '/contracts/core/logics/ProfileLogic.sol:ProfileLogic'
//     // )

//     // await verify(
//     //   address['content logic'],
//     //   [],
//     //   '/contracts/core/logics/PublicationLogic.sol:PublicationLogic'
//     // )

//     // await verify(
//     //   address['reaction logic'],
//     //   [],
//     //   '/contracts/core/logics/ReactionLogic.sol:ReactionLogic'
//     // )

//     // await verify(
//     //   address['relation logic'],
//     //   [],
//     //   '/contracts/core/logics/RelationLogic.sol:RelationLogic'
//     // )

//     // await verify(
//     //   address['community logic'],
//     //   [],
//     //   '/contracts/core/logics/CommunityLogic.sol:CommunityLogic'
//     // )

//     // // router
//     // await verify(
//     //   routerAddress,
//     //   [
//     //     deployer.address,
//     //     treasuryAddress,
//     //     TREASURY_FEE_BPS
//     //   ],
//     //   'contracts/upgradeability/OspRouterImmutable.sol:OspRouterImmutable'
//     // );

//     // // folowSBT & collectNFT & joinNFT
//     // await verify(
//     //   address['follow SBT impl'],
//     //   [routerAddress],
//     //   'contracts/core/modules/FollowSBT.sol:FollowSBT'
//     // )

//     // await verify(
//     //   address['collect NFT impl'],
//     //   [routerAddress],
//     //   'contracts/core/modules/CollectNFT.sol:CollectNFT'
//     // )

//     // await verify(
//     //   address['join NFT impl'],
//     //   [routerAddress],
//     //   'contracts/core/modules/JoinNFT.sol:JoinNFT'
//     // )

//     // // communityNFT
//     // await verify(
//     //   address['community NFT'],
//     //   [routerAddress],
//     //   'contracts/core/modules/CommunityNFT.sol:CommunityNFT'
//     // )

//     // await verify(
//     //   address['currency'],
//     //   [],
//     //   'contracts/mocks/Currency.sol:Currency'
//     // )

//     // // collect module
//     // await verify(
//     //   address['fee collect module'],
//     //   [],
//     //   'contracts/core/modules/collect/FeeCollectModule.sol:FeeCollectModule'
//     // )

//     // await verify(
//     //   address['limited fee collect module'],
//     //   [routerAddress, moduleGlobalsAddress],
//     //   'contracts/core/modules/collect/LimitedFeeCollectModule.sol:LimitedFeeCollectModule'
//     // )

//     // await verify(
//     //   address['timed fee collect module'],
//     //   [routerAddress, moduleGlobalsAddress],
//     //   'contracts/core/modules/collect/TimedFeeCollectModule.sol:TimedFeeCollectModule'
//     // )

//     // await verify(
//     //   address['limited timed fee collect module'],
//     //   [routerAddress, moduleGlobalsAddress],
//     //   'contracts/core/modules/collect/LimitedTimedFeeCollectModule.sol:LimitedTimedFeeCollectModule'
//     // )

//     // await verify(
//     //   address['revert collect module'],
//     //   [],
//     //   'contracts/core/modules/collect/RevertCollectModule.sol:RevertCollectModule'
//     // )

//     // await verify(
//     //   address['free collect module'],
//     //   [routerAddress],
//     //   'contracts/core/modules/collect/FreeCollectModule.sol:FreeCollectModule'
//     // )
//     // // follow module
//     // await verify(
//     //   address['fee follow module'],
//     //   [routerAddress, moduleGlobalsAddress],
//     //   'contracts/core/modules/follow/FeeFollowModule.sol:FeeFollowModule'
//     // )

//     // await verify(
//     //   address['profile follow module'],
//     //   [routerAddress],
//     //   'contracts/core/modules/follow/ProfileFollowModule.sol:ProfileFollowModule'
//     // )

//     // await verify(
//     //   address['revert follow module'],
//     //   [routerAddress],
//     //   'contracts/core/modules/follow/RevertFollowModule.sol:RevertFollowModule'
//     // )

//     // await verify(
//     //   address['approval follow module'],
//     //   [routerAddress],
//     //   'contracts/core/modules/follow/ApprovalFollowModule.sol:ApprovalFollowModule'
//     // )

//     // // reference module
//     // await verify(
//     //   address['follower only reference module'],
//     //   [routerAddress],
//     //   'contracts/core/modules/reference/FollowerOnlyReferenceModule.sol:FollowerOnlyReferenceModule'
//     // )

//     // // join module
//     // await verify(
//     //   address['fee join module'],
//     //   [routerAddress, moduleGlobalsAddress],
//     //   'contracts/core/modules/join/FeeJoinModule.sol:FeeJoinModule'
//     // )

//     // // community condition
//     // await verify(
//     //   address['slot NFT condition'],
//     //   [routerAddress],
//     //   'contracts/core/conditions/SlotNFTCondition.sol:SlotNFTCondition'
//     // )

//     // await verify(
//     //   address['whitelist address condition'],
//     //   [routerAddress],
//     //   'contracts/core/conditions/WhitelistAddressCondition.sol:WhitelistAddressCondition'
//     // )

//     // // mock NFT
//     // await verify(
//     //   address['slot NFT'],
//     //   [routerAddress],
//     //   'contracts/mocks/MockNFTBase.sol:MockNFTBase'
//     // )
//   }
// );
