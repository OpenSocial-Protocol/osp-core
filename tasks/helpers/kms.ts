import { HardhatRuntimeEnvironment, HttpNetworkConfig } from 'hardhat/types';
import { ethers, Signer, UnsignedTransaction } from 'ethers';
import { AwsKmsSigner } from 'ethers-aws-kms-signer';
import '@nomiclabs/hardhat-ethers/internal/type-extensions';

export class KmsSigner extends AwsKmsSigner {
  async signTransaction(
    transaction: ethers.utils.Deferrable<ethers.providers.TransactionRequest>
  ): Promise<string> {
    const unsignedTx = await ethers.utils.resolveProperties(transaction);
    delete unsignedTx['from'];
    const serializedTx = ethers.utils.serializeTransaction(<UnsignedTransaction>unsignedTx);
    const transactionSignature = await this._signDigest(ethers.utils.keccak256(serializedTx));
    return ethers.utils.serializeTransaction(<UnsignedTransaction>unsignedTx, transactionSignature);
  }
}

export async function getDeployer(hre: HardhatRuntimeEnvironment) {
  const deployer: Signer = process.env.AWS_KMS_KEY_ID
    ? new KmsSigner(
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
