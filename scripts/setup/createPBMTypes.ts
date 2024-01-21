import hre, { ethers } from "hardhat";
import { getAddressList } from "../../utils/address.util";
import {
  TravelPBMManager__factory,
} from "../../typechain-types";

export const createPBMTypes = async () => {
  const [owner] = await ethers.getSigners();
  const addressList = getAddressList(hre.network.name);
  const uri =
    "https://bafybeih5ij4dbras2du3eq2rbbl54ffzqx5dqghswpqyiarlpcs2psijji.ipfs.nftstorage.link/{id}.json";

  const block = await ethers.provider.getBlock("latest");
  const blockTime = block?.timestamp || 0;
  const expiry = blockTime + 365 * 24 * 60;

  const TravelPBMManager = TravelPBMManager__factory.connect(
    addressList.TravelPBMManger,
    owner
  );

  const tx1 = await TravelPBMManager.createPBMTokenType(
    "Hotel",
    1,
    expiry,
    uri,
    4000
  );
  await tx1.wait();

  const tx2 = await TravelPBMManager.createPBMTokenType(
    "Flight",
    1,
    expiry,
    uri,
    4000
  );
  await tx2.wait();

  const tx3 = await TravelPBMManager.createPBMTokenType(
    "Food",
    1,
    expiry,
    uri,
    3000
  );
  await tx3.wait();

};