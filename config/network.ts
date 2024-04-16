import { HARDHAT_CHAIN_ID } from './hardhat';
import { hardhatAccounts } from './hardhat-accounts';
export const local: Network = {
  chainId: HARDHAT_CHAIN_ID,
  url: 'http://127.0.0.1:8545/',
};
export const sepolia: Network = {
  chainId: 11155111,
  url: 'https://eth-sepolia.g.alchemy.com/v2/UJu10EBnVKSI-qO8tp4yarUqVAoNAcrV',
};
//beta network
export const mumbai: Network = {
  chainId: 80001,
  url: 'https://polygon-mumbai.g.alchemy.com/v2/DH4n-QvjWVu44OvUFRtIOAaOvzsu1U9B',
};
//prod network
//other
export interface Network {
  chainId: number;
  url: string;
}
export const getHardhatNetwork = (network: Network) => ({
  url: network.url,
  chainId: network.chainId,
  accounts: hardhatAccounts.map((value) => value.privateKey),
});
export function getRpcNetwork(network: Network) {
  return {
    url: network.url,
    chainId: network.chainId,
    accounts: process.env.DEPLOYER_PRIVATE_KEY
      ? [
          process.env.DEPLOYER_PRIVATE_KEY,
          process.env.GOVERNANCE_PRIVATE_KEY ? process.env.GOVERNANCE_PRIVATE_KEY : '',
        ]
      : hardhatAccounts.map((value) => value.privateKey),
  };
}
