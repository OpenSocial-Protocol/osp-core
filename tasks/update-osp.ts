import '@nomiclabs/hardhat-ethers';
import { Wallet } from 'ethers';
import { task } from 'hardhat/config';
import {
  ERC6551Account__factory,
  LikeReaction__factory,
  OnlyMemberReferenceCond__factory,
  OspClient__factory,
  SlotNFTCommunityCond__factory,
  VoteReaction__factory,
  WhitelistAddressCommunityCond__factory,
} from '../target/typechain-types';
import { deployContract, getAddresses, waitForTx } from './helpers/utils';
import fs from 'fs';
import { getDeployer } from './helpers/kms';

task('6551-update')
  .addParam('env')
  .setAction(async ({ env }, hre) => {
    const ospAddressConfig = getAddresses(hre, env);
    const ospAddress = ospAddressConfig.routerProxy;

    const ethers = hre.ethers;
    const deployer = new Wallet(<string>process.env.DEPLOYER_PRIVATE_KEY, ethers.provider);

    const osp = OspClient__factory.connect(ospAddress, deployer);
    const erc6551Account = await deployContract(new ERC6551Account__factory(deployer).deploy());
    await waitForTx(osp.setERC6551AccountImpl(erc6551Account.address));
  });

task('token-update')
  .addParam('env')
  .setAction(async ({ env }, hre) => {
    const ospAddressConfig = getAddresses(hre, env);
    const ospAddress = ospAddressConfig.routerProxy;
    const communityCondition = ospAddressConfig.slotNFTCommunityCond;

    const ethers = hre.ethers;
    const deployer = new Wallet(<string>process.env.DEPLOYER_PRIVATE_KEY, ethers.provider);

    const osp = OspClient__factory.connect(ospAddress, deployer);

    await waitForTx(osp.whitelistToken('0xE3fc2f5E071810395C7584ec14e2257056888457', true));
    await waitForTx(
      SlotNFTCommunityCond__factory.connect(communityCondition, deployer).whitelistCommunitySlot(
        '3946Ce3FD7Ac2101d3062aD471e2d7b45E16B902',
        true
      )
    );
  });

task('uri-update')
  .addParam('env')
  .setAction(async ({ env }, hre) => {
    const ospAddressConfig = getAddresses(hre, env);
    const ospAddress = ospAddressConfig.routerProxy;

    const ethers = hre.ethers;
    const deployer = new Wallet(<string>process.env.DEPLOYER_PRIVATE_KEY, ethers.provider);

    const osp = OspClient__factory.connect(ospAddress, deployer);

    await waitForTx(osp.setBaseURI('https://dev.opensocial.trex.xyz/v2/meta/'));
  });

task('deploy-like-vote-reaction')
  .addParam('env')
  .setAction(async ({ env }, hre) => {
    const ospAddressConfig = getAddresses(hre, env);
    const ospAddress = ospAddressConfig.routerProxy;
    const ethers = hre.ethers;
    const deployer = new Wallet(<string>process.env.DEPLOYER_PRIVATE_KEY, ethers.provider);

    const likeReaction = await deployContract(
      new LikeReaction__factory(deployer).deploy(ospAddress)
    );
    const voteReaction = await deployContract(
      new VoteReaction__factory(deployer).deploy(ospAddress)
    );

    await waitForTx(
      OspClient__factory.connect(ospAddress, deployer).whitelistApp(likeReaction.address, true)
    );
    await waitForTx(
      OspClient__factory.connect(ospAddress, deployer).whitelistApp(voteReaction.address, true)
    );

    ospAddressConfig.likeReaction = likeReaction.address;
    ospAddressConfig.voteReaction = voteReaction.address;
    fs.writeFileSync(
      `addresses-${hre.network.name}.json`,
      JSON.stringify(ospAddressConfig, null, 2)
    );
  });

task('deploy-only-member-referenced-condition')
  .addParam('env')
  .setAction(async ({ env }, hre) => {
    const ospAddressConfig = getAddresses(hre, env);
    const ospAddress = ospAddressConfig.routerProxy;
    const ethers = hre.ethers;
    const deployer = new Wallet(<string>process.env.DEPLOYER_PRIVATE_KEY, ethers.provider);

    const onlyMemberReferencedCondition = await deployContract(
      new OnlyMemberReferenceCond__factory(deployer).deploy(ospAddress)
    );

    await waitForTx(
      OspClient__factory.connect(ospAddress, deployer).whitelistApp(
        onlyMemberReferencedCondition.address,
        true
      )
    );

    ospAddressConfig.onlyMemberReferencedCondition = onlyMemberReferencedCondition.address;
    fs.writeFileSync(
      `addresses-${hre.network.name}.json`,
      JSON.stringify(ospAddressConfig, null, 2)
    );
  });

task('add-whitelist-community-creator')
  .addParam('env')
  .addParam('address')
  .addParam('amount')
  .setAction(async ({ env, address, amount }, hre) => {
    const addresses = getAddresses(hre, env);
    const whitelistAddressCommunityCond = WhitelistAddressCommunityCond__factory.connect(
      addresses.whitelistAddressCommunityCond,
      await getDeployer(hre)
    );
    await waitForTx(whitelistAddressCommunityCond.setMaxCreationNumber(address, amount));
  });
