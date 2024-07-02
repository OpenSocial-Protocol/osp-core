import { task } from 'hardhat/config';
import { deployContract, getAddresses, OspAddress, waitForTx } from './helpers/utils';
import { getDeployer } from './helpers/kms';
import {
  FixedFeeCommunityCond,
  FixedFeeCommunityCond__factory,
  OspClient__factory,
  OspRouterImmutable,
  OspRouterImmutable__factory,
  PresaleSigCommunityCond__factory,
  WhitelistAddressCommunityCond__factory,
} from '../target/typechain-types';
import fs from 'fs';
import { create2_directory, deployCreate2, getDeployData } from './helpers/create2';
import { ethers } from 'ethers';

task('deploy-fixed-fee-cond-create2')
  .addParam('env')
  .addParam('whitelist')
  .setAction(async ({ env, whitelist }, hre) => {
    const address: OspAddress = getAddresses(hre, env);
    const deployer = await getDeployer(hre);
    const ospClient = OspClient__factory.connect(address.routerProxy, deployer);
    const create2AccountFileName = `${create2_directory}/osp-${env}.json`;
    const create2 = JSON.parse(fs.readFileSync(create2AccountFileName).toString());
    if (!create2.fixedFeeCommunityCond) {
      create2.fixedFeeCommunityCond = getDeployData(
        new FixedFeeCommunityCond__factory(deployer).getDeployTransaction(address.routerProxy)
      );
      const json = JSON.stringify(create2, null, 2);
      fs.writeFileSync(create2AccountFileName, json, 'utf-8');
      console.log(create2.fixedFeeCommunityCond);
    }
    await deployCreate2(create2.fixedFeeCommunityCond, deployer);
    address.fixedFeeCommunityCond = create2.fixedFeeCommunityCond.address;
    fs.writeFileSync(
      `addresses-${env}-${hre.network.name}.json`,
      JSON.stringify(address, null, 2),
      'utf-8'
    );
    if (whitelist == 'true') {
      await waitForTx(ospClient.whitelistApp(create2.fixedFeeCommunityCond.address, true));
    }
  });

task('init-fixed-fee-cond')
  .addParam('env')
  .addParam('start')
  .setAction(async ({ env, start }, hre) => {
    const address: OspAddress = getAddresses(hre, env);
    const deployer = await getDeployer(hre);
    const fixedFeeCond: FixedFeeCommunityCond = FixedFeeCommunityCond__factory.connect(
      // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
      address.fixedFeeCommunityCond!,
      deployer
    );
    await waitForTx(
      fixedFeeCond.setFixedFeeCondData({
        price1Letter: ethers.utils.parseEther('2.049'),
        price2Letter: ethers.utils.parseEther('0.257'),
        price3Letter: ethers.utils.parseEther('0.065'),
        price4Letter: ethers.utils.parseEther('0.017'),
        price5Letter: ethers.utils.parseEther('0.005'),
        price6Letter: ethers.utils.parseEther('0.003'),
        price7ToMoreLetter: ethers.utils.parseEther('0.001'),
        createStartTime: Number(start),
      })
    );
  });

task('redeploy-whitelist-cond-create2')
  .addParam('env')
  .setAction(async ({ env }, hre) => {
    const deployer = await getDeployer(hre);
    const addresses: OspAddress = getAddresses(hre, env);
    const ospClient = OspClient__factory.connect(addresses.routerProxy, deployer);
    const oldAddr = addresses.whitelistAddressCommunityCond;
    console.log(`old whitelist is ${oldAddr}`);
    const create2AccountFileName = `${create2_directory}/osp-${env}.json`;
    const create2 = JSON.parse(fs.readFileSync(create2AccountFileName).toString());
    const whitelistAddressCommunityCond = getDeployData(
      new WhitelistAddressCommunityCond__factory(deployer).getDeployTransaction(
        addresses.routerProxy
      )
    );
    if (create2.whitelistAddressCommunityCond.initCode == whitelistAddressCommunityCond.initCode) {
      throw new Error('same initCode');
    }
    create2.whitelistAddressCommunityCond = whitelistAddressCommunityCond;
    const json = JSON.stringify(create2, null, 2);
    fs.writeFileSync(create2AccountFileName, json, 'utf-8');
    addresses.whitelistAddressCommunityCond = whitelistAddressCommunityCond.address;
    fs.writeFileSync(
      `addresses-${env}-${hre.network.name}.json`,
      JSON.stringify(addresses, null, 2)
    );
    await deployCreate2(whitelistAddressCommunityCond, deployer);
    const initData = [
      ospClient.interface.encodeFunctionData('whitelistApp', [oldAddr, false]),
      ospClient.interface.encodeFunctionData('whitelistApp', [
        whitelistAddressCommunityCond.address,
        true,
      ]),
    ];
    const router: OspRouterImmutable = OspRouterImmutable__factory.connect(
      create2.ospRouter.address,
      deployer
    );
    await waitForTx(router.connect(deployer).multicall(initData));
  });

task('deploy-presale-sig-cond')
  .addParam('env')
  .addParam('start')
  .addParam('whitelist')
  .setAction(async ({ env, start, whitelist }, hre) => {
    console.log(`env is ${env}, start is ${start}, whitelist is ${whitelist}`);
    const signer: Record<string, string> = {
      dev: '0x511436a5199827dd1aa37462a680921a410d0947',
      beta: '0x511436a5199827dd1aa37462a680921a410d0947',
      pre: '0xee59c698401c9f7a949b8c1d3012c57349acb82d',
      prod: '0xca2771d61e2bde5c005cc44f6fab3845b2c180e3',
    };
    const address: OspAddress = getAddresses(hre, env);
    const deployer = await getDeployer(hre);
    // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
    const fixedFeeCommunityCond = address.fixedFeeCommunityCond!;
    console.log(`fixedFeeCommunityCond is ${fixedFeeCommunityCond}, ${address.routerProxy}`);
    const presaleSigCond = await deployContract(
      new PresaleSigCommunityCond__factory(deployer).deploy(
        address.routerProxy,
        fixedFeeCommunityCond,
        signer[env],
        Number(start)
      )
    );
    console.log('PresaleSigCommunityCond deployed at', presaleSigCond.address);
    // eslint-disable-next-line @typescript-eslint/ban-ts-comment
    // @ts-ignore
    address.presaleSigCommunityCond = presaleSigCond.address;
    fs.writeFileSync(
      `addresses-${env}-${hre.network.name}.json`,
      JSON.stringify(address, null, 2),
      'utf-8'
    );
    if (whitelist == 'true') {
      const ospClient = OspClient__factory.connect(address.routerProxy, deployer);
      await waitForTx(ospClient.whitelistApp(presaleSigCond.address, true));
      console.log(`whitelist presaleSigCond success`);
    }
  });
