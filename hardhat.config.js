require("@nomiclabs/hardhat-truffle5");
require("@nomiclabs/hardhat-etherscan");
require("@nomiclabs/hardhat-web3");
require("@nomiclabs/hardhat-waffle");
require("dotenv/config")
const fs = require("fs");
const mnemonic = process.env.MNEMONIC;

module.exports = {
  networks: {
    hardhat: {
      accounts: { mnemonic: "test test test test test test test test test test test junk" },
    },
    testnet: {
      url: `https://data-seed-prebsc-1-s1.binance.org:8545/`,
      network_id: 97,
      confirmations: 1,
      gas:20000000,
      timeoutBlocks: 20000000,
      skipDryRun: true,
      accounts: { mnemonic: mnemonic },
    },
    bnbMainNet: {
      url: `https://bsc-dataseed.binance.org`,
      network_id: 56,
      confirmations: 1,
      gas: 20000000,
      timeoutBlocks: 20000000,
      skipDryRun: true,
      accounts: { mnemonic: mnemonic },
    },
  },
  solidity: {
    compilers: [
      {
        version: "0.6.12",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ],
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY, //bnb
  },
};
