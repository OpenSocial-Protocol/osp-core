const path = require('path');
const fs = require('fs');
// If no arguments are passed - fail
if (process.argv.length !== 5) {
  console.error('Usage: node saveAddress.js <targetEnv> <contractName> <address>');
  process.exit(1);
}
const [targetEnv, contract, address] = process.argv.slice(2);

const addressesPath = `../../addresses-${targetEnv}.json`;
if (!fs.existsSync(path.join(__dirname, addressesPath))) {
  fs.writeFileSync(path.join(__dirname, addressesPath), '{}\n');
}
const addresses = require(path.join(__dirname, addressesPath));
// If 3 arguments are passed - save the contract address
addresses[contract] = address;
fs.writeFileSync(path.join(__dirname, addressesPath), JSON.stringify(addresses, null, 2) + '\n');
process.exit(0);
