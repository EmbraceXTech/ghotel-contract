import hre, { ethers } from "hardhat";
import addressUtil, { setAddress } from "../../utils/address.util";

export async function deployPayment() {
  const addressList = await addressUtil.getAddressList(hre.network.name);
  const [owner] = await ethers.getSigners();

  const Payment = (await ethers.getContractFactory(
    "Payment",
    owner
  ));

  const payment = await Payment.deploy(addressList['Permit2']);
  await payment.waitForDeployment();

  const paymentAddr = await payment.getAddress();
  console.log("Payment deployed address:", paymentAddr);

  setAddress("Payment", paymentAddr, hre.network.name);
  return paymentAddr;
}
