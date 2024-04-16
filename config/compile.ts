import { FunctionFragment } from '@ethersproject/abi';
import '@nomiclabs/hardhat-ethers';
import { ethers } from 'ethers';
import fs from 'fs';
import { task } from 'hardhat/config';
import path from 'path';
import { COMPILE_TASK_NAME } from './tasks';
import { getAddRouterCode, writeSetUpTestFile } from './forge-test-setup-code-generation';

//compile
task(COMPILE_TASK_NAME.COMPILE).setAction(async function (args, hre, runSuper) {
  await runSuper(args);
  await hre.run(COMPILE_TASK_NAME.FUN_SIG);
  await hre.run(COMPILE_TASK_NAME.EXPORT_ABI_OSP);
  await hre.run(COMPILE_TASK_NAME.OSP_CLIENT_ABI);
  console.log(`opensocial compile SUCCESS!`);
});
//compile ospClient
task(COMPILE_TASK_NAME.OSP_CLIENT_ABI, 'compile osp client abi').setAction(async (_, hre) => {
  try {
    // eslint-disable-next-line @typescript-eslint/no-var-requires
    const ospClient = require('../target/abis/core/logics/interfaces/OspClient.json');
    // eslint-disable-next-line @typescript-eslint/no-var-requires
    const ospEvents = require('../target/abis/libraries/OspEvents.json');
    ospClient.abi = [...ospClient.abi, ...ospEvents.abi];
    fs.writeFileSync(
      path.resolve(__dirname, '../target/abis/core/logics/interfaces/OspClient.json'),
      JSON.stringify(ospClient, null, 4),
      {
        encoding: 'utf-8',
        flag: 'w+',
      }
    );
  } catch (e) {
    console.log(`e`, e);
  }
});
//abi
task(COMPILE_TASK_NAME.EXPORT_ABI_OSP, 'export the abis of contracts').setAction(async (_, hre) => {
  try {
    const only = [
      'ERC721BurnableUpgradeable',
      'OspDataTypes',
      'OspErrors',
      'OspClient',
      'OspEvents',
      'plugins',
      'core/conditions/join',
      'core/conditions/community',
      'contracts/token/SlotNFT',
      'contracts/token/Token',
    ];
    const except = ['PluginBase', 'openzeppelin'];
    const fullNames = await hre.artifacts.getAllFullyQualifiedNames();
    let contracts = '';
    fullNames.forEach((fullName) => {
      if (only.length && !only.some((m) => fullName.match(m))) return;
      if (except.length && except.some((m) => fullName.match(m))) return;
      //contracts/core/CollectNFT.sol:CollectNFT
      const name = fullName.replace('contracts/', '').split('.sol')[0]; //core/CollectNFT.sol
      contracts = contracts + name + ',';
    });
    contracts = contracts.substring(0, contracts.lastIndexOf(','));
    await hre.run(COMPILE_TASK_NAME.EXPORT_ABI, {
      includes: contracts,
      clean: 'true',
    });
  } catch (e) {
    console.log(`e`, e);
  }
});

task(COMPILE_TASK_NAME.EXPORT_ABI, 'export the abis of contracts')
  .addParam('includes', 'the contract name to export', '')
  .addParam('clean', 'clean all abis before exporting', 'true')
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  .setAction(async ({ includes, clean }, _) => {
    try {
      const includeArray: string[] = includes.split(',');
      const folder = path.resolve(__dirname, `../target/abis/`);
      // check clean == true
      if (clean === 'true') {
        // delete all files under abis folder
        if (fs.existsSync(folder)) {
          fs.rmSync(folder, { recursive: true });
        }
      }
      includeArray.forEach((contractName) => {
        let contractRealName = contractName;
        if (contractName.indexOf('/') > -1) {
          contractRealName = contractName.substring(contractName.lastIndexOf('/') + 1);
        }
        const file = path.resolve(
          __dirname,
          `../target/artifacts/contracts/${contractName}.sol/${contractRealName}.json`
        );
        // console.log(file);
        const destFullPath = `./${contractName}.sol`;
        const destPath = destFullPath.substring(0, destFullPath.lastIndexOf('/'));
        const absoluteDestPath = path.resolve(folder, destPath);

        fs.mkdirSync(absoluteDestPath, { recursive: true });
        fs.copyFileSync(file, path.resolve(absoluteDestPath, `${contractRealName}.json`));
      });
      console.log(`abi exported successfully to abis folder SUCCESS`);
    } catch (e) {
      console.log(`e`, e);
    }
  });
//fun-sig
task(COMPILE_TASK_NAME.FUN_SIG, 'get function signature').setAction(async (_, hre) => {
  if (fs.existsSync(path.resolve(__dirname, `../target/fun-sig`))) {
    fs.rmSync(path.resolve(__dirname, `../target/fun-sig`), { recursive: true });
  }
  const fullNames = await hre.artifacts.getAllFullyQualifiedNames();
  const only = ['core/logics/interfaces'];
  const except = [];
  const funSigTempMap = new Map();
  for (let index = 0; index < fullNames.length; index++) {
    const fullName = fullNames[index];
    if (only.length && !only.some((m) => fullName.match(m))) continue;
    if (except.length && except.some((m) => fullName.match(m))) continue;
    const contractName = fullName.replace('contracts/', '').split('.sol')[0];
    let contractRealName = contractName;
    if (contractName.indexOf('/') > -1) {
      contractRealName = contractName.substring(contractName.lastIndexOf('/') + 1);
    }
    const filePath = path.resolve(
      __dirname,
      `../target/artifacts/contracts/${contractName}.sol/${contractRealName}.json`
    );
    const json = JSON.parse(fs.readFileSync(filePath).toString());

    const cInterface = new ethers.Contract('0x5FbDB2315678afecb367f032d93F642f64180aa3', json.abi)
      .interface;
    let funSigMap = '{';
    cInterface.fragments
      .filter((item) => item instanceof FunctionFragment)
      .forEach((item) => {
        const selector = cInterface.getSighash(item);
        funSigMap += '"' + item.format() + '"' + ':' + '"' + selector + '",';
        if (!fullName.match('OspClient')) {
          if (funSigTempMap.has(selector)) {
            throw `function signature already exists:${item.format()},selector:${selector},contractName:${contractName},conflict contractName:${funSigTempMap.get(
              selector
            )}`;
          } else {
            funSigTempMap.set(selector, contractName);
          }
        }
      });
    const destPath = contractName.substring(0, contractName.lastIndexOf('/'));
    const outPath = path.resolve(__dirname, `../target/fun-sig/${destPath}`);
    if (!fs.existsSync(outPath)) {
      fs.mkdirSync(outPath, { recursive: true });
    }
    fs.writeFileSync(
      `${outPath}/${contractRealName}.json`,
      JSON.stringify(
        JSON.parse(
          `${funSigMap.length == 1 ? funSigMap : funSigMap.substring(0, funSigMap.length - 1)}}`
        ),
        null,
        4
      ),
      {
        encoding: 'utf-8',
        flag: 'w+',
      }
    );
    const addPluginCode = getAddRouterCode();
    writeSetUpTestFile(addPluginCode);
  }
  console.log('generate logic function selector SUCCESS!');
});
