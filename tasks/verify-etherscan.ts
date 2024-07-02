import { task } from 'hardhat/config';

task('verify:contract', 'Verifies a contract on Etherscan')
  .addParam('contract', 'The contract address to verify')
  .addOptionalParam('args', 'The constructor arguments')
  .setAction(async (taskArgs, hre) => {
    await hre.run('verify:verify', {
      address: taskArgs.contract,
      constructorArguments: taskArgs.args ? taskArgs.args.split(',') : [],
    });
  });
