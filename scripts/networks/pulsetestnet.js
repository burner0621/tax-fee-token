//const deployMulticall = require("../core/deployMulticall");
const deployTokenContract = require("../pulsetestnet/deployTokenContract");
const { getGasUsed, syncDeployInfo } = require("../shared/syncParams");
const deploy_pulsetestnet = async () => {
  await deployTokenContract()
  console.log("gas used:", getGasUsed());
};

module.exports = { deploy_pulsetestnet };
