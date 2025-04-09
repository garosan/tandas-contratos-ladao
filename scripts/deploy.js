require("dotenv").config();
const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();

  const devFund = process.env.DEV_FUND_ADDRESS;
  if (!devFund) {
    throw new Error("DEV_FUND_ADDRESS is not defined in .env");
  }

  console.log("Deploying contracts with address:", deployer.address);
  console.log("Using dev fund address:", devFund);

  const Main = await hre.ethers.getContractFactory("Main");
  const main = await Main.deploy(devFund);
  await main.waitForDeployment();

  console.log("Contract deployed to:", await main.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
