import hre, { ethers } from "hardhat";
import { TravelPBM__factory } from "../../typechain-types";
import { setAddress } from "../../utils/address.util";

export async function deployTravelPBM(uri: string) {
  const [owner] = await ethers.getSigners();

  const TravelPBM = (await ethers.getContractFactory(
    "TravelPBM",
    owner
  )) as TravelPBM__factory;

  const travelPBM = await TravelPBM.deploy(uri);

  await travelPBM.waitForDeployment();

  const travelPBMAddr = await travelPBM.getAddress();

  console.log("TravelPBM deployed address:", travelPBMAddr);

  setAddress("TravelPBM", travelPBMAddr, hre.network.name);

  return travelPBMAddr;
}
