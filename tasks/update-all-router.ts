import '@nomiclabs/hardhat-ethers';
import { Wallet } from 'ethers';
import fs from 'fs';
import { task } from 'hardhat/config';
import { COMPILE_TASK_NAME } from '../config/tasks';
import { OspClient__factory, OspRouterImmutable__factory } from '../target/typechain-types';
import { waitForTx } from './helpers/utils';

function getAddresses(hre) {
  return JSON.parse(fs.readFileSync(`addresses-${hre.network.name}.json`).toString());
}

function getFunSig(logicName: string) {
  const interfaceName = logicName.at(0)?.toUpperCase() + logicName.slice(1);
  return JSON.parse(
    fs
      .readFileSync(`./target/fun-sig/core/logics/interfaces/I${interfaceName}Logic.json`)
      .toString()
  );
}

task('update-router', 'update-router')
  .addParam('logic')
  .setAction(async ({ logic }, hre) => {
    const logicName = logic as string;
    console.log(`start update router ,logic is ${logicName}.`);

    const ethers = hre.ethers;
    const deployer = new Wallet(<string>process.env.DEPLOYER_PRIVATE_KEY, ethers.provider);
    const ospAddressConfig = getAddresses(hre);
    const ospAddress = ospAddressConfig.routerProxy;

    const osp = OspClient__factory.connect(ospAddress, deployer);
    const router = OspRouterImmutable__factory.connect(ospAddress, deployer);

    const allRouters = await router.getAllRouters();
    const logicRouters = await router.getAllFunctionsOfRouter(
      ospAddressConfig[`${logicName}Logic`]
    );

    console.log('logic old functions:');
    console.log(logicRouters);

    const funSig = getFunSig(logicName);

    const removeFun = new Set(logicRouters);
    const updateFun: Set<any> = new Set();
    const addFun: Set<any> = new Set();

    for (let key in funSig) {
      const selector = funSig[key];
      if (logicRouters.find((item) => item == selector)) {
        removeFun.delete(selector);
        updateFun.add({
          functionSignature: key,
          functionSelector: selector,
        });
      } else {
        addFun.add({
          functionSignature: key,
          functionSelector: selector,
        });
      }
    }
    console.log('remove functions:');
    console.log(removeFun);
    console.log('update functions:');
    console.log(updateFun);
    console.log('add functions:');
    console.log(addFun);

    const logicContract = await hre.ethers.deployContract(
      // @ts-ignore
      logicName.at(0).toUpperCase() + logicName.slice(1) + 'Logic'
    );
    console.log(`deploy logic contract: ${logicContract.address}`);

    const contractAddress = logicContract.address;

    const calldata: string[] = [];

    removeFun.forEach((selector) => {
      calldata.push(
        router.interface.encodeFunctionData('removeRouter', [
          selector,
          // @ts-ignore
          allRouters.find((item) => item.functionSelector == selector).functionSignature as string,
        ])
      );
    });

    updateFun.forEach((item) => {
      calldata.push(
        router.interface.encodeFunctionData('updateRouter', [
          {
            functionSignature: item.functionSignature,
            functionSelector: item.functionSelector,
            routerAddress: contractAddress,
          },
        ])
      );
    });

    addFun.forEach((item) => {
      calldata.push(
        router.interface.encodeFunctionData('addRouter', [
          {
            functionSignature: item.functionSignature,
            functionSelector: item.functionSelector,
            routerAddress: contractAddress,
          },
        ])
      );
    });
    console.log(calldata);

    await waitForTx(router.multicall(calldata));

    ospAddressConfig[`${logicName}Logic`] = contractAddress;
    fs.writeFileSync(
      `addresses-${hre.network.name}.json`,
      JSON.stringify(ospAddressConfig, null, 2)
    );
  });
