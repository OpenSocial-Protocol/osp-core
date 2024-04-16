import { PopulatedTransaction } from 'ethers';
import { OspRouterImmutable } from '../../target/typechain-types';

export async function getAddRouterDataMulti(
  funSig: { [name: string]: string },
  address: string,
  router: OspRouterImmutable
): Promise<string[]> {
  const governanceLogicInitData: string[] = [];
  const entries = Object.entries(funSig);
  for (let index = 0; index < entries.length; index++) {
    const element = entries[index];
    const res: PopulatedTransaction = await router.populateTransaction.addRouter({
      functionSignature: element[0],
      functionSelector: element[1],
      routerAddress: address,
    });
    res?.data && governanceLogicInitData.push(res.data);
  }
  return governanceLogicInitData;
}

export async function getUpdateRouterDataMulti(
  funSig: { [name: string]: string },
  address: string,
  router: OspRouterImmutable
): Promise<string[]> {
  const governanceLogicInitData: string[] = [];
  const entries = Object.entries(funSig);
  for (let index = 0; index < entries.length; index++) {
    const element = entries[index];
    const res: PopulatedTransaction = await router.populateTransaction.updateRouter({
      functionSignature: element[0],
      functionSelector: element[1],
      routerAddress: address,
    });
    res?.data && governanceLogicInitData.push(res.data);
  }
  return governanceLogicInitData;
}

export async function getAllSelectors(funSig: { [name: string]: string }): Promise<string[]> {
  const allSelectors: string[] = [];
  const entries = Object.entries(funSig);
  for (let index = 0; index < entries.length; index++) {
    const element = entries[index];
    allSelectors.push(element[1]);
  }
  return allSelectors;
}
