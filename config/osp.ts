//config
import { ethers } from 'ethers';

const OPENSOCIAL_SBT_NAME = 'OpenSocial Protocol Profile';
const OPENSOCIAL_SBT_SYMBOL = 'OSPP';
const OPENSOCIAL_COMMUNITY_NAME = 'OpenSocial Protocol Community';
const OPENSOCIAL_COMMUNITY_SYMBOL = 'OSPC';

export function getProfileNFTName(env: string): string {
  let name = OPENSOCIAL_SBT_NAME;
  if (env == 'pre') {
    name = 'Trex Protocol Profile';
  }
  console.log(`Profile NFT Name: ${name}`);
  return name;
}
export function getProfileNFTSymbol(env: string): string {
  let symbol = OPENSOCIAL_SBT_SYMBOL;
  if (env == 'pre') {
    symbol = 'TPP';
  }
  console.log(`Profile NFT Symbol: ${symbol}`);
  return symbol;
}
export function getCommunityNFTName(env: string): string {
  let name = OPENSOCIAL_COMMUNITY_NAME;
  if (env == 'pre') {
    name = 'Trex Protocol Community';
  }
  console.log(`Community NFT Name: ${name}`);
  return name;
}
export function getCommunityNFTSymbol(env: string): string {
  let symbol = OPENSOCIAL_COMMUNITY_SYMBOL;
  if (env == 'pre') {
    symbol = 'TPC';
  }
  console.log(`Community NFT Symbol: ${symbol}`);
  return symbol;
}
//const
export enum ProtocolState {
  Unpaused,
  PublishingPaused,
  Paused,
}

export const whitelistTokenList: { [chainId: number]: string[] } = {
  11155111: [
    '0x12b5B2fbF734fcd8C22a07C32f28D51F69775fC2',
    '0xcfFE58F09FfB9d4AE5f92449EA4aC75edD87e779',
  ],
  80002: [
    '0xf1286A6c17C1DC41D4DC5166751579a61D7aa6fC',
    '0xbF3299b4C9eA7CdB7373836E75633FE2696157b0',
  ],
  84532: [
    '0x323e78f944A9a1FcF3a10efcC5319DBb0bB6e673',
    '0xAa8Ff530B040A36eaF29CF161F79b44F4e76d254',
  ],
  31337: [],
  8543: ['0x833589fcd6edb6e08f4c7c32d4f71b54bda02913'],
};

export const whitelistSlotNftList: { [chainId: number]: string[] } = {
  11155111: ['0xBCfa8220b687Bf76C3440DEdB8A01542a6b16106'],
  31337: [],
};

export const nftMetaBaseUrl: { [network: string]: string | undefined } = {
  dev: 'https://dev.opensocial.trex.xyz/v2/meta',
  beta: 'https://opensocial.trex.xyz/v2/meta',
  pre: 'https://api.opensocial.fun/v2/meta',
  local: undefined,
};

export type OspRole = {
  stateAdmin: string[];
  appAdmin: string[];
  governance: string[];
  operation: string[];
  treasureAddress: string;
};

export const ospRoles: { [chainIdAndEnv: string]: OspRole } = {
  '8453-prod': {
    stateAdmin: ['0xe84ec627c902B8dfDd6e97278066de1FA0a83fAd'],
    appAdmin: ['0x0B45cA958E9f655C154e70Da909795baC1B4aD83'],
    governance: ['0x0B45cA958E9f655C154e70Da909795baC1B4aD83'],
    operation: ['0x00091fB7CF3E2fC93FE2792ea51086037F2EE8AC'],
    treasureAddress: '0xA81cbAf4CA84361a7ffF509538d7b682a2AcDb77',
  },
  '8453-pre': {
    stateAdmin: ['0xe84ec627c902B8dfDd6e97278066de1FA0a83fAd'],
    appAdmin: ['0x88E976462588e9D9fbE2d19Eaf28719C8ACaD788'],
    governance: ['0x88E976462588e9D9fbE2d19Eaf28719C8ACaD788'],
    operation: ['0x88E976462588e9D9fbE2d19Eaf28719C8ACaD788'],
    treasureAddress: '0x88E976462588e9D9fbE2d19Eaf28719C8ACaD788',
  },
  '196-prod': {
    stateAdmin: ['0xe84ec627c902B8dfDd6e97278066de1FA0a83fAd'],
    appAdmin: ['0x0B45cA958E9f655C154e70Da909795baC1B4aD83'],
    governance: ['0x0B45cA958E9f655C154e70Da909795baC1B4aD83'],
    operation: ['0x00091fB7CF3E2fC93FE2792ea51086037F2EE8AC'],
    treasureAddress: '0xA81cbAf4CA84361a7ffF509538d7b682a2AcDb77',
  },
  '196-pre': {
    stateAdmin: ['0x93727498f170f1a585093b4b6c3dbe0db056a7c4'],
    appAdmin: ['0x88E976462588e9D9fbE2d19Eaf28719C8ACaD788'],
    governance: ['0x88E976462588e9D9fbE2d19Eaf28719C8ACaD788'],
    operation: ['0x88E976462588e9D9fbE2d19Eaf28719C8ACaD788'],
    treasureAddress: '0x88E976462588e9D9fbE2d19Eaf28719C8ACaD788',
  },
};

export const STATE_ADMIN = ethers.utils.keccak256(ethers.utils.toUtf8Bytes('STATE_ADMIN'));
export const APP_ADMIN = ethers.utils.keccak256(ethers.utils.toUtf8Bytes('APP_ADMIN'));
export const GOVERNANCE = ethers.utils.keccak256(ethers.utils.toUtf8Bytes('GOVERNANCE'));
export const OPERATION = ethers.utils.keccak256(ethers.utils.toUtf8Bytes('OPERATION'));
console.log(OPERATION);
