require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.9",
  networks: {
    goerli: {
      url: "https://goerli.infura.io/v3/f52e8964c7734baeafbd08a6ef7b3774",
      accounts: ["..."]
    }
  }
};
