import { task } from 'hardhat/config';
import {
  deployContract,
  getAddresses,
  getMulticall3,
  OspAddress,
  waitForTx,
} from './helpers/utils';
import { getDeployer } from './helpers/kms';
import {
  CommunityNFT__factory,
  ERC6551Account__factory,
  FixedFeeCommunityCond__factory,
  JoinNFT__factory,
  OspClient__factory,
  OspRouterImmutable__factory,
} from '../target/typechain-types';
import fs from 'fs';
import { Contract, ethers } from 'ethers';
import { APP_ADMIN, GOVERNANCE, OPERATION, STATE_ADMIN } from '../config/osp';

task('step1-0702-deploy')
  .addParam('env')
  .setAction(async ({ env }, hre) => {
    const deployer = await getDeployer(hre);
    await hre.run('deploy-fixed-fee-cond-create2', { env, whitelist: 'false' });
    const address: OspAddress = getAddresses(hre, env);
    const joinNFTImpl: Contract = await deployContract(
      new JoinNFT__factory(deployer).deploy(address.routerProxy)
    );
    address.joinNFTImpl = joinNFTImpl.address;
    console.log(`deployed joinNFTImpl at ${joinNFTImpl.address}`);
    const erc6551AccountImpl: Contract = await deployContract(
      new ERC6551Account__factory(deployer).deploy(address.routerProxy)
    );
    address.erc6551AccountImpl = erc6551AccountImpl.address;
    console.log(`deployed erc6551AccountImpl at ${erc6551AccountImpl.address}`);
    const communityNFT = await deployContract(
      new CommunityNFT__factory(deployer).deploy(address.routerProxy)
    );
    address.communityNFT = communityNFT.address;
    fs.writeFileSync(
      `addresses-${env}-${hre.network.name}.json`,
      JSON.stringify(address, null, 2),
      'utf-8'
    );
  });

task('step2-0702-setFixedFeeCondData')
  .addParam('start')
  .setAction(async ({ start }) => {
    const calldata = FixedFeeCommunityCond__factory.createInterface().encodeFunctionData(
      'setFixedFeeCondData',
      [
        {
          price1Letter: ethers.utils.parseEther('2.049'),
          price2Letter: ethers.utils.parseEther('0.257'),
          price3Letter: ethers.utils.parseEther('0.065'),
          price4Letter: ethers.utils.parseEther('0.017'),
          price5Letter: ethers.utils.parseEther('0.005'),
          price6Letter: ethers.utils.parseEther('0.003'),
          price7ToMoreLetter: ethers.utils.parseEther('0.001'),
          createStartTime: Number(start),
        },
      ]
    );
    console.log(`fixedFeeCommunityCond calldata is ${calldata}`);
  });

task('step3-0702-deployPresale')
  .addParam('env')
  .addParam('start')
  .setAction(async ({ env, start }, hre) => {
    await hre.run('deploy-presale-sig-cond', { env, start, whitelist: 'false' });
  });

task('step4-0702-updateRouter')
  .addParam('env')
  .setAction(async ({ env }, hre) => {
    await hre.run('update-router', { env, logic: 'community,profile,content,governance,relation' });
  });

//step5 safe setImpl
task('step5-0702-setImpl')
  .addParam('env')
  .setAction(async ({ env }, hre) => {
    const address: OspAddress = getAddresses(hre, env);
    const initData: string[] = [];
    initData.push(
      OspClient__factory.createInterface().encodeFunctionData('whitelistApp', [
        address.whitelistAddressCommunityCond!,
        false,
      ])
    );
    initData.push(
      OspClient__factory.createInterface().encodeFunctionData('whitelistApp', [
        address.fixedFeeCommunityCond!,
        true,
      ])
    );
    initData.push(
      OspClient__factory.createInterface().encodeFunctionData('whitelistApp', [
        address.presaleSigCommunityCond!,
        true,
      ])
    );
    const calldata = OspRouterImmutable__factory.createInterface().encodeFunctionData('multicall', [
      initData,
    ]);
    console.log(`router is ${address.routerProxy}, calldata is ${calldata}`);
  });

task('step6-0702-6551Update')
  .addParam('env')
  .setAction(async ({ env }, hre) => {
    const addresses = getAddresses(hre, env);
    // eslint-disable-next-line @typescript-eslint/ban-ts-comment
    // @ts-ignore
    const deployer = await getDeployer(hre);
    //update 6551 account
    const multicall3 = await getMulticall3(hre);
    const ospClient = OspClient__factory.connect(addresses.routerProxy, deployer);
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

//step7 safe whitelist WhitelistAddressCommunityCond FixedFeeCommunityCond PresaleSigCommunityCond
task('step00-0702-grantRole')
  .addParam('env')
  .addParam('address')
  .setAction(async ({ env, addr }, hre) => {
    const address = getAddresses(hre, env);
    const router = address?.routerProxy;
    const deployer = await getDeployer(hre);
    const ospClient = OspClient__factory.connect(address.routerProxy, deployer);
    const callDatas: string[] = [];
    callDatas.push(ospClient.interface.encodeFunctionData('grantRole', [GOVERNANCE, addr]));
    callDatas.push(ospClient.interface.encodeFunctionData('grantRole', [APP_ADMIN, addr]));
    callDatas.push(ospClient.interface.encodeFunctionData('grantRole', [STATE_ADMIN, addr]));
    callDatas.push(ospClient.interface.encodeFunctionData('grantRole', [OPERATION, addr]));
    await waitForTx(OspRouterImmutable__factory.connect(router, deployer).multicall(callDatas));
  });
