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
export const baseSepolia: Network = {
  chainId: 84532,
  url: 'https://sepolia.base.org',
};
export const polygonAmoy: Network = {
  chainId: 80002,
  url: 'https://rpc-amoy.polygon.technology',
};

export const anvil: Network = {
  chainId: 31337,
  url: 'http://127.0.0.1:8545',
};

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
      ? [process.env.DEPLOYER_PRIVATE_KEY]
      : hardhatAccounts.map((value) => value.privateKey),
  };
}
