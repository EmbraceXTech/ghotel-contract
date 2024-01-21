import hre, { ethers } from "hardhat";
import addressUtil, { setAddress } from "../../utils/address.util";

export async function deployGovHelper() {
  const addressList = await addressUtil.getAddressList(hre.network.name);
  const [owner] = await ethers.getSigners();

  const GovHelper = (await ethers.getContractFactory(
    "GovHelper",
    owner
  ));

  const govHelper = await GovHelper.deploy(addressList['TravelPBM'], addressList['PBMDistributor'], addressList['TravelLogic']);
  await govHelper.waitForDeployment();

  const govHelperAddr = await govHelper.getAddress();
  console.log("GovHelper deployed address:", govHelperAddr);

  setAddress("GovHelper", govHelperAddr, hre.network.name);
  return govHelperAddr;
}
