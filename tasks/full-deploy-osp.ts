import '@nomiclabs/hardhat-ethers';
import fs from 'fs';
import { task } from 'hardhat/config';
import {
  OPENSOCIAL_COMMUNITY_NAME,
  OPENSOCIAL_COMMUNITY_SYMBOL,
  OPENSOCIAL_SBT_NAME,
  OPENSOCIAL_SBT_SYMBOL,
  nftMetaBaseUrl,
  whitelistSlotNftList,
  whitelistTokenList,
} from '../config/osp';
import { COMPILE_TASK_NAME, DEPLOY_TASK_NAME } from '../config/tasks';
import {
  CommunityLogic__factory,
  CommunityNFT__factory,
  ContentLogic__factory,
  ERC20FeeJoinCond__factory,
  FollowSBT__factory,
  GovernanceLogic__factory,
  HoldTokenJoinCond__factory,
  JoinNFT__factory,
  LikeReaction__factory,
  NativeFeeJoinCond__factory,
  OspClient__factory,
  OspRouterImmutable,
  OspRouterImmutable__factory,
  OspUniversalProxy__factory,
  ProfileLogic__factory,
  RelationLogic__factory,
  SlotNFTCommunityCond__factory,
  VoteReaction__factory,
  OnlyMemberReferenceCond__factory,
} from '../target/typechain-types';
import { getAddRouterDataMulti } from './helpers/fun-sig';
import { ProtocolState, deployContract, waitForTx } from './helpers/utils';

task(DEPLOY_TASK_NAME.FULL_DEPLOY_OSP, 'deploys the entire OpenSocial Protocol').setAction(
  async (_, hre) => {
    await hre.run(COMPILE_TASK_NAME.COMPILE);
    // Note that the use of these signers is a placeholder and is not meant to be used in
    // production.
    const ethers = hre.ethers;
    const accounts = await ethers.getSigners();
    const deployer = accounts[0];
    const governanceAddress = deployer.address;

    console.log('\n\t-- Deploying Logic Implementation --');
    const governanceLogic = await deployContract(new GovernanceLogic__factory(deployer).deploy());
    const profileLogic = await deployContract(new ProfileLogic__factory(deployer).deploy());
    const contentLogic = await deployContract(new ContentLogic__factory(deployer).deploy());
    const relationLogic = await deployContract(new RelationLogic__factory(deployer).deploy());
    const communityLogic = await deployContract(new CommunityLogic__factory(deployer).deploy());

    console.log('\n\t-- Deploying OspRouterImmutable --');
    const router: OspRouterImmutable = <OspRouterImmutable>(
      await deployContract(new OspRouterImmutable__factory(deployer).deploy(governanceAddress))
    );

    console.log('\n\t-- Deploying Follow & Collect & Join NFT Implementations --');
    const FollowSBTImpl = await deployContract(
      new FollowSBT__factory(deployer).deploy(router.address)
    );
    const joinNFTImpl = await deployContract(new JoinNFT__factory(deployer).deploy(router.address));
    console.log('\n\t-- Deploying CommunityNFT --');
    const communityNFT = await deployContract(
      new CommunityNFT__factory(deployer).deploy(router.address)
    );

    console.log('\n\t-- Deploying CommunityNFT proxy --');
    const data = (
      await communityNFT.populateTransaction.initialize(
        OPENSOCIAL_COMMUNITY_NAME,
        OPENSOCIAL_COMMUNITY_SYMBOL
      )
    ).data;
    const communityNFTProxy = await deployContract(
      new OspUniversalProxy__factory(deployer).deploy(
        router.address,
        communityNFT.address,
        data ? data : []
      )
    );
    console.log('\n\t-- get GovernanceLogic router --');
    const governanceLogicFunSig: {
      [name: string]: string;
      // eslint-disable-next-line @typescript-eslint/no-var-requires
    } = require('../target/fun-sig/core/logics/interfaces/IGovernanceLogic.json');

    const governanceLogicInitData = await getAddRouterDataMulti(
      governanceLogicFunSig,
      governanceLogic.address,
      router
    );

    console.log('\n\t-- get ProfileLogic router --');
    const profileLogicFunSig: {
      [name: string]: string;
      // eslint-disable-next-line @typescript-eslint/no-var-requires
    } = require('../target/fun-sig/core/logics/interfaces/IProfileLogic.json');
    const profileLogicInitData = await getAddRouterDataMulti(
      profileLogicFunSig,
      profileLogic.address,
      router
    );

    console.log('\n\t-- get CommunityLogic router --');
    const communityLogicFunSig: {
      [name: string]: string;
      // eslint-disable-next-line @typescript-eslint/no-var-requires
    } = require('../target/fun-sig/core/logics/interfaces/ICommunityLogic.json');
    const communityLogicInitData = await getAddRouterDataMulti(
      communityLogicFunSig,
      communityLogic.address,
      router
    );

    console.log('\n\t-- get ContentLogic router --');
    const contentLogicFunSig: {
      [name: string]: string;
      // eslint-disable-next-line @typescript-eslint/no-var-requires
    } = require('../target/fun-sig/core/logics/interfaces/IContentLogic.json');
    const contentLogicInitData = await getAddRouterDataMulti(
      contentLogicFunSig,
      contentLogic.address,
      router
    );

    console.log('\n\t-- get RelationLogic router --');
    const relationLogicFunSig: {
      [name: string]: string;
      // eslint-disable-next-line @typescript-eslint/no-var-requires
    } = require('../target/fun-sig/core/logics/interfaces/IRelationLogic.json');
    const relationLogicInitData = await getAddRouterDataMulti(
      relationLogicFunSig,
      relationLogic.address,
      router
    );

    console.log('\n\t-- init Opensocial Protocol --');
    const initData = [
      ...governanceLogicInitData,
      ...profileLogicInitData,
      ...contentLogicInitData,
      ...relationLogicInitData,
      ...communityLogicInitData,
    ];
    const openSocial = OspClient__factory.connect(router.address, deployer);
    initData.push(
      openSocial.interface.encodeFunctionData('initialize', [
        OPENSOCIAL_SBT_NAME,
        OPENSOCIAL_SBT_SYMBOL,
        FollowSBTImpl.address,
        joinNFTImpl.address,
        communityNFTProxy.address,
      ])
    );

    console.log('\n\t-- setting Opensocial Protocol --');
    initData.push(
      openSocial.interface.encodeFunctionData('grantRole', [
        ethers.utils.keccak256(ethers.utils.toUtf8Bytes('AppAdmin')),
        deployer.address,
      ])
    );
    initData.push(
      openSocial.interface.encodeFunctionData('grantRole', [
        ethers.utils.keccak256(ethers.utils.toUtf8Bytes('Governance')),
        deployer.address,
      ])
    );

    //Deploy reaction
    console.log('\n\t-- Deploying reaction --');
    const likeReaction = await deployContract(
      new LikeReaction__factory(deployer).deploy(router.address)
    );

    const voteReaction = await deployContract(
      new VoteReaction__factory(deployer).deploy(router.address)
    );
    // Whitelist the join condition
    console.log('\n\t--Get Whitelisting Reaction CallData --');
    initData.push(
      openSocial.interface.encodeFunctionData('whitelistApp', [likeReaction.address, true])
    );
    initData.push(
      openSocial.interface.encodeFunctionData('whitelistApp', [voteReaction.address, true])
    );

    //Deploy join condition
    console.log('\n\t-- Deploying JoinCondition --');
    const holdTokenJoinCond = await deployContract(
      new HoldTokenJoinCond__factory(deployer).deploy(router.address)
    );
    const erc20FeeJoinCond = await deployContract(
      new ERC20FeeJoinCond__factory(deployer).deploy(router.address)
    );
    const nativeFeeJoinCond = await deployContract(
      new NativeFeeJoinCond__factory(deployer).deploy(router.address)
    );

    // Whitelist the join condition
    console.log('\n\t--Get Whitelisting Join Condition CallData --');
    initData.push(
      openSocial.interface.encodeFunctionData('whitelistApp', [holdTokenJoinCond.address, true])
    );
    initData.push(
      openSocial.interface.encodeFunctionData('whitelistApp', [erc20FeeJoinCond.address, true])
    );
    initData.push(
      openSocial.interface.encodeFunctionData('whitelistApp', [nativeFeeJoinCond.address, true])
    );

    //Deploy community condition
    console.log('\n\t-- Deploying communityCondition --');
    const slotNFTCommunityCond = await deployContract(
      new SlotNFTCommunityCond__factory(deployer).deploy(router.address)
    );

    // Whitelist the community condition
    console.log('\n\t--Get Whitelisting Community Condition CallData --');
    initData.push(
      openSocial.interface.encodeFunctionData('whitelistApp', [slotNFTCommunityCond.address, true])
    );

    // Deploy referenced condition
    console.log('\n\t-- Deploying referencedCondition --');
    const onlyMemberReferenceCond = await deployContract(
      new OnlyMemberReferenceCond__factory(deployer).deploy(router.address)
    );

    // Whitelist the referenced condition
    console.log('\n\t--Get Whitelisting Referenced Condition CallData --');
    initData.push(
      openSocial.interface.encodeFunctionData('whitelistApp', [
        onlyMemberReferenceCond.address,
        true,
      ])
    );

    console.log('\n\t--Set OpenSocial State --');
    initData.push(openSocial.interface.encodeFunctionData('setState', [ProtocolState.Unpaused]));

    whitelistTokenList[hre.ethers.provider.network.chainId].forEach((token) => {
      initData.push(openSocial.interface.encodeFunctionData('whitelistToken', [token, true]));
    });

    const baseUrl = nftMetaBaseUrl[hre.network.name];
    if (baseUrl) {
      initData.push(openSocial.interface.encodeFunctionData('setBaseURI', [baseUrl]));
    }

    // multiCall the whitelisting data
    console.log('\n\t--MultiCall init Data --');
    await waitForTx(router.connect(deployer).multicall(initData));

    const address = {
      routerProxy: router.address,
      //logic
      governanceLogic: governanceLogic.address,
      profileLogic: profileLogic.address,
      communityLogic: communityLogic.address,
      contentLogic: contentLogic.address,
      relationLogic: relationLogic.address,
      //impl
      followSBTImpl: FollowSBTImpl.address,
      joinNFTImpl: joinNFTImpl.address,
      communityNFT: communityNFT.address,
      //nftProxy
      communityNFTProxy: communityNFTProxy.address,
      //reaction
      likeReaction: likeReaction.address,
      voteReaction: voteReaction.address,
      //joinCondition
      holdTokenJoinCond: holdTokenJoinCond.address,
      erc20FeeJoinCond: erc20FeeJoinCond.address,
      nativeFeeJoinCond: nativeFeeJoinCond.address,
      //referencedCondition
      onlyMemberReferenceCond: onlyMemberReferenceCond.address,
      //condition
      slotNFTCommunityCond: slotNFTCommunityCond.address,
    };
    const whitelistSlotNfts = whitelistSlotNftList[hre.ethers.provider.network.chainId];
    await Promise.all(
      whitelistSlotNfts.map(async (slotNFT) => {
        await waitForTx(slotNFTCommunityCond.whitelistCommunitySlot(slotNFT, true));
      })
    );
    const json = JSON.stringify(address, null, 2);
    console.log(json);
    fs.writeFileSync(`addresses-${hre.network.name}.json`, json, 'utf-8');
  }
);
