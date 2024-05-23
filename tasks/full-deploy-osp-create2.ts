import '@nomiclabs/hardhat-ethers';
import fs from 'fs';
import { task } from 'hardhat/config';
import {
  APP_ADMIN,
  GOVERNANCE,
  nftMetaBaseUrl,
  OPENSOCIAL_COMMUNITY_NAME,
  OPENSOCIAL_COMMUNITY_SYMBOL,
  OPENSOCIAL_SBT_NAME,
  OPENSOCIAL_SBT_SYMBOL,
  OPERATION,
  STATE_ADMIN,
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
  GovernanceLogic,
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
import {
  deployContract,
  getAddresses,
  OspAddress,
  ProtocolState,
  waitForTx,
} from './helpers/utils';
import { Contract, Signer } from 'ethers';
import { deployCreate2, getDeployData } from './helpers/create2';
import { getDeployer } from './helpers/kms';

const create2_directory = `create2-osp`;

task('deploy_factory').setAction(async (_, hre) => {
  // https://eips.ethereum.org/EIPS/eip-2470
  await (
    await hre.ethers.provider.sendTransaction(
      '0xf9016c8085174876e8008303c4d88080b90154608060405234801561001057600080fd5b50610134806100206000396000f3fe6080604052348015600f57600080fd5b506004361060285760003560e01c80634af63f0214602d575b600080fd5b60cf60048036036040811015604157600080fd5b810190602081018135640100000000811115605b57600080fd5b820183602082011115606c57600080fd5b80359060200191846001830284011164010000000083111715608d57600080fd5b91908080601f016020809104026020016040519081016040528093929190818152602001838380828437600092019190915250929550509135925060eb915050565b604080516001600160a01b039092168252519081900360200190f35b6000818351602085016000f5939250505056fea26469706673582212206b44f8a82cb6b156bfcc3dc6aadd6df4eefd204bc928a4397fd15dacf6d5320564736f6c634300060200331b83247000822470'
    )
  ).wait();
});

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
    let address: OspAddress | null;

    address = getAddresses(hre, env);
    if (!address) {
      address = {
        routerProxy: router.address,
        communityNFT: communityNFT.address,
        communityNFTProxy: communityNFTProxy.address,
        voteReaction: voteReaction.address,
        holdTokenJoinCond: holdTokenJoinCond.address,
        erc20FeeJoinCond: erc20FeeJoinCond.address,
        nativeFeeJoinCond: nativeFeeJoinCond.address,
        onlyMemberReferenceCond: onlyMemberReferenceCond.address,
        slotNFTCommunityCond: slotNFTCommunityCond.address,
        whitelistAddressCommunityCond: whitelistAddressCommunityCond.address,
      };
    }

    try {
      console.log('\n\t-- Deploying Logic Implementation --');
      let governanceLogic: Contract;
      if (address.governanceLogic) {
        governanceLogic = GovernanceLogic__factory.connect(address.governanceLogic, deployer);
      } else {
        governanceLogic = await deployContract(new GovernanceLogic__factory(deployer).deploy());
        address.governanceLogic = governanceLogic.address;
      }
      let profileLogic: Contract;
      if (address.profileLogic) {
        profileLogic = ProfileLogic__factory.connect(address.profileLogic, deployer);
      } else {
        profileLogic = await deployContract(new ProfileLogic__factory(deployer).deploy());
        address.profileLogic = profileLogic.address;
      }
      let contentLogic: Contract;
      if (address.contentLogic) {
        contentLogic = ContentLogic__factory.connect(address.contentLogic, deployer);
      } else {
        contentLogic = await deployContract(new ContentLogic__factory(deployer).deploy());
        address.contentLogic = contentLogic.address;
      }
      let relationLogic: Contract;
      if (address.relationLogic) {
        relationLogic = RelationLogic__factory.connect(address.relationLogic, deployer);
      } else {
        relationLogic = await deployContract(new RelationLogic__factory(deployer).deploy());
        address.relationLogic = relationLogic.address;
      }
      let communityLogic: Contract;
      if (address.communityLogic) {
        communityLogic = CommunityLogic__factory.connect(address.communityLogic, deployer);
      } else {
        communityLogic = await deployContract(new CommunityLogic__factory(deployer).deploy());
        address.communityLogic = communityLogic.address;
      }

      console.log('\n\t-- Deploying Follow & Collect & Join NFT Implementations --');
      let followSBTImpl: Contract;
      if (address.followSBTImpl) {
        followSBTImpl = FollowSBT__factory.connect(address.followSBTImpl, deployer);
      } else {
        followSBTImpl = await deployContract(
          new FollowSBT__factory(deployer).deploy(router.address)
        );
        address.followSBTImpl = followSBTImpl.address;
      }
      let joinNFTImpl: Contract;
      if (address.joinNFTImpl) {
        joinNFTImpl = JoinNFT__factory.connect(address.joinNFTImpl, deployer);
      } else {
        joinNFTImpl = await deployContract(new JoinNFT__factory(deployer).deploy(router.address));
        address.joinNFTImpl = joinNFTImpl.address;
      }

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
          followSBTImpl.address,
          joinNFTImpl.address,
          communityNFTProxy.address,
        ])
      );

      console.log('\n\t-- setting Opensocial Protocol --');
      initData.push(
        openSocial.interface.encodeFunctionData('grantRole', [
          APP_ADMIN,
          await deployer.getAddress(),
        ])
      );
      initData.push(
        openSocial.interface.encodeFunctionData('grantRole', [
          GOVERNANCE,
          await deployer.getAddress(),
        ])
      );
      initData.push(
        openSocial.interface.encodeFunctionData('grantRole', [
          OPERATION,
          await deployer.getAddress(),
        ])
      );
      initData.push(
        openSocial.interface.encodeFunctionData('grantRole', [
          STATE_ADMIN,
          await deployer.getAddress(),
        ])
      );

      console.log('\n\t--Get Whitelisting Community Condition CallData --');
      initData.push(
        openSocial.interface.encodeFunctionData('whitelistApp', [
          slotNFTCommunityCond.address,
          true,
        ])
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
        initData.push(
          openSocial.interface.encodeFunctionData('setBaseURI', [
            `${baseUrl}/${hre.network.config.chainId}/`,
          ])
        );
      }
      console.log('\n\t--Set OpenSocial State --');
      initData.push(openSocial.interface.encodeFunctionData('setState', [ProtocolState.Unpaused]));

      // multiCall the whitelisting data
      console.log('\n\t--MultiCall init Data --');
      await waitForTx(router.connect(deployer).multicall(initData, { gasLimit: 21474836 }));
    } catch (e) {
      console.log(e);
    }
    const json = JSON.stringify(address, null, 2);
    console.log(json);
    fs.writeFileSync(`addresses-${env}-${hre.network.name}.json`, json, 'utf-8');
  });
