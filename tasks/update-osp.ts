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
    const ospClient = OspClient__factory.connect(addresses.routerProxy, await getDeployer(hre));
    await waitForTx(ospClient.whitelistApp(address, whitelist == 'true'));
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
    const ospRoleConfig = ospRoles[`${hre.network.config.chainId as number}-${env}`];
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

task('add-whitelist-token')
  .addParam('env')
  .addParam('address')
  .addParam('whitelist')
  .setAction(async ({ env, address, whitelist }, hre) => {
    const addresses = getAddresses(hre, env);
    const ospClient = OspClient__factory.connect(addresses.routerProxy, await getDeployer(hre));
    await waitForTx(ospClient.whitelistToken(address, whitelist == 'true'));
  });
