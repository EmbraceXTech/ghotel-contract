import hre, { ethers } from "hardhat";
import { getAddressList } from "../../utils/address.util";
import {
  TravelPBM__factory,
} from "../../typechain-types";
import { ERC20__factory } from "../../typechain-types/factories/solmate/src/tokens";

export const mintPBM = async () => {
  const [owner] = await ethers.getSigners();
  const addressList = getAddressList(hre.network.name);

  const sovToken = ERC20__factory.connect(addressList.GHO, owner);
  const travelPBM = TravelPBM__factory.connect(addressList.TravelPBM, owner);

  const tx = await sovToken.approve(addressList['TravelPBM'], ethers.MaxUint256);
  await tx.wait();

  const tx2 = await travelPBM.safeMintBatch(addressList['PBMDistributor'], [0, 1, 2], [ethers.parseEther("400000"), ethers.parseEther("400000"), ethers.parseEther("200000")], ethers.encodeBytes32String(""))
  await tx2.wait();
};