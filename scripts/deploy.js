const hre = require("hardhat");

async function main() {
  const [deployer, team, marketing] = await hre.ethers.getSigners();

  console.log("Deploying contracts with:", deployer.address);

  // Deploy TPAY token with initialOwner, team, and marketing addresses
  const TpayToken = await hre.ethers.getContractFactory("TpayToken");
  const token = await TpayToken.deploy(deployer.address, team.address, marketing.address);
  await token.deployed();
  console.log("TpayToken deployed to:", token.address);

  // Set start block for farming
  const currentBlock = await hre.ethers.provider.getBlockNumber();
  const startBlock = currentBlock + 10;

  // Deploy farming contract
  const TpayFarm = await hre.ethers.getContractFactory("TpayFarm");
  const farm = await TpayFarm.deploy(deployer.address, token.address, hre.ethers.utils.parseEther("1"), startBlock);
  await farm.deployed();
  console.log("TpayFarm deployed to:", farm.address);

  // Deploy DEX Factory
  const TpayFactory = await hre.ethers.getContractFactory("TpayFactory");
  const factory = await TpayFactory.deploy(deployer.address);
  await factory.deployed();
  console.log("TpayFactory deployed to:", factory.address);

  // Deploy DEX Router
  const TpayRouter = await hre.ethers.getContractFactory("TpayRouter");
  const router = await TpayRouter.deploy(factory.address);
  await router.deployed();
  console.log("TpayRouter deployed to:", router.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
