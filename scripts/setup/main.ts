import { createPBMTypes } from "./createPBMTypes";
import { initPBM } from "./initPBM";
import { mintPBM } from "./mintPBM";
import { setPBMToManager } from "./setPBMToManager";
import { transferLogicOwnership } from "./transferLogicOwnership";

const main = async () => {
  // const uri =
  //   "https://bafybeihidh7z4tgengyhu7qwmden6e4dzy42tds7h2jd7hsbozakpedh5i.ipfs.nftstorage.link/{id}.json";

  // await deployPayment(); //one time

  await initPBM();
  await setPBMToManager();
  await createPBMTypes();
  await transferLogicOwnership();
  await mintPBM();
};

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
