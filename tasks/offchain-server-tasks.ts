import '@nomiclabs/hardhat-ethers';
import { task } from 'hardhat/config';
import { ZERO_ADDRESS } from '../config/hardhat';
import { DEPLOY_TASK_NAME } from '../config/tasks';
import { OspClient__factory, SlotNFT__factory } from '../target/typechain-types';
import { waitForTx } from './helpers/utils';

task('offchain-setup', 'deploys the entire OpenSocial Protocol').setAction(async (_, hre) => {
  await hre.run(DEPLOY_TASK_NAME.FULL_DEPLOY_OSP);
  // Note that the use of these signers is a placeholder and is not meant to be used in
  // production.
  const ethers = hre.ethers;
  const accounts = await ethers.getSigners();
  const deployer = accounts[0];

  // eslint-disable-next-line @typescript-eslint/no-var-requires
  const address = require(`../addresses-${hre.network.name}.json`);
  console.log(address.routerProxy);

  const ospClient = OspClient__factory.connect(address.routerProxy, deployer);

  await waitForTx(
    ospClient.createProfile({
      handle: 'aaaaaaaaa',
      followConditionInitCode: [],
      inviter: 0,
    })
  );
  await waitForTx(SlotNFT__factory.connect(address.slotNFT, deployer).mintTo(deployer.address));
  await waitForTx(
    ospClient.createCommunity({
      handle: 'aaaaaaaaa',
      joinConditionInitCode: [],
      communityConditionAndData: ethers.utils.concat([
        address.slotNFTCommunityCond,
        ethers.utils.defaultAbiCoder.encode(['address', 'uint256'], [address.slotNFT, 1]),
      ]),
    })
  );
  await waitForTx(
    ospClient.createActivity({
      profileId: 1,
      communityId: 1,
      contentURI: 'ipfs://QmbnjYPgZNU1V3jAetGP5PBgQpn3P9kBzCZhVZmefhMCu6',
      extensionInitCode: [],
      referenceConditionInitCode: [],
    })
  );
});

task('offchain-sig', 'deploys the entire OpenSocial Protocol').setAction(async (_, hre) => {
  // Note that the use of these signers is a placeholder and is not meant to be used in
  // production.
  const ethers = hre.ethers;
  const accounts = await ethers.getSigners();
  const deployer = accounts[0];

  const eip712Message = {
    domain: {
      name: 'OpenSocial Protocol Profiles',
      version: '1',
      chainId: 31337,
      verifyingContract: '0x5FC8d32690cc91D4c39d9d3abcBD16989F875707',
    },
    types: {
      CreateOpenReactionWithSig: [
        {
          name: 'profileId',
          type: 'uint256',
        },
        {
          name: 'communityId',
          type: 'uint256',
        },
        {
          name: 'referencedProfileId',
          type: 'uint256',
        },
        {
          name: 'referencedContentId',
          type: 'uint256',
        },
        {
          name: 'reactionAndData',
          type: 'bytes',
        },
        {
          name: 'referenceConditionData',
          type: 'bytes',
        },
        {
          name: 'nonce',
          type: 'uint256',
        },
        {
          name: 'deadline',
          type: 'uint256',
        },
      ],
    },
    value: {
      profileId: 1,
      communityId: 1,
      referencedProfileId: 1,
      referencedContentId: '0x9eb21bc04dd640adba1fe40e8ab2481a00000000000000000000000000000002',
      reactionAndData:
        '0x610178da211fef7d417bc0e6fed39f05609ad7880000000000000000000000000000000000000000000000000000000000000000',
      referenceConditionData: '0x',
      nonce: 0,
      deadline: 1715652200,
    },
  };

  const sig = await deployer._signTypedData(
    eip712Message.domain,
    eip712Message.types,
    eip712Message.value
  );

  console.log(sig);
  console.log(deployer.address);
});
