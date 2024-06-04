import '@nomiclabs/hardhat-ethers';
import { ethers, Wallet } from 'ethers';
import { task } from 'hardhat/config';
import {
  CommunityNFT__factory,
  ERC6551Account__factory,
  JoinNFT__factory,
  OspClient__factory,
  OspRouterImmutable__factory,
  OspUniversalProxy__factory,
  WhitelistAddressCommunityCond__factory,
} from '../target/typechain-types';
import { deployContract, getAddresses, getMulticall3, waitForTx } from './helpers/utils';
import { getDeployer } from './helpers/kms';
import { getUpdateCallDatas } from './update-all-router';
import fs from 'fs';
import {
  APP_ADMIN,
  GOVERNANCE,
  nftMetaBaseUrl,
  OPERATION,
  ospRoles,
  STATE_ADMIN,
} from '../config/osp';

task('6551-update')
  .addParam('env')
  .setAction(async ({ env }, hre) => {
    const ospAddressConfig = getAddresses(hre, env);
    const ospAddress = ospAddressConfig.routerProxy;

    const ethers = hre.ethers;
    const deployer = new Wallet(<string>process.env.DEPLOYER_PRIVATE_KEY, ethers.provider);

    const osp = OspClient__factory.connect(ospAddress, deployer);
    const erc6551Account = await deployContract(
      new ERC6551Account__factory(deployer).deploy(ospAddress)
    );
    await waitForTx(osp.setERC6551AccountImpl(erc6551Account.address));
  });

task('uri-update')
  .addParam('env')
  .setAction(async ({ env }, hre) => {
    const ospAddressConfig = getAddresses(hre, env);
    const ospAddress = ospAddressConfig.routerProxy;
    const osp = OspClient__factory.connect(ospAddress, await getDeployer(hre));
    await waitForTx(osp.setBaseURI(`${nftMetaBaseUrl[env]}/${hre.network.config.chainId}/`));
  });

task('add-whitelist-community-creator')
  .addParam('env')
  .addParam('address')
  .addParam('amount')
  .setAction(async ({ env, address, amount }, hre) => {
    const addresses = getAddresses(hre, env);
    const whitelistAddressCommunityCond = WhitelistAddressCommunityCond__factory.connect(
      addresses.whitelistAddressCommunityCond,
      await getDeployer(hre)
    );
    await waitForTx(whitelistAddressCommunityCond.setMaxCreationNumber(address, amount));
  });

task('add-whitelist-app')
  .addParam('env')
  .addParam('address')
  .addParam('whitelist')
  .setAction(async ({ env, address, whitelist }, hre) => {
    const addresses = getAddresses(hre, env);
    const whitelistAddressCommunityCond = OspClient__factory.connect(
      addresses.routerProxy,
      await getDeployer(hre)
    );
    await waitForTx(whitelistAddressCommunityCond.whitelistApp(address, whitelist == 'true'));
  });

task('set-treasure-address')
  .addParam('env')
  .addParam('address')
  .setAction(async ({ env, address }, hre) => {
    const addresses = getAddresses(hre, env);
    const ospClient = OspClient__factory.connect(addresses.routerProxy, await getDeployer(hre));
    await waitForTx(ospClient.setTreasureAddress(address));
  });
task('update-osp-role')
  .addParam('env')
  .setAction(async ({ env }, hre) => {
    const addresses = getAddresses(hre, env);
    const deployer = await getDeployer(hre);
    const ospClient = OspClient__factory.connect(addresses?.routerProxy, deployer);
    const callDatas: string[] = [];
    const ospRoleConfig = ospRoles[hre.network.config.chainId as number];
    console.log(await ospClient.hasRole(APP_ADMIN, await deployer.getAddress()));
    console.log(await ospClient.hasRole(GOVERNANCE, await deployer.getAddress()));
    console.log(await ospClient.hasRole(OPERATION, await deployer.getAddress()));
    console.log(await ospClient.hasRole(STATE_ADMIN, await deployer.getAddress()));
    callDatas.push(
      ospClient.interface.encodeFunctionData('setTreasureAddress', [ospRoleConfig.treasureAddress])
    );
    ospRoleConfig.stateAdmin.forEach((address) => {
      callDatas.push(ospClient.interface.encodeFunctionData('grantRole', [STATE_ADMIN, address]));
    });
    ospRoleConfig.appAdmin.forEach((address) => {
      callDatas.push(ospClient.interface.encodeFunctionData('grantRole', [APP_ADMIN, address]));
    });
    ospRoleConfig.governance.forEach((address) => {
      callDatas.push(ospClient.interface.encodeFunctionData('grantRole', [GOVERNANCE, address]));
    });
    ospRoleConfig.operation.forEach((address) => {
      callDatas.push(ospClient.interface.encodeFunctionData('grantRole', [OPERATION, address]));
    });
    callDatas.push(
      ospClient.interface.encodeFunctionData('revokeRole', [APP_ADMIN, await deployer.getAddress()])
    );
    callDatas.push(
      ospClient.interface.encodeFunctionData('revokeRole', [
        GOVERNANCE,
        await deployer.getAddress(),
      ])
    );
    callDatas.push(
      ospClient.interface.encodeFunctionData('revokeRole', [OPERATION, await deployer.getAddress()])
    );
    callDatas.push(
      ospClient.interface.encodeFunctionData('revokeRole', [
        STATE_ADMIN,
        await deployer.getAddress(),
      ])
    );
    await waitForTx(
      OspRouterImmutable__factory.connect(addresses?.routerProxy, deployer).multicall(callDatas)
    );
    console.log(!(await ospClient.hasRole(APP_ADMIN, await deployer.getAddress())));
    console.log(!(await ospClient.hasRole(GOVERNANCE, await deployer.getAddress())));
    console.log(!(await ospClient.hasRole(OPERATION, await deployer.getAddress())));
    console.log(!(await ospClient.hasRole(STATE_ADMIN, await deployer.getAddress())));
    console.log(await ospClient.hasRole(STATE_ADMIN, ospRoleConfig.stateAdmin[0]));
    console.log(await ospClient.hasRole(APP_ADMIN, ospRoleConfig.appAdmin[0]));
    console.log(await ospClient.hasRole(GOVERNANCE, ospRoleConfig.governance[0]));
    console.log(await ospClient.hasRole(OPERATION, ospRoleConfig.operation[0]));
    console.log((await ospClient.getTreasureAddress()) == ospRoleConfig.treasureAddress);
  });

task('update-20240521')
  .addParam('env')
  .setAction(async ({ env }, hre) => {
    const addresses = getAddresses(hre, env);
    // eslint-disable-next-line @typescript-eslint/ban-ts-comment
    // @ts-ignore
    const deployer = await getDeployer(hre);

    // update community nft
    const communityNFTProxy = OspUniversalProxy__factory.connect(
      addresses?.communityNFTProxy,
      deployer
    );
    const communityNftImpl = await deployContract(
      new CommunityNFT__factory(deployer).deploy(addresses.routerProxy)
    );
    addresses.communityNFT = communityNftImpl.address;
    await waitForTx(communityNFTProxy.updateToAndCall(communityNftImpl.address, []));
    fs.writeFileSync(
      `addresses-${env}-${hre.network.name}.json`,
      JSON.stringify(addresses, null, 2)
    );

    //update core
    const ospClient = OspClient__factory.connect(addresses.routerProxy, deployer);
    const calldatas: Array<string> = [];
    const { ospAddressConfig, calldata: updateRouterCallDatas } = await getUpdateCallDatas(
      'content,community,governance,relation',
      hre,
      env
    );
    calldatas.push(...updateRouterCallDatas);

    //update 6551 account
    const erc6551Impl = await deployContract(
      new ERC6551Account__factory(deployer).deploy(addresses.routerProxy)
    );
    ospAddressConfig.erc6551AccountImpl = erc6551Impl.address;
    calldatas.push(
      ospClient.interface.encodeFunctionData('setERC6551AccountImpl', [erc6551Impl.address])
    );

    //update join nft impl
    const joinNFTImpl = await deployContract(
      new JoinNFT__factory(deployer).deploy(addresses.routerProxy)
    );
    ospAddressConfig.joinNFTImpl = joinNFTImpl.address;
    calldatas.push(ospClient.interface.encodeFunctionData('setJoinNFTImpl', [joinNFTImpl.address]));

    await waitForTx(
      OspRouterImmutable__factory.connect(addresses.routerProxy, deployer).multicall(calldatas)
    );
    fs.writeFileSync(
      `addresses-${env}-${hre.network.name}.json`,
      JSON.stringify(ospAddressConfig, null, 2)
    );

    //update 6551 account
    const multicall3 = await getMulticall3(hre);
    const communityNFT = CommunityNFT__factory.connect(addresses?.communityNFTProxy, deployer);
    const totalSupply = await communityNFT.totalSupply();
    const communityIds: Array<number> = [];
    for (let i = 1; i <= totalSupply.toNumber(); i++) {
      communityIds.push(i);
    }
    const community6551Account = (
      (
        await multicall3.callStatic.aggregate(
          communityIds.map((communityId) => ({
            target: addresses.routerProxy,
            callData: ospClient.interface.encodeFunctionData('getCommunityAccount(uint256)', [
              communityId,
            ]),
          }))
        )
      ).returnData as Array<string>
    ).map((bytes) => ethers.utils.defaultAbiCoder.decode(['address'], bytes)[0] as string);
    const updateCommunityIdCallDatas: Array<{
      target: string;
      callData: string;
      allowFailure: boolean;
    }> = [];
    for (const index in communityIds) {
      updateCommunityIdCallDatas.push({
        target: community6551Account[index],
        callData: ERC6551Account__factory.createInterface().encodeFunctionData('setCommunityId', [
          communityIds[index],
        ]),
        allowFailure: false,
      });
    }
    console.log(updateCommunityIdCallDatas);
    await waitForTx(multicall3.aggregate3(updateCommunityIdCallDatas));
  });

task('update-joinNFT')
  .addParam('env')
  .setAction(async ({ env }, hre) => {
    const addresses = getAddresses(hre, env);
    // eslint-disable-next-line @typescript-eslint/ban-ts-comment
    // @ts-ignore
    const deployer = await getDeployer(hre);
    const joinNFTImpl = await deployContract(
      new JoinNFT__factory(deployer).deploy(addresses.routerProxy)
    );
    await waitForTx(
      OspClient__factory.connect(addresses.routerProxy, deployer).setJoinNFTImpl(
        joinNFTImpl.address
      )
    );
    addresses.joinNFTImpl = joinNFTImpl.address;
    fs.writeFileSync(
      `addresses-${env}-${hre.network.name}.json`,
      JSON.stringify(addresses, null, 2)
    );
  });
