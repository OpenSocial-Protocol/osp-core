import fs from 'fs';
import path from 'path';
import prettier from 'prettier';
import 'prettier-plugin-solidity';

export function getAddRouterCode() {
  const funSigDir = path.resolve(__dirname, '../target/fun-sig/core/logics/interfaces');
  const names = fs.readdirSync(funSigDir);
  let addRouterCode = '';
  names
    .filter((item) => item.startsWith('I'))
    .forEach((fileName) => {
      const logicName =
        fileName.charAt(1).toLowerCase() + fileName.substring(2, fileName.length - 5);
      const json = JSON.parse(fs.readFileSync(funSigDir + '/' + fileName, 'utf8'));
      Object.keys(json).forEach((key) => {
        const addCode =
          'ospRouter.addRouter(IRouter.Router({functionSelector:hex"' +
          json[key].replace('0x', '') +
          '",functionSignature:"' +
          key +
          '",routerAddress:address(' +
          logicName +
          ')}));';
        addRouterCode = addRouterCode + addCode + '\n';
      });
    });
  return addRouterCode;
}
export function writeSetUpTestFile(addRouterCode: string) {
  const setUpSolFilePath = path.resolve(__dirname, '../test/foundry/OspTestSetUp.sol');
  let setUpSolFile = fs.readFileSync(setUpSolFilePath, 'utf-8');
  const split = setUpSolFile.split('//addRouter');
  setUpSolFile = split[0] + '//addRouter\n' + addRouterCode + '//addRouter\n' + split[2];
  setUpSolFile = prettier.format(setUpSolFile, {
    parser: 'solidity-parse',
    semi: true,
    singleQuote: true,
    printWidth: 100,
    tabWidth: 4,
  });
  fs.writeFileSync(setUpSolFilePath, setUpSolFile, { encoding: 'utf-8' });
}
