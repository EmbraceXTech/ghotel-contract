import hre, { ethers } from "hardhat";
import { getAddressList } from "../../utils/address.util";
import {
  PBMDistributor__factory,
} from "../../typechain-types";

export const transferDistributorOwnership = async () => {
  const [owner] = await ethers.getSigners();
  const addressList = getAddressList(hre.network.name);

  const PBMDistributor = PBMDistributor__factory.connect(
    addressList['PBMDistributor'],
    owner
  );

  const tx = await PBMDistributor.transferOwnership(addressList['GovHelper']);
  await tx.wait();

  console.log(`Transfer ownership of PBMDistributor to GovHelper`);
};