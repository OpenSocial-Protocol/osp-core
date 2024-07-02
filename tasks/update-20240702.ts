import { task } from 'hardhat/config';
import { deployContract, getAddresses, OspAddress } from './helpers/utils';
import { getDeployer } from './helpers/kms';
import {
  CommunityNFT__factory,
  ERC6551Account__factory,
  FixedFeeCommunityCond__factory,
  JoinNFT__factory,
} from '../target/typechain-types';
import fs from 'fs';
import { Contract, ethers } from 'ethers';

task('step1-0720-deploy')
  .addParam('env')
  .setAction(async ({ env }, hre) => {
    const address: OspAddress = getAddresses(hre, env);
    const deployer = await getDeployer(hre);
    await hre.run('deploy-fixed-fee-cond-create2', { env, whitelist: 'false' });
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

task('step2-0720-setFixedFeeCondData')
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

task('step3-0720-deployPresale')
  .addParam('env')
  .addParam('start')
  .setAction(async ({ env, start }, hre) => {
    await hre.run('deploy-presale-sig-cond', { env, start, whitelist: 'false' });
  });

task('step4-0720-updateRouter')
  .addParam('env')
  .setAction(async ({ env }, hre) => {
    await hre.run('update-router', { env, logic: 'community,profile,content,governance,relation' });
  });

//step5 safe setImpl

task('step6-0720-6551Update')
  .addParam('env')
  .setAction(async ({ env }, hre) => {
    await hre.run('6551-update', { env });
  });

//step7 safe whitelist WhitelistAddressCommunityCond FixedFeeCommunityCond PresaleSigCommunityCond
