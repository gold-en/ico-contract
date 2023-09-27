// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  const CryptoX = await hre.ethers.deployContract("CryptoX");

  await CryptoX.waitForDeployment();

  console.log(`CryptoX deployed to ${CryptoX.target}`);

  const CryptoX_ICO = await hre.ethers.deployContract("CryptoX_ICO", [
    CryptoX.target,
  ]);

  await CryptoX_ICO.waitForDeployment();
  console.log(`CryptoX_ICO deployed to ${CryptoX_ICO.target}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
