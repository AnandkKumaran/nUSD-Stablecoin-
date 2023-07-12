require("@nomicfoundation/hardhat-toolbox");

// The next line is part of the sample project, you don't need it in your
// project. It imports a Hardhat task definition, that can be used for
// testing the frontend.
require("./tasks/faucet");

/** @type import('hardhat/config').HardhatUserConfig */

const INFURA_API_KEY = "361d296a6ad64c0297331a6dc1666b3d";
const SEPOLIA_PRIVATE_KEY = "c7f8ad704f09db88d70f6b6de7f87e3d7d42c74b70074f2d137b0bb453205108";


module.exports = {
  solidity: "0.8.18",

  networks: {
    sepolia: {
      url: `https://sepolia.infura.io/v3/${INFURA_API_KEY}`,
      accounts: [SEPOLIA_PRIVATE_KEY]
    }
  }
};
