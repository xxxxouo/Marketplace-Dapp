require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-etherscan");
require("dotenv").config()
const fs = require('fs');
// const infuraId = fs.readFileSync(".infuraid").toString().trim() || "";


const GOERLI_RUL = process.env.GOERLI_RUL
const GOERLI_PRIVATE_KEY = process.env.GOERLI_PRIVATE_KEY

task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

module.exports = {
  defaultNetwork: "hardhat",
  networks: {
    // hardhat: {
    //   chainId: 1337
    // },
    goerli: {
      url: GOERLI_RUL,
      accounts: [GOERLI_PRIVATE_KEY]
    }
  },
  solidity: {
    version: "0.8.4",
    // settings: {
    //   optimizer: {
    //     enabled: true,
    //     runs: 200
    //   }
    // }
  },
  etherscan:{
    apiKey: {
      goerli: process.env.GOERLI_API_KEY
    },
    customChains: [
      {
        network: "goerli",
        chainId: 5,
        urls: {
          apiURL: "http://api-goerli.etherscan.io/api",
          browserURL: "https://goerli.etherscan.io"
        }
      }
    ]
  }
};