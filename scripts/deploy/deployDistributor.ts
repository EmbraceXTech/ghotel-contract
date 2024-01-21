import hre, { ethers } from "hardhat";
import addressUtil, { setAddress } from "../../utils/address.util";

export async function deployPBMDistributor() {
  const [owner] = await ethers.getSigners();

  const PBMDistributor = (await ethers.getContractFactory(
    "PBMDistributor",
    owner
  ));

  const pbmDistributor = await PBMDistributor.deploy();
  await pbmDistributor.waitForDeployment();

  const pbmDistributorAddr = await pbmDistributor.getAddress();
  console.log("PBM Distributor deployed address:", pbmDistributorAddr);

  setAddress("PBMDistributor", pbmDistributorAddr, hre.network.name);
  return pbmDistributorAddr;
}
