import hre, { ethers } from "hardhat";
import { getAddressList } from "../../utils/address.util";
import {
  TravelPBMManager__factory,
  TravelPBM__factory,
} from "../../typechain-types";
import { ERC20__factory } from "../../typechain-types/factories/solmate/src/tokens";

export const createPBMTypes = async () => {
  const [owner] = await ethers.getSigners();
  const addressList = getAddressList(hre.network.name);
  const uri =
    "https://bafybeihidh7z4tgengyhu7qwmden6e4dzy42tds7h2jd7hsbozakpedh5i.ipfs.nftstorage.link/{id}.json";

  const block = await ethers.provider.getBlock("latest");
  const blockTime = block?.timestamp || 0;
  const expiry = blockTime + 365 * 24 * 60;

  const sovToken = ERC20__factory.connect(addressList.GHO, owner);
  const TravelPBM = TravelPBM__factory.connect(addressList.TravelPBM, owner);
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