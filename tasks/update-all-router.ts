import '@nomiclabs/hardhat-ethers';
import fs from 'fs';
import { task } from 'hardhat/config';
import { OspRouterImmutable__factory } from '../target/typechain-types';
import { waitForTx } from './helpers/utils';
import { getDeployer } from './helpers/kms';

function getAddresses(hre, env) {
  return JSON.parse(fs.readFileSync(`addresses-${env}-${hre.network.name}.json`).toString());
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
  .addParam('env')
  .setAction(async ({ logic, env }, hre) => {
    const logicName = logic as string;
    console.log(`start update router ,logic is ${logicName}.`);

    const deployer = await getDeployer(hre);
    const ospAddressConfig = getAddresses(hre, env);
    const ospAddress = ospAddressConfig.routerProxy;

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

    for (const key in funSig) {
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
      logicName.at(0).toUpperCase() + logicName.slice(1) + 'Logic',
      deployer
    );
    await logicContract.deployed();
    console.log(`deploy logic contract: ${logicContract.address}`);

    const contractAddress = logicContract.address;

    const calldata: string[] = [];

    removeFun.forEach((selector) => {
      calldata.push(
        router.interface.encodeFunctionData('removeRouter', [
          selector,
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
      `addresses-${env}-${hre.network.name}.json`,
      JSON.stringify(ospAddressConfig, null, 2)
    );
  });
