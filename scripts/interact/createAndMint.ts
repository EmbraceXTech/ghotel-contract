import hre, { ethers } from "hardhat";
import { getAddressList } from "../../utils/address.util";
import {
  TravelPBMManager__factory,
  TravelPBM__factory,
} from "../../typechain-types";
import { ERC20__factory } from "../../typechain-types/factories/solmate/src/tokens";

const main = async () => {
  const [owner] = await ethers.getSigners();
  const addressList = getAddressList(hre.network.name);
  const uri =
    "https://bafybeih5ij4dbras2du3eq2rbbl54ffzqx5dqghswpqyiarlpcs2psijji.ipfs.nftstorage.link/{id}.json";

  const block = await ethers.provider.getBlock("latest");
  const blockTime = block?.timestamp || 0;
  const expiry = blockTime + 365 * 24 * 60;

  const sovToken = ERC20__factory.connect(addressList.GHO, owner);
  const TravelPBM = TravelPBM__factory.connect(addressList.TravelPBM, owner);
  const TravelPBMManager = TravelPBMManager__factory.connect(
    addressList.TravelPBMManger,
    owner
  );

  const create = await TravelPBMManager.createPBMTokenType(
    "Hotel",
    1,
    expiry,
    uri,
    4000
  );

  await create.wait();

  const approve = await sovToken.approve(
    addressList.TravelPBM,
    ethers.MaxUint256
  );
  await approve.wait();

  const mint = await TravelPBM.safeMint(
    owner.address,
    0,
    ethers.parseEther("10"),
    ethers.encodeBytes32String("")
  );
  await mint.wait();
};

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
