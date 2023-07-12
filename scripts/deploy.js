// This is a script for deploying your contracts. You can adapt it to deploy
// yours, or create new ones.

const path = require("path");

async function main() {
  // This is just a convenience check
  if (network.name === "hardhat") {
    console.warn(
      "You are trying to deploy a contract to the Hardhat Network, which" +
        "gets automatically created and destroyed every time. Use the Hardhat" +
        " option '--network localhost'"
    );
  }

  // ethers is available in the global scope
  const [deployer] = await ethers.getSigners();
  console.log(
    "Deploying the contracts with the account:",
    await deployer.getAddress()
  );

  console.log("Account balance:", (await deployer.getBalance()).toString());

  const Token = await ethers.getContractFactory("nUSDStableCoin");
  const token = await Token.deploy();
  await token.deployed();

  console.log("Token address:", token.address);

  const ETH_USD_PRICE_FEED = "0x694AA1769357215DE4FAC081bf1f309aDC325306";
  const Engine = await ethers.getContractFactory("nUSDEngine");
  const engine = await Engine.deploy(ETH_USD_PRICE_FEED,token.address);
  await engine.deployed();

  console.log("nUSD Engine address:", engine.address);

  // GRANT OWNER ROLE TO ENGINE CONTRACT
  await token.transferOwnership(engine.address);

  // We also save the contract's artifacts and address in the frontend directory
  saveFrontendFiles(token, engine);
}

function saveFrontendFiles(token, engine) {
  const fs = require("fs");
  const contractsDir = path.join(__dirname, "..", "frontend", "src", "contracts");

  if (!fs.existsSync(contractsDir)) {
    fs.mkdirSync(contractsDir);
  }

  fs.writeFileSync(
    path.join(contractsDir, "contract-address.json"),
    JSON.stringify({ Token: token.address, Engine: engine.address }, undefined, 2)
  );

  const TokenArtifact = artifacts.readArtifactSync("nUSDStableCoin");

  fs.writeFileSync(
    path.join(contractsDir, "Token.json"),
    JSON.stringify(TokenArtifact, null, 2)
  );

  const EngineArtifact = artifacts.readArtifactSync("nUSDEngine");

  fs.writeFileSync(
    path.join(contractsDir, "Engine.json"),
    JSON.stringify(TokenArtifact, null, 2)
  );

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
