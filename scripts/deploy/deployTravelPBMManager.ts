import hre, { ethers } from "hardhat";
import { TravelPBMManager__factory } from "../../typechain-types";
import { setAddress } from "../../utils/address.util";

export async function deployTravelPBMManager() {
  const [owner] = await ethers.getSigners();

  const TravelPBMManager = (await ethers.getContractFactory(
    "TravelPBMManager",
    owner
  )) as TravelPBMManager__factory;

  const travelPBMManger = await TravelPBMManager.deploy();

  await travelPBMManger.waitForDeployment();

  const travelPBMMangerAddr = await travelPBMManger.getAddress();

  console.log("TravelPBMManger deployed address:", travelPBMMangerAddr);

  setAddress("TravelPBMManger", travelPBMMangerAddr, hre.network.name);

  return travelPBMManger;
}
