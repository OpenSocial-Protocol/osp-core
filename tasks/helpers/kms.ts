import { HardhatRuntimeEnvironment, HttpNetworkConfig } from 'hardhat/types';
import { ethers, Signer } from 'ethers';
import { AwsKmsSigner } from 'ethers-aws-kms-signer';
import '@nomiclabs/hardhat-ethers/internal/type-extensions';

export async function getDeployer(hre: HardhatRuntimeEnvironment) {
  const deployer: Signer = process.env.AWS_KMS_KEY_ID
    ? new AwsKmsSigner(
        {
          region: process.env.AWS_REGION as string,
          keyId: process.env.AWS_KMS_KEY_ID as string,
          accessKeyId: process.env.ACCESS_KEY_ID,
          secretAccessKey: process.env.SECRET_ACCESS_KEY,
        },
        hre.ethers.provider
        // new ethers.providers.StaticJsonRpcProvider(
        //   {
        //     url: (hre.network.config as HttpNetworkConfig).url,
        //     timeout: 2147483647,
        //   },
        //   { chainId: hre.network.config.chainId as number, name: hre.network.name as string }
        // )
      )
    : (await hre.ethers.getSigners())[0];
  return deployer;
}
