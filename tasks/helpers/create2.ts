import { execSync } from 'child_process';
import { BytesLike, ethers, Signer } from 'ethers';
import { hexlify } from 'ethers/lib/utils';
import { TransactionReceipt, TransactionResponse } from '@ethersproject/providers';
import { address } from 'hardhat/internal/core/config/config-validation';

const create2_abi = [
  {
    inputs: [
      { internalType: 'bytes', name: '_initCode', type: 'bytes' },
      { internalType: 'bytes32', name: '_salt', type: 'bytes32' },
    ],
    name: 'deploy',
    outputs: [{ internalType: 'address payable', name: 'createdContract', type: 'address' }],
    stateMutability: 'nonpayable',
    type: 'function',
  },
];
const create2_factory_address = '0xce0042b868300000d44a59004da54a005ffdcf9f';
export function getCreate2Factory(signer?: Signer) {
  return new ethers.Contract(create2_factory_address, create2_abi, signer);
}

export function getDeployData(tx: { data?: BytesLike }): {
  initCode: string;
  salt: string;
  address: string;
} {
  if (tx.data == null) {
    throw new Error('data is null');
  }
  const initCode = ethers.utils.hexlify(tx.data);
  const command = `cast create2 --starts-with 000000 -i ${initCode}  --deployer ${create2_factory_address}`;
  const execRes = new TextDecoder().decode(execSync(command));
  const getFromRes = (name: string): string => {
    const res = execRes.match(`${name}:.*?\n`)?.[0].replace(`${name}: `, '').replace('\n', '');
    if (!res) {
      throw new Error('cast not install');
    }
    return res;
  };
  console.log(execRes);
  return {
    initCode,
    salt: hexlify(ethers.BigNumber.from(getFromRes('Salt').split(' (')[0])),
    address: getFromRes('Address'),
  };
}

export async function waitForTx(
  tx: Promise<TransactionResponse> | TransactionResponse
): Promise<TransactionReceipt> {
  return await (await tx).wait();
}

export const create2Factory = getCreate2Factory();
export const deployCreate2 = async (
  params: { initCode: string; salt: string; address: string },
  deployer: Signer
) => {
  const code = await deployer.provider?.getCode(params.address);
  if (code && code != '0x') {
    return;
  }
  const calldata = create2Factory.interface.encodeFunctionData('deploy', [
    params.initCode,
    ethers.utils.hexZeroPad(params.salt, 32),
  ]);
  const tx = { to: create2Factory.address, data: calldata };
  await waitForTx(deployer.sendTransaction({ ...tx, gasLimit: 9000000 }));
  const code2 = await deployer.provider?.getCode(params.address);
  if (!code2 || code2 == '0x') {
    throw new Error('deploy failed');
  }
};
