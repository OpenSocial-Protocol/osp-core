//config
export const OPENSOCIAL_SBT_NAME = 'OpenSocial Protocol Profiles';
export const OPENSOCIAL_SBT_SYMBOL = 'OSPT';
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
};

export const whitelistSlotNftList: { [chainId: number]: string[] } = {
  11155111: ['0xBCfa8220b687Bf76C3440DEdB8A01542a6b16106'],
  31337: [],
};

export const nftMetaBaseUrl: { [network: string]: string | undefined } = {
  dev: 'https://dev.opensocial.trex.xyz/v2/meta/',
  beta: 'https://opensocial.trex.xyz/v2/meta/',
  pre: 'https://api.opensocial.fun/v2/meta/',
  local: undefined,
};
