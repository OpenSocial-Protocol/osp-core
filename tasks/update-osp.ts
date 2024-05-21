import '@nomiclabs/hardhat-ethers';
import { ethers, Wallet } from 'ethers';
import { task } from 'hardhat/config';
import {
  CommunityNFT__factory,
  ERC20FeeJoinCond__factory,
  ERC6551Account__factory,
  JoinNFT__factory,
  OspClient__factory,
  OspRouterImmutable__factory,
  OspUniversalProxy__factory,
  WhitelistAddressCommunityCond__factory,
} from '../target/typechain-types';
import { deployContract, getAddresses, getMulticall3, waitForTx } from './helpers/utils';
import { getDeployer } from './helpers/kms';
import { ProtocolState } from '../config/osp';
import { getUpdateCallDatas } from './update-all-router';
import fs from 'fs';

task('6551-update')
  .addParam('env')
  .setAction(async ({ env }, hre) => {
    const ospAddressConfig = getAddresses(hre, env);
    const ospAddress = ospAddressConfig.routerProxy;

    const ethers = hre.ethers;
    const deployer = new Wallet(<string>process.env.DEPLOYER_PRIVATE_KEY, ethers.provider);

    const osp = OspClient__factory.connect(ospAddress, deployer);
    const erc6551Account = await deployContract(
      new ERC6551Account__factory(deployer).deploy(ospAddress)
    );
    await waitForTx(osp.setERC6551AccountImpl(erc6551Account.address));
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

task('add-whitelist-app')
  .addParam('env')
  .addParam('address')
  .addParam('whitelist')
  .setAction(async ({ env, address, whitelist }, hre) => {
    const addresses = getAddresses(hre, env);
    const whitelistAddressCommunityCond = OspClient__factory.connect(
      addresses.routerProxy,
      await getDeployer(hre)
    );
    await waitForTx(whitelistAddressCommunityCond.whitelistApp(address, whitelist == 'true'));
  });

task('set-treasure-address')
  .addParam('env')
  .addParam('address')
  .setAction(async ({ env, address }, hre) => {
    const addresses = getAddresses(hre, env);
    const ospClient = OspClient__factory.connect(addresses.routerProxy, await getDeployer(hre));
    await waitForTx(ospClient.setTreasureAddress(address));
  });

task('update-20240521')
  .addParam('env')
  .setAction(async ({ env }, hre) => {
    fs.writeFileSync(
      `addresses-${env}-${hre.network.name}.json`,
      JSON.stringify(
        {
          routerProxy: '0x0000005d520C83F6A87b4AaF62872566c3509C2C',
          governanceLogic: '0x519e7b8d92302da5bc23cC7e3B89383bBd5EbfBe',
          profileLogic: '0x5AfF2A765E202a895c5a56d2e0441c816b3D3E79',
          communityLogic: '0x69e5602EfAC2454de839D5Cf8e8fAcDfB271E39a',
          contentLogic: '0xE8200730A6dDe4AB02122b96Bd2E36c100e35317',
          relationLogic: '0x1A5Dc1ee47006C2c5817627242cC6FF54e608b1d',
          followSBTImpl: '0xF0656e75B787e5b04d4B3473E0dF2B93802B0078',
          joinNFTImpl: '0xfE246D320D8f6677b3330cE0A1CACC9a0b6a24AA',
          communityNFT: '0x00000026EfBD75a40192fb561959aEA4A660BdF1',
          communityNFTProxy: '0x00000062954A785b82fb182D289987bDf29389Ab',
          voteReaction: '0x000000031B349FC9eb7AD21760b22C0eE96e48D0',
          holdTokenJoinCond: '0x00000012727AF92E64Da917Cfaf793cd95c68Cdc',
          erc20FeeJoinCond: '0x0000003FBC3A9898E98946EC27129fD2b940C3D9',
          nativeFeeJoinCond: '0x0000000968Ee9FB0C19Cb949Fc66dC95B364a695',
          onlyMemberReferenceCond: '0x000000b9a0a54956Ecc12E780d93F5807FEaE990',
          slotNFTCommunityCond: '0x00000060aE675f320EEA4CFB50E003a60f73B5EC',
          whitelistAddressCommunityCond: '0x000000fD667CD9476aB8103346c18d41C8E18546',
        },
        null,
        2
      )
    );

    const address = getAddresses(hre, env);
    // eslint-disable-next-line @typescript-eslint/ban-ts-comment
    // @ts-ignore
    const deployer = await getDeployer(hre);

    // update community nft
    const communityNFTProxy = OspUniversalProxy__factory.connect(
      address?.communityNFTProxy,
      deployer
    );
    const communityNftImpl = await deployContract(
      new CommunityNFT__factory(deployer).deploy(address.routerProxy)
    );
    await waitForTx(communityNFTProxy.updateToAndCall(communityNftImpl.address, []));

    //update core
    const ospClient = OspClient__factory.connect(address.routerProxy, deployer);
    const calldatas: Array<string> = [];
    calldatas.push(ospClient.interface.encodeFunctionData('setState', [ProtocolState.Paused]));
    const { ospAddressConfig, calldata: updateRouterCallDatas } = await getUpdateCallDatas(
      'content,community,governance,relation',
      hre,
      env
    );
    calldatas.push(...updateRouterCallDatas);

    //update 6551 account
    const erc6551Impl = await deployContract(
      new ERC6551Account__factory(deployer).deploy(address.routerProxy)
    );
    ospAddressConfig.erc6551AccountImpl = erc6551Impl.address;
    calldatas.push(
      ospClient.interface.encodeFunctionData('setERC6551AccountImpl', [erc6551Impl.address])
    );

    //update join nft impl
    const joinNFTImpl = await deployContract(
      new JoinNFT__factory(deployer).deploy(address.routerProxy)
    );
    ospAddressConfig.joinNFTImpl = joinNFTImpl.address;
    calldatas.push(ospClient.interface.encodeFunctionData('setJoinNFTImpl', [joinNFTImpl.address]));
    calldatas.push(ospClient.interface.encodeFunctionData('setState', [ProtocolState.Unpaused]));

    await waitForTx(
      OspRouterImmutable__factory.connect(address.routerProxy, deployer).multicall(calldatas)
    );
    fs.writeFileSync(
      `addresses-${env}-${hre.network.name}.json`,
      JSON.stringify(ospAddressConfig, null, 2)
    );

    //update 6551 account
    const multicall3 = await getMulticall3(hre);
    const communityNFT = CommunityNFT__factory.connect(address?.communityNFTProxy, deployer);
    const totalSupply = await communityNFT.totalSupply();
    const communityIds: Array<number> = [];
    for (let i = 1; i <= totalSupply.toNumber(); i++) {
      communityIds.push(i);
    }
    const community6551Account = (
      (
        await multicall3.callStatic.aggregate(
          communityIds.map((communityId) => ({
            target: address.routerProxy,
            callData: ospClient.interface.encodeFunctionData('getCommunityAccount(uint256)', [
              communityId,
            ]),
          }))
        )
      ).returnData as Array<string>
    ).map((bytes) => ethers.utils.defaultAbiCoder.decode(['address'], bytes)[0] as string);
    const updateCommunityIdCallDatas: Array<{
      target: string;
      callData: string;
      allowFailure: boolean;
    }> = [];
    for (const index in communityIds) {
      updateCommunityIdCallDatas.push({
        target: community6551Account[index],
        callData: ERC6551Account__factory.createInterface().encodeFunctionData('setCommunityId', [
          communityIds[index],
        ]),
        allowFailure: false,
      });
    }
    console.log(updateCommunityIdCallDatas);
    await waitForTx(multicall3.aggregate3(updateCommunityIdCallDatas));
  });
