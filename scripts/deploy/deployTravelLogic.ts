import hre, { ethers } from "hardhat";
import { TravelLogic__factory } from "../../typechain-types";
import { setAddress } from "../../utils/address.util";

export async function deployTravelLogic() {
  const [owner] = await ethers.getSigners();

  const TravelLogic = (await ethers.getContractFactory(
    "TravelLogic",
    owner
  )) as TravelLogic__factory;

  const travelLogic = await TravelLogic.deploy();

  await travelLogic.waitForDeployment();

  const travelLogicAddr = await travelLogic.getAddress();

  console.log("TravelLogic deployed address:", travelLogicAddr);

  setAddress("TravelLogic", travelLogicAddr, hre.network.name);

  return travelLogic;
}
