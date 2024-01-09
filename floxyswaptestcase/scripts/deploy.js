const { ethers, upgrades } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  const Floxyswap = await ethers.getContractFactory("Floxyswap");
  //const floxyswap = await upgrades.deployProxy(Floxyswap);
 const floxyswap = await Floxyswap.deploy();
  await floxyswap.deployed();

  console.log("Floxyswap deployed to:", floxyswap.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });