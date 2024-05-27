//config
import { ethers } from 'ethers';

export const OPENSOCIAL_SBT_NAME = 'OpenSocial Protocol Profile';
export const OPENSOCIAL_SBT_SYMBOL = 'OSPP';
export const OPENSOCIAL_COMMUNITY_NAME = 'OpenSocial Protocol Community';
export const OPENSOCIAL_COMMUNITY_SYMBOL = 'OSPC';
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

export const ospRoles: { [chainId: number]: OspRole } = {
  8453: {
    stateAdmin: ['0xe84ec627c902B8dfDd6e97278066de1FA0a83fAd'],
    appAdmin: ['0x0B45cA958E9f655C154e70Da909795baC1B4aD83'],
    governance: ['0x0B45cA958E9f655C154e70Da909795baC1B4aD83'],
    operation: ['0x00091fB7CF3E2fC93FE2792ea51086037F2EE8AC'],
    treasureAddress: '0xA81cbAf4CA84361a7ffF509538d7b682a2AcDb77',
  },
};

export const STATE_ADMIN = ethers.utils.keccak256(ethers.utils.toUtf8Bytes('STATE_ADMIN'));
export const APP_ADMIN = ethers.utils.keccak256(ethers.utils.toUtf8Bytes('APP_ADMIN'));
export const GOVERNANCE = ethers.utils.keccak256(ethers.utils.toUtf8Bytes('GOVERNANCE'));
export const OPERATION = ethers.utils.keccak256(ethers.utils.toUtf8Bytes('OPERATION'));
