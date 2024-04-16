import '@nomiclabs/hardhat-ethers';
import fs from 'fs';
import { task } from 'hardhat/config';
import { ZERO_ADDRESS } from '../config/hardhat';
import { ospAddressConfig } from '../config/osp';
import { COMPILE_TASK_NAME, DEPLOY_TASK_NAME } from '../config/tasks';
import { CoinMintPlugin__factory, OspClient__factory } from '../target/typechain-types';
import { deployContract, isHardhatNetwork, waitForTx } from './helpers/utils';

task(DEPLOY_TASK_NAME.PLUGIN_DEPLOY, 'deploys the entire OpenSocial Protocol').setAction(
  async ({}, hre) => {
    await hre.run(COMPILE_TASK_NAME.COMPILE);
    // Note that the use of these signers is a placeholder and is not meant to be used in
    // production.
    const ethers = hre.ethers;
    const accounts = await ethers.getSigners();
    const deployer = accounts[0];
    const [governanceAddress, treasuryAddress, proxyAdminAddress] = isHardhatNetwork(hre)
      ? [accounts[1].address, accounts[2].address, deployer.address]
      : [
          process.env.GOVERNANCE_ADDRESS,
          process.env.TREASURY_ADDRESS,
          process.env.PROXY_ADMIN_ADDRESS,
        ];
    if (!(governanceAddress && treasuryAddress && proxyAdminAddress)) {
      throw 'ERROR: Configure GOVERNANCE_ADDRESS, TREASURY_ADDRESS, and PROXY_ADMIN_ADDRESS in the.env file';
    }

    const network = hre.network.name;

    const ospAddress = ospAddressConfig[network].ospRouter;

    const osp = OspClient__factory.connect(ospAddress, deployer);

    const coinMintPlugin = await deployContract(
      new CoinMintPlugin__factory(deployer).deploy(ospAddress)
    );

    await waitForTx(
      osp.setPlugin({
        pluginAddress: coinMintPlugin.address,
        isEnable: true,
        tokenAddress: ZERO_ADDRESS,
        amount: 0,
      })
    );

    const address = {
      coinMintPlugin: coinMintPlugin.address,
    };
    const json = JSON.stringify(address, null, 2);
    console.log(json);
    fs.writeFileSync(`target/plugin-addresses-${hre.network.name}.json`, json, 'utf-8');
  }
);
