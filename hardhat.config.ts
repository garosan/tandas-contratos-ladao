require("dotenv").config();
require("hardhat-contract-sizer");
require("@nomicfoundation/hardhat-ethers");
import type { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox-viem";

if (!process.env.SEPOLIA_RPC_URL || !process.env.PRIVATE_KEY) {
  throw new Error("Missing environment variables for Sepolia deployment.");
}

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.28",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  networks: {
    sepolia: {
      url: process.env.SEPOLIA_RPC_URL,
      accounts: [process.env.PRIVATE_KEY],
    },
    localhost: {
      url: "http://127.0.0.1:8545",
    },
  },
};

export default config;
