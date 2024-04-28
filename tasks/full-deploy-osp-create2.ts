import '@nomiclabs/hardhat-ethers';
import fs from 'fs';
import { task } from 'hardhat/config';
import {
  nftMetaBaseUrl,
  OPENSOCIAL_COMMUNITY_NAME,
  OPENSOCIAL_COMMUNITY_SYMBOL,
  OPENSOCIAL_SBT_NAME,
  OPENSOCIAL_SBT_SYMBOL,
  whitelistTokenList,
} from '../config/osp';
import { COMPILE_TASK_NAME, DEPLOY_TASK_NAME } from '../config/tasks';
import {
  CommunityLogic__factory,
  CommunityNFT,
  CommunityNFT__factory,
  ContentLogic__factory,
  ERC20FeeJoinCond__factory,
  FollowSBT__factory,
  GovernanceLogic__factory,
  HoldTokenJoinCond__factory,
  JoinNFT__factory,
  NativeFeeJoinCond__factory,
  OnlyMemberReferenceCond__factory,
  OspClient__factory,
  OspRouterImmutable,
  OspRouterImmutable__factory,
  OspUniversalProxy__factory,
  ProfileLogic__factory,
  RelationLogic__factory,
  SlotNFTCommunityCond__factory,
  VoteReaction__factory,
  WhitelistAddressCommunityCond__factory,
} from '../target/typechain-types';
import { getAddRouterDataMulti } from './helpers/fun-sig';
import { deployContract, ProtocolState, waitForTx } from './helpers/utils';
import { Signer } from 'ethers';
import { deployCreate2, getDeployData } from './helpers/create2';
import { getDeployer } from './helpers/kms';

const create2_directory = `create2-osp`;

task(DEPLOY_TASK_NAME.DEPLOY_OSP_CREATE2, 'deploys the entire OpenSocial Protocol')
  .addParam('env')
  .setAction(async ({ env }, hre) => {
    await hre.run(COMPILE_TASK_NAME.COMPILE);

    const create2AccountFileName = `${create2_directory}/osp-${env}.json`;
    const deployer: Signer = await getDeployer(hre);
    console.log(`deployer address: ${await deployer.getAddress()}`);
    const ethers = hre.ethers;
    const routerAdmin = await deployer.getAddress();

    if (!fs.existsSync(create2_directory)) {
      fs.mkdirSync(create2_directory);
    }

    if (!fs.existsSync(create2AccountFileName)) {
      const ospRouterImmutableDeployData = getDeployData(
        new OspRouterImmutable__factory(deployer).getDeployTransaction(routerAdmin)
      );
      const communityNFTProxyData = getDeployData(
        new CommunityNFT__factory(deployer).getDeployTransaction(
          ospRouterImmutableDeployData.address
        )
      );
      const create2 = {
        ospRouter: ospRouterImmutableDeployData,
        communityNFT: communityNFTProxyData,
        communityNFTProxy: getDeployData(
          new OspUniversalProxy__factory(deployer).getDeployTransaction(
            ospRouterImmutableDeployData.address,
            communityNFTProxyData.address,
            CommunityNFT__factory.createInterface().encodeFunctionData('initialize', [
              OPENSOCIAL_COMMUNITY_NAME,
              OPENSOCIAL_COMMUNITY_SYMBOL,
            ])
          )
        ),
        slotNFTCommunityCond: getDeployData(
          new SlotNFTCommunityCond__factory(deployer).getDeployTransaction(
            ospRouterImmutableDeployData.address
          )
        ),
        whitelistAddressCommunityCond: getDeployData(
          new WhitelistAddressCommunityCond__factory(deployer).getDeployTransaction(
            ospRouterImmutableDeployData.address
          )
        ),
        erc20FeeJoinCond: getDeployData(
          new ERC20FeeJoinCond__factory(deployer).getDeployTransaction(
            ospRouterImmutableDeployData.address
          )
        ),
        holdTokenJoinCond: getDeployData(
          new HoldTokenJoinCond__factory(deployer).getDeployTransaction(
            ospRouterImmutableDeployData.address
          )
        ),
        nativeFeeJoinCond: getDeployData(
          new NativeFeeJoinCond__factory(deployer).getDeployTransaction(
            ospRouterImmutableDeployData.address
          )
        ),
        onlyMemberReferenceCond: getDeployData(
          new OnlyMemberReferenceCond__factory(deployer).getDeployTransaction(
            ospRouterImmutableDeployData.address
          )
        ),
        voteReaction: getDeployData(
          new VoteReaction__factory(deployer).getDeployTransaction(
            ospRouterImmutableDeployData.address
          )
        ),
      };
      const json = JSON.stringify(create2, null, 2);
      fs.writeFileSync(create2AccountFileName, json, 'utf-8');
    }

    console.log('\n\t-- Deploying OspRouterImmutable --');
    const create2 = JSON.parse(fs.readFileSync(create2AccountFileName).toString());
    console.log(create2);
    await deployCreate2(create2.ospRouter, deployer);
    const router: OspRouterImmutable = OspRouterImmutable__factory.connect(
      create2.ospRouter.address,
      deployer
    );
    console.log('\n\t-- Deploying CommunityNFT --');
    await deployCreate2(create2.communityNFT, deployer);
    await deployCreate2(create2.communityNFTProxy, deployer);
    const communityNFT: CommunityNFT = CommunityNFT__factory.connect(
      create2.communityNFT.address,
      deployer
    );
    const communityNFTProxy = OspUniversalProxy__factory.connect(
      create2.communityNFTProxy.address,
      deployer
    );
    console.log('\n\t-- Deploying communityCondition --');
    await deployCreate2(create2.whitelistAddressCommunityCond, deployer);
    const whitelistAddressCommunityCond = WhitelistAddressCommunityCond__factory.connect(
      create2.whitelistAddressCommunityCond.address,
      deployer
    );
    await deployCreate2(create2.slotNFTCommunityCond, deployer);
    const slotNFTCommunityCond = SlotNFTCommunityCond__factory.connect(
      create2.slotNFTCommunityCond.address,
      deployer
    );
    console.log('\n\t-- Deploying JoinCondition --');
    await deployCreate2(create2.holdTokenJoinCond, deployer);
    await deployCreate2(create2.erc20FeeJoinCond, deployer);
    await deployCreate2(create2.nativeFeeJoinCond, deployer);
    const holdTokenJoinCond = HoldTokenJoinCond__factory.connect(
      create2.holdTokenJoinCond.address,
      deployer
    );
    const erc20FeeJoinCond = ERC20FeeJoinCond__factory.connect(
      create2.erc20FeeJoinCond.address,
      deployer
    );
    const nativeFeeJoinCond = NativeFeeJoinCond__factory.connect(
      create2.nativeFeeJoinCond.address,
      deployer
    );
    console.log('\n\t-- Deploying referencedCondition --');
    await deployCreate2(create2.onlyMemberReferenceCond, deployer);
    const onlyMemberReferenceCond = OnlyMemberReferenceCond__factory.connect(
      create2.onlyMemberReferenceCond.address,
      deployer
    );
    console.log('\n\t-- Deploying reaction --');
    await deployCreate2(create2.voteReaction, deployer);
    const voteReaction = VoteReaction__factory.connect(create2.voteReaction.address, deployer);

    console.log('\n\t-- Deploying Logic Implementation --');
    const governanceLogic = await deployContract(new GovernanceLogic__factory(deployer).deploy());
    const profileLogic = await deployContract(new ProfileLogic__factory(deployer).deploy());
    const contentLogic = await deployContract(new ContentLogic__factory(deployer).deploy());
    const relationLogic = await deployContract(new RelationLogic__factory(deployer).deploy());
    const communityLogic = await deployContract(new CommunityLogic__factory(deployer).deploy());

    console.log('\n\t-- Deploying Follow & Collect & Join NFT Implementations --');
    const FollowSBTImpl = await deployContract(
      new FollowSBT__factory(deployer).deploy(router.address)
    );
    const joinNFTImpl = await deployContract(new JoinNFT__factory(deployer).deploy(router.address));

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
        ethers.utils.keccak256(ethers.utils.toUtf8Bytes('APP_ADMIN')),
        await deployer.getAddress(),
      ])
    );
    initData.push(
      openSocial.interface.encodeFunctionData('grantRole', [
        ethers.utils.keccak256(ethers.utils.toUtf8Bytes('GOVERNANCE')),
        await deployer.getAddress(),
      ])
    );
    initData.push(
      openSocial.interface.encodeFunctionData('grantRole', [
        ethers.utils.keccak256(ethers.utils.toUtf8Bytes('OPERATION')),
        await deployer.getAddress(),
      ])
    );
    initData.push(
      openSocial.interface.encodeFunctionData('grantRole', [
        ethers.utils.keccak256(ethers.utils.toUtf8Bytes('STATE_ADMIN')),
        await deployer.getAddress(),
      ])
    );

    console.log('\n\t--Get Whitelisting Community Condition CallData --');
    initData.push(
      openSocial.interface.encodeFunctionData('whitelistApp', [slotNFTCommunityCond.address, true])
    );
    initData.push(
      openSocial.interface.encodeFunctionData('whitelistApp', [
        whitelistAddressCommunityCond.address,
        true,
      ])
    );
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
    console.log('\n\t--Get Whitelisting Referenced Condition CallData --');
    initData.push(
      openSocial.interface.encodeFunctionData('whitelistApp', [
        onlyMemberReferenceCond.address,
        true,
      ])
    );
    console.log('\n\t--Get Whitelisting Reaction CallData --');
    initData.push(
      openSocial.interface.encodeFunctionData('whitelistApp', [voteReaction.address, true])
    );

    whitelistTokenList[hre.ethers.provider.network.chainId]?.forEach((token) => {
      initData.push(openSocial.interface.encodeFunctionData('whitelistToken', [token, true]));
    });

    const baseUrl = nftMetaBaseUrl[env];
    if (baseUrl) {
      initData.push(openSocial.interface.encodeFunctionData('setBaseURI', [baseUrl]));
    }

    console.log('\n\t--Set OpenSocial State --');
    initData.push(openSocial.interface.encodeFunctionData('setState', [ProtocolState.Unpaused]));

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
      voteReaction: voteReaction.address,
      //joinCondition
      holdTokenJoinCond: holdTokenJoinCond.address,
      erc20FeeJoinCond: erc20FeeJoinCond.address,
      nativeFeeJoinCond: nativeFeeJoinCond.address,
      //referencedCondition
      onlyMemberReferenceCond: onlyMemberReferenceCond.address,
      //condition
      slotNFTCommunityCond: slotNFTCommunityCond.address,
      whitelistAddressCommunityCond: whitelistAddressCommunityCond.address,
    };
    const json = JSON.stringify(address, null, 2);
    console.log(json);
    fs.writeFileSync(`addresses-${env}-${hre.network.name}.json`, json, 'utf-8');
  });
