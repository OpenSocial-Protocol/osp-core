import '@nomiclabs/hardhat-ethers';
import '@nomiclabs/hardhat-etherscan';
import '@typechain/hardhat';
import dotenv from 'dotenv';
import glob from 'glob';
import 'hardhat-gas-reporter';
import { HardhatUserConfig } from 'hardhat/types';
import path from 'path';
import 'solidity-docgen';
//config
import './config/compile';
import { HARDHAT_CHAIN_ID } from './config/hardhat';
import { hardhatAccounts } from './config/hardhat-accounts';
import {
  anvil,
  base,
  baseSepolia,
  beraTestnet,
  getRpcNetwork,
  polygonAmoy,
  sepolia,
  xLayer,
  xLayerTestnet,
} from './config/network';

dotenv.config();
if (!process.env.SKIP_LOAD) {
  glob.sync('./tasks/**/*.ts').forEach(function (file) {
    require(path.resolve(file));
  });
}

const config: HardhatUserConfig = {
  solidity: {
    compilers: [
      {
        version: '0.8.20',
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
            details: {
              yul: true,
            },
          },
        },
      },
    ],
  },
  networks: {
    // hardhat network
    hardhat: {
      chainId: HARDHAT_CHAIN_ID,
      throwOnTransactionFailures: true,
      throwOnCallFailures: true,
      accounts: hardhatAccounts.map(
        ({ privateKey, balance }: { privateKey: string; balance: string }) => ({
          privateKey,
          balance,
        })
      ),
      //fork beta or prod network
      // forking: {
      //   url: 'https://polygon-mumbai.g.alchemy.com/v2/DH4n-QvjWVu44OvUFRtIOAaOvzsu1U9B',
      //   blockNumber: 39375570,
      //   enabled: true,
      // },
      // forking: {
      //   url: 'https://eth-sepolia.g.alchemy.com/v2/UJu10EBnVKSI-qO8tp4yarUqVAoNAcrV',
      //   blockNumber: 4155150,
      //   enabled: true,
      // },
    },
    // hardhat network
    sepolia: getRpcNetwork(sepolia),
    baseSepolia: getRpcNetwork(baseSepolia),
    polygonAmoy: getRpcNetwork(polygonAmoy),
    anvil: getRpcNetwork(anvil),
    beraTestnet: getRpcNetwork(beraTestnet),
    xLayerTestnet: getRpcNetwork(xLayerTestnet),
    base: getRpcNetwork(base),
    xLayer: getRpcNetwork(xLayer),
  },
  paths: {
    cache: './target/cache',
    artifacts: './target/artifacts',
  },
  etherscan: {
    apiKey: {
      sepolia: process.env.ETHERSCAN_API_KEY!,
      baseSepolia: process.env.BASE_ETHERSCAN_API_KEY!,
      base: process.env.BASE_ETHERSCAN_API_KEY!,
    },
    customChains: [
      {
        network: 'baseSepolia',
        chainId: 84532,
        urls: {
          apiURL: 'https://api-sepolia.basescan.org/api',
          browserURL: 'https://sepolia.basescan.org',
        },
      },
      {
        network: 'base',
        chainId: 8453,
        urls: {
          apiURL: 'https://api.basescan.org/api',
          browserURL: 'https://basescan.org',
        },
      },
    ],
  },
  gasReporter: {
    enabled: !!process.env.REPORT_GAS,
  },
  docgen: {
    outputDir: './target/doc',
    pages: 'files',
  },
  typechain: {
    outDir: './target/typechain-types',
  },
};

export default config;
