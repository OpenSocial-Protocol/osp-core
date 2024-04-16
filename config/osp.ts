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
export enum ReactionType {
  Like,
}
export enum ContentType {
  Post,
  Comment,
  Mirror,
  Nonexistent,
}

export const whitelistTokenList: { [chainId: number]: string[] } = {
  11155111: [
    '0x12b5B2fbF734fcd8C22a07C32f28D51F69775fC2',
    '0xcfFE58F09FfB9d4AE5f92449EA4aC75edD87e779',
  ],
  80001: [
    '0x40DB13287efc8d7e1a89baa4855d3e0D0e396006',
    '0xcfFE58F09FfB9d4AE5f92449EA4aC75edD87e779',
  ],
  31337: [],
};

export const whitelistSlotNftList: { [chainId: number]: string[] } = {
  11155111: ['0xBCfa8220b687Bf76C3440DEdB8A01542a6b16106'],
  80001: ['0x3946Ce3FD7Ac2101d3062aD471e2d7b45E16B902'],
  31337: [],
};

export const nftMetaBaseUrl: { [network: string]: string | undefined } = {
  dev: 'https://dev.opensocial.trex.xyz/v2/meta/',
  beta: 'https://opensocial.trex.xyz/v2/meta/',
  local: undefined,
};
