import { HARDHAT_CHAIN_ID } from './hardhat';
import { hardhatAccounts } from './hardhat-accounts';

export const local: Network = {
  chainId: HARDHAT_CHAIN_ID,
  url: 'http://127.0.0.1:8545/',
};
export const sepolia: Network = {
  chainId: 11155111,
  url: 'https://eth-sepolia.g.alchemy.com/v2/FIL_uMHp4ubZpAYa64DbQOTmqhOiqMRm',
};
export const baseSepolia: Network = {
  chainId: 84532,
  url: 'https://sepolia.base.org',
};
export const polygonAmoy: Network = {
  chainId: 80002,
  url: 'https://rpc-amoy.polygon.technology',
};
export const beraTestnet: Network = {
  url: 'https://smart-spring-river.bera-artio.quiknode.pro/5400cbe24581860e9a78ac84dd9e10663b4d4d8c/',
  chainId: 80085,
};
export const xLayerTestnet: Network = {
  url: 'https://testrpc.xlayer.tech',
  chainId: 195,
};
export const anvil: Network = {
  chainId: 84532,
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
