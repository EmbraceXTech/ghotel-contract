import hre, { ethers } from "hardhat";
import { getAddressList } from "../../utils/address.util";
import {
  TravelPBMManager__factory,
} from "../../typechain-types";

export const setPBMToManager = async () => {
  const [owner] = await ethers.getSigners();
  const addressList = getAddressList(hre.network.name);

  const TravelPBMManager = TravelPBMManager__factory.connect(
    addressList['TravelPBMManger'],
    owner
  );

  const tx = await TravelPBMManager.setPBM(addressList['TravelPBM']);
  await tx.wait();

  console.log(`Set PBM to Manager contract`);
};