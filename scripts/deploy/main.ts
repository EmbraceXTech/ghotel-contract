import { deployPBMDistributor } from "./deployDistributor";
import { deployGovHelper } from "./deployGovHelper";
import { deployTravelLogic } from "./deployTravelLogic";
import { deployTravelPBM } from "./deployTravelPBM";
import { deployTravelPBMManager } from "./deployTravelPBMManager";

const main = async () => {
  const uri =
    "https://bafybeihidh7z4tgengyhu7qwmden6e4dzy42tds7h2jd7hsbozakpedh5i.ipfs.nftstorage.link/{id}.json";

  // await deployPayment(); //one time

  await deployTravelLogic();
  await deployTravelPBMManager();
  await deployTravelPBM(uri);
  await deployPBMDistributor();
  await deployGovHelper();
};

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
