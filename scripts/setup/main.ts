import { createPBMTypes } from "./createPBMTypes";
import { initPBM } from "./initPBM";
import { mintPBM } from "./mintPBM";
import { setPBMToManager } from "./setPBMToManager";
import { transferDistributorOwnership } from "./transferDistributorOwnership";
import { transferLogicOwnership } from "./transferLogicOwnership";

const main = async () => {
  await initPBM();
  await setPBMToManager();
  await createPBMTypes();
  await transferLogicOwnership();
  await transferDistributorOwnership();
  await mintPBM();
};

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
