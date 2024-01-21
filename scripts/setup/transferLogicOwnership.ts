import hre, { ethers } from "hardhat";
import { getAddressList } from "../../utils/address.util";
import {
  TravelLogic__factory,
} from "../../typechain-types";

export const transferLogicOwnership = async () => {
  const [owner] = await ethers.getSigners();
  const addressList = getAddressList(hre.network.name);

  const TravelLogic = TravelLogic__factory.connect(
    addressList['TravelLogic'],
    owner
  );

  const tx = await TravelLogic.transferOwnership(addressList['GovHelper']);
  await tx.wait();

  console.log(`Transfer ownership of Logic to GovHelper`);
};