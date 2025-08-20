import { ethers } from "hardhat";

async function main() {
  const ContractFactory = await ethers.getContractFactory("PrivateDCA");
  const contract = await ContractFactory.deploy();

  await contract.waitForDeployment();

  console.log("PrivateDCA deployed to:", await contract.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
