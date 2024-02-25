require("@nomiclabs/hardhat-waffle")
require("@nomiclabs/hardhat-etherscan")
require("hardhat-contract-sizer")
require('@typechain/hardhat')

const {
  CORE_RPC,
  CORE_DEPLOY_KEY,
  CORESCAN_API_KEY
} = require("./env.json")

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async () => {
  const accounts = await ethers.getSigners()

  for (const account of accounts) {
    console.info(account.address)
  }
})

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  networks: {
    localhost: {
      url: 'http://127.0.0.1:8545/',
      timeout: 120000,
      chainId: 31337
    },
    hardhat: {
      allowUnlimitedContractSize: true
    },
    pulsetestnet: {
      url: 'https://rpc-testnet-pulsechain.g4mm4.io',
      accounts: [CORE_DEPLOY_KEY],
      network_id: '*',
    },
  },
  etherscan: {
    apiKey: {
      pulsemainnet: "675cb5c5ae5b434e88fc8602b65aca0f",
      pulsetestnet: "0000000000000000000000000000000000",
      goerli: "3TEWVV2EK19S1Y6SV8EECZAGQ7W3362RCN",
    },
    customChains: [
      {
        network: "pulsetestnet",
        chainId: 943,
        urls: {
          apiURL: "https://scan.v4.testnet.pulsechain.com/api",
          browserURL: "https://scan.v4.testnet.pulsechain.com"
        }
      },
    ]
  },
  solidity: {
    compilers: [
      {
        version: "0.6.11",
        settings: {
            optimizer: {
                enabled: true,
                runs: 100
            }
        }
      },
      {
        version: "0.8.10",
        settings: {
            optimizer: {
                enabled: true,
                runs: 100
            }
        }
      },
    ]
  },
  typechain: {
    outDir: "typechain",
    target: "ethers-v5",
  },
}
