import hre, { ethers } from "hardhat";
import { getAddressList } from "../../utils/address.util";
import { TravelPBM__factory } from "../../typechain-types";

const main = async () => {
  const [owner] = await ethers.getSigners();
  const addressList = getAddressList(hre.network.name);

  const sovToken = "";
  const block = await ethers.provider.getBlock("latest");
  const blockTime = block?.timestamp || 0;
  const expiry = blockTime + 365 * 24 * 60;

  const TravelPBM = TravelPBM__factory.connect(addressList.TravelPBM, owner);
  const tx = await TravelPBM.initialise(
    sovToken,
    expiry,
    addressList.TravelLogic,
    addressList.TravelPBMManager
  );
  await tx.wait();

  console.log("TravelPBM initialised successfully !");
};

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
